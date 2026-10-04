import 'dart:async';
import 'dart:io';
import 'package:dazie/models/chat_message.dart';
import 'package:dazie/services/android_nearby_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dazie/services/nearby_event.dart';
import 'package:dazie/services/nearby_failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_services.dart';

void main() {
  test('runtime permission matrix covers Android API 23 through 37', () {
    for (final sdk in [23, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37]) {
      final permissions = requiredNearbyPermissions(sdk);
      expect(permissions.contains(Permission.locationWhenInUse), sdk <= 32);
      expect(permissions.contains(Permission.nearbyWifiDevices), sdk >= 33);
      expect(permissions.contains(Permission.bluetoothScan), sdk >= 31);
      expect(permissions.contains(Permission.bluetooth), false);
    }
  });
  test('Wi-Fi permissions are not capped; location covers Android 12L', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    for (final permission in [
      'ACCESS_WIFI_STATE',
      'CHANGE_WIFI_STATE',
      'INTERNET',
    ]) {
      expect(
        RegExp(
          '<uses-permission[^>]*android.permission.$permission[^>]*>',
        ).firstMatch(manifest)!.group(0),
        isNot(contains('maxSdkVersion')),
      );
    }
    for (final permission in [
      'ACCESS_COARSE_LOCATION',
      'ACCESS_FINE_LOCATION',
    ]) {
      expect(
        RegExp(
          '<uses-permission[^>]*android.permission.$permission[^>]*>',
        ).firstMatch(manifest)!.group(0),
        contains('maxSdkVersion="32"'),
      );
    }
  });
  test(
    'missing install permission and denied runtime access have different recovery',
    () {
      final install = NearbyFailure.from(
        PlatformException(
          code: 'Failure',
          message: '8032: MISSING_PERMISSION_ACCESS_WIFI_STATE',
        ),
      );
      expect(install.message, contains('APK'));
      expect(install.openSettings, false);
      final runtime = NearbyFailure.from(
        PlatformException(
          code: 'Failure',
          message: 'MISSING_PERMISSION_BLUETOOTH_SCAN',
        ),
      );
      expect(runtime.openSettings, true);
    },
  );
  test(
    'failed host creates no chat, rapid taps coalesce, resume preserves group ID',
    () async {
      final nearby = FakeNearby();
      final services = await testServices(nearby: nearby);
      addTearDown(services.close);
      final profile = await services.profiles.saveProfile(
        username: 'Host',
        email: 'host@test.com',
      );
      nearby.hostingError = const NearbyFailure('Denied');
      await expectLater(
        services.chatSync.startGroup('Friends', profile),
        throwsA(isA<NearbyFailure>()),
      );
      expect(await services.conversations.watchConversations().first, isEmpty);
      nearby.hostingError = null;
      nearby.hostingGate = Completer<void>();
      final first = services.chatSync.startGroup('Friends', profile);
      final second = services.chatSync.startGroup('Friends', profile);
      nearby.hostingGate!.complete();
      final groups = await Future.wait([first, second]);
      expect(groups[0].id, groups[1].id);
      expect(nearby.hostingCalls, 2);
      await services.chatSync.stopNearby();
      final resumed = await services.chatSync.startGroup(' friends ', profile);
      expect(resumed.id, groups.first.id);
      expect(
        await services.conversations.watchConversations().first,
        hasLength(1),
      );
    },
  );
  test(
    'deleting a message updates preview and blocks history resurrection',
    () async {
      final services = await testServices();
      addTearDown(services.close);
      final group = await services.conversations.createGroup(
        name: 'Test',
        ownerId: 'me',
      );
      final first = ChatMessage(
        id: 'first',
        groupId: group.id,
        senderId: 'me',
        sender: 'Me',
        text: 'First',
        createdAt: '2026-01-01T00:00:00Z',
        isMine: true,
      );
      final last = ChatMessage(
        id: 'last',
        groupId: group.id,
        senderId: 'me',
        sender: 'Me',
        text: 'Last',
        createdAt: '2026-01-02T00:00:00Z',
        isMine: true,
      );
      await services.messages.saveMessage(last);
      await services.messages.saveMessage(first);
      expect(
        (await services.conversations.getConversation(group.id))!.lastMessage,
        'Last',
      );
      await services.messages.deleteMessage(last.id);
      expect(
        (await services.conversations.getConversation(group.id))!.lastMessage,
        'First',
      );
      expect(await services.messages.saveMessage(last), false);
      await services.chatSync.deleteConversation(group.id);
      expect(await services.messages.getLatestMessages(group.id), isEmpty);
      expect(await services.conversations.getConversation(group.id), isNull);
      expect(await services.conversations.isDeleted(group.id), true);
    },
  );
  test(
    'two peers sync one group, route messages only to that group, and retry sent messages',
    () async {
      final hostRadio = FakeNearby();
      final guestRadio = FakeNearby();
      final host = await testServices(nearby: hostRadio);
      final guest = await testServices(nearby: guestRadio);
      addTearDown(host.close);
      addTearDown(guest.close);
      final hostProfile = await host.profiles.saveProfile(
        username: 'Host',
        email: 'h@test.com',
      );
      final guestProfile = await guest.profiles.saveProfile(
        username: 'Guest',
        email: 'g@test.com',
      );
      final group = await host.chatSync.startGroup('Friends', hostProfile);
      await guest.chatSync.connect('host', guestProfile);
      hostRadio.deliver = (_, packet) => guestRadio.emit(
        NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: 'host',
          packet: packet,
        ),
      );
      guestRadio.deliver = (_, packet) => hostRadio.emit(
        NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: 'guest',
          packet: packet,
        ),
      );
      hostRadio.emit(
        const NearbyEvent(type: NearbyEventType.connected, endpointId: 'guest'),
      );
      guestRadio.emit(
        const NearbyEvent(type: NearbyEventType.connected, endpointId: 'host'),
      );
      await settleEvents();
      expect(guest.chatSync.activeConversation?.id, group.id);
      expect(guest.chatSync.connectionCount(group.id), 1);
      expect(host.chatSync.connectionCount(group.id), 1);
      final message = await guest.chatSync.sendMessage(
        groupId: group.id,
        text: 'Hello',
        profile: guestProfile,
      );
      await settleEvents();
      expect(
        (await host.messages.getLatestMessages(group.id)).single.text,
        'Hello',
      );
      expect(
        (await guest.messages.getMessage(message.id))!.deliveryStatus,
        'delivered',
      );
      final other = await guest.conversations.createGroup(
        name: 'Private',
        ownerId: guestProfile.id,
      );
      guestRadio.sent.clear();
      await guest.chatSync.sendMessage(
        groupId: other.id,
        text: 'Private text',
        profile: guestProfile,
      );
      expect(guestRadio.sent, isEmpty);
      expect(
        (await guest.messages.getLatestMessages(
          other.id,
        )).single.deliveryStatus,
        'queued',
      );
      await guest.messages.deleteMessage(message.id);
      hostRadio.deliver!('guest', {
        'type': 'message',
        'message': message.toMap(),
      });
      await settleEvents();
      expect(await guest.messages.getMessage(message.id), isNull);
      guestRadio.emit(
        const NearbyEvent(
          type: NearbyEventType.disconnected,
          endpointId: 'host',
        ),
      );
      await settleEvents();
      expect(guest.chatSync.connectionCount(group.id), 0);
      expect(guest.chatSync.activeConversation?.id, group.id);
      await guest.chatSync.stopNearby();
      await guest.chatSync.connect('host', guestProfile);
      hostRadio.emit(
        const NearbyEvent(type: NearbyEventType.connected, endpointId: 'guest'),
      );
      guestRadio.emit(
        const NearbyEvent(type: NearbyEventType.connected, endpointId: 'host'),
      );
      await settleEvents();
      expect(
        await guest.conversations.watchConversations().first,
        hasLength(2),
      );
      expect(await guest.messages.getMessage(message.id), isNull);
    },
  );
  test('connection rejection clears busy state and permits retry', () async {
    final radio = FakeNearby();
    final services = await testServices(nearby: radio);
    addTearDown(services.close);
    final profile = await services.profiles.saveProfile(
      username: 'Me',
      email: 'me@test.com',
    );
    await services.chatSync.connect('host', profile);
    expect(services.chatSync.isBusy, true);
    radio.emit(
      const NearbyEvent(
        type: NearbyEventType.connectionFailed,
        endpointId: 'host',
        message: 'Declined',
      ),
    );
    await settleEvents();
    expect(services.chatSync.isBusy, false);
    expect(services.chatSync.error?.message, 'Declined');
    await services.chatSync.findGroups(profile);
    expect(services.chatSync.isSearching, true);
  });
}
