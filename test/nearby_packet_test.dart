import 'dart:convert';

import 'package:dazie/models/chat_message.dart';
import 'package:dazie/services/nearby_event.dart';
import 'package:dazie/services/nearby_packet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_services.dart';

Map<String, Object?> message(
  String id,
  String group, {
  String sender = 'guest',
}) => {
  'id': id,
  'groupId': group,
  'senderId': sender,
  'sender': 'Guest',
  'text': 'Hello',
  'createdAt': '2026-10-04T00:00:00.000Z',
  'isMine': true,
  'deliveryStatus': 'delivered',
};

void main() {
  test(
    'packet decoder rejects damaged JSON, unsupported versions and invalid fields',
    () {
      final valid = <Map<String, Object?>>[
        {'type': 'hello', 'peerId': 'peer', 'displayName': 'Peer'},
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'ownerId': 'host',
          'memberIds': ['host', 'guest'],
        },
        {'type': 'message', 'message': message('m', 'group')},
        {'type': 'ack', 'messageId': 'm'},
      ];
      for (final packet in valid) {
        for (final data in [
          packet,
          {'version': 1, ...packet},
        ]) {
          expect(NearbyPacket.decode(utf8.encode(jsonEncode(data))), isNotNull);
        }
        for (final version in [0, 2, '1', 1.0, null]) {
          expect(
            NearbyPacket.validate({...packet, 'version': version}),
            isNull,
          );
        }
      }
      for (final bytes in [
        utf8.encode('{'),
        [0xff],
        utf8.encode('[]'),
        List.filled(30001, 32),
      ]) {
        expect(NearbyPacket.decode(bytes), isNull);
      }
      final invalid = <Object?>[
        null,
        [],
        {'type': 'unknown'},
        {'type': 'ack', 'messageId': ''},
        {'type': 'hello', 'peerId': ' ', 'displayName': 'Peer'},
        {'type': 'hello', 'peerId': 3, 'displayName': 'Peer'},
        {'type': 'hello', 'peerId': 'peer'},
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'ownerId': 2,
          'memberIds': ['host'],
        },
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'ownerId': 'host',
          'memberIds': ['host', 4],
        },
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'ownerId': 'host',
          'memberIds': ['host', 'host'],
        },
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'ownerId': 'host',
          'memberIds': [],
        },
        {
          'type': 'group',
          'groupId': 'group',
          'name': 'Group',
          'memberIds': ['host'],
          'version': 1,
        },
        {1: 'hello'},
      ];
      for (final key in [
        'id',
        'groupId',
        'senderId',
        'sender',
        'text',
        'createdAt',
      ]) {
        for (final value in ['', null, 2, []]) {
          invalid.add({
            'type': 'message',
            'message': {...message('m', 'group'), key: value},
          });
        }
      }
      for (final entry in {
        'createdAt': 'yesterday',
        'text': 'x' * 2001,
        'isMine': 'true',
        'deliveryStatus': 'read',
      }.entries) {
        invalid.add({
          'type': 'message',
          'message': {...message('m', 'group'), entry.key: entry.value},
        });
      }
      for (final date in [
        '2026-02-30T00:00:00Z',
        '2026-10-04T25:00:00Z',
        '2026-10-04T00:00:00',
      ]) {
        invalid.add({
          'type': 'message',
          'message': {...message('m', 'group'), 'createdAt': date},
        });
      }
      for (final packet in invalid) {
        expect(NearbyPacket.validate(packet), isNull, reason: '$packet');
      }
    },
  );

  test(
    'invalid and spoofed packets cannot mutate a hosted group; subsequent valid packets work',
    () async {
      final radio = FakeNearby();
      final services = await testServices(nearby: radio);
      addTearDown(services.close);
      final profile = await services.profiles.createProfile(username: 'Host');
      final group = await services.chatSync.startGroup('Group', profile);
      radio.emit(
        const NearbyEvent(
          type: NearbyEventType.connected,
          endpointId: 'guest-endpoint',
        ),
      );
      void emit(
        Map<String, Object?> packet, {
        String endpoint = 'guest-endpoint',
      }) => radio.emit(
        NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: endpoint,
          packet: packet,
        ),
      );
      emit({'type': 'hello', 'peerId': 'guest', 'displayName': 'Guest'});
      await settleEvents();
      expect(services.chatSync.connectionCount(group.id), 1);
      final originalMembers = (await services.conversations.getConversation(
        group.id,
      ))!.memberIds;
      emit({'type': 'hello', 'peerId': 'imposter', 'displayName': 'Imposter'});
      emit({
        'version': 9,
        'type': 'message',
        'message': message('unsupported', group.id),
      });
      emit({
        'type': 'message',
        'message': {...message('bad', group.id), 'text': 123},
      });
      emit({'type': 'message', 'message': message('foreign', 'other-group')});
      emit({
        'type': 'message',
        'message': message('spoof', group.id, sender: profile.id),
      });
      emit({
        'type': 'message',
        'message': message('stranger', group.id),
      }, endpoint: 'not-connected');
      emit({'type': 'group', 'groupId': group.id, 'ownerId': 23});
      await settleEvents();
      expect(await services.messages.getLatestMessages(group.id), isEmpty);
      expect(
        (await services.conversations.getConversation(group.id))!.memberIds,
        originalMembers,
      );
      emit({
        'version': 1,
        'type': 'message',
        'message': message('good', group.id),
      });
      await settleEvents();
      final saved = (await services.messages.getLatestMessages(
        group.id,
      )).single;
      expect(saved.id, 'good');
      expect(saved.isMine, false);
      expect(saved.deliveryStatus, 'received');
      expect(services.chatSync.error, isNull);
      expect(radio.sent.every((item) => item.packet['version'] == 1), true);
    },
  );

  test(
    'one group receipt means one peer confirmation, never all recipients',
    () async {
      final radio = FakeNearby();
      final services = await testServices(nearby: radio);
      addTearDown(services.close);
      final profile = await services.profiles.createProfile(username: 'Host');
      final group = await services.chatSync.startGroup('Group', profile);
      final queued = await services.chatSync.sendMessage(
        groupId: group.id,
        text: 'Waiting',
        profile: profile,
      );
      expect(queued.deliveryLabel, 'Waiting to send');
      for (final peer in ['a', 'b']) {
        radio.emit(
          NearbyEvent(type: NearbyEventType.connected, endpointId: peer),
        );
        radio.emit(
          NearbyEvent(
            type: NearbyEventType.packet,
            endpointId: peer,
            packet: {'type': 'hello', 'peerId': peer, 'displayName': peer},
          ),
        );
      }
      await settleEvents();
      final sent = (await services.messages.getMessage(queued.id))!;
      expect(sent.deliveryStatus, 'sent');
      expect(sent.deliveryLabel, 'Sent to a nearby device');
      radio.emit(
        NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: 'stranger',
          packet: {'type': 'ack', 'messageId': queued.id},
        ),
      );
      await settleEvents();
      expect(
        (await services.messages.getMessage(queued.id))!.deliveryStatus,
        'sent',
      );
      radio.emit(
        NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: 'a',
          packet: {'version': 1, 'type': 'ack', 'messageId': queued.id},
        ),
      );
      await settleEvents();
      final confirmed = (await services.messages.getMessage(queued.id))!;
      expect(confirmed.deliveryStatus, 'delivered');
      expect(confirmed.deliveryLabel, 'Confirmed by a nearby device');
      await Future.wait([
        services.messages.updateDeliveryStatus(queued.id, 'delivered'),
        services.messages.updateDeliveryStatus(queued.id, 'sent'),
      ]);
      expect(
        (await services.messages.getMessage(queued.id))!.deliveryStatus,
        'delivered',
      );
      final legacy = message('legacy', group.id)..remove('deliveryStatus');
      expect(
        ChatMessage.fromMap(legacy).deliveryLabel,
        'Sent to a nearby device',
      );
    },
  );

  test(
    'joining peer receives the latest 50 saved messages, not full history',
    () async {
      final radio = FakeNearby();
      final services = await testServices(nearby: radio);
      addTearDown(services.close);
      final profile = await services.profiles.createProfile(username: 'Host');
      final group = await services.chatSync.startGroup('Group', profile);
      for (var i = 0; i < 55; i++) {
        await services.messages.saveMessage(
          ChatMessage(
            id: 'm$i',
            groupId: group.id,
            senderId: profile.id,
            sender: 'Host',
            text: '$i',
            createdAt: DateTime.utc(
              2026,
              1,
              1,
            ).add(Duration(minutes: i)).toIso8601String(),
            isMine: true,
            deliveryStatus: 'delivered',
          ),
        );
      }
      radio.emit(
        const NearbyEvent(type: NearbyEventType.connected, endpointId: 'guest'),
      );
      radio.emit(
        const NearbyEvent(
          type: NearbyEventType.packet,
          endpointId: 'guest',
          packet: {'type': 'hello', 'peerId': 'guest', 'displayName': 'Guest'},
        ),
      );
      await settleEvents();
      final history = radio.sent
          .where((item) => item.packet['type'] == 'message')
          .toList();
      expect(history, hasLength(50));
      expect((history.first.packet['message'] as Map)['id'], 'm5');
      expect((history.last.packet['message'] as Map)['id'], 'm54');
      expect(
        await services.messages.watchMessages(group.id).first,
        hasLength(55),
      );
    },
  );
}
