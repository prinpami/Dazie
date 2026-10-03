import 'package:dazie/main.dart';
import 'package:dazie/screens/chat_screen.dart';
import 'package:dazie/screens/discovery_screen.dart';
import 'package:dazie/services/app_services.dart';
import 'package:dazie/services/nearby_event.dart';
import 'package:dazie/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_services.dart';

void main() {
  Future<AppServices> fixture(WidgetTester tester, {FakeNearby? nearby}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final services = await testServices(nearby: nearby);
    addTearDown(services.close);
    return services;
  }

  testWidgets('registration saves profile and opens an empty real chat list', (
    tester,
  ) async {
    final services = await fixture(tester);
    await tester.pumpWidget(MainApp(services: services));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sampleuser');
    await tester.enterText(fields.at(1), 'sample@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');
    await tester.ensureVisible(find.text('REGISTER'));
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();
    expect(find.text('Your conversations will show up here.'), findsOneWidget);
    expect(
      (await services.profiles.getCurrentProfile())!.username,
      'sampleuser',
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'find group is visibly enabled; searching disables hosting and offers stop',
    (tester) async {
      final radio = FakeNearby();
      final services = await fixture(tester, nearby: radio);
      await services.profiles.saveProfile(username: 'Me', email: 'me@test.com');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DiscoveryScreen(displayName: 'Me', services: services),
        ),
      );
      await tester.pumpAndSettle();
      final findButton = find.widgetWithText(FilledButton, 'Find a group');
      expect(tester.widget<FilledButton>(findButton).onPressed, isNotNull);
      await tester.tap(findButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Stop searching'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Host a group'),
            )
            .onPressed,
        isNull,
      );
      expect(radio.findingCalls, 1);
      await tester.tap(find.text('Stop searching'));
      await tester.pumpAndSettle();
      expect(find.text('Find a group'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'connected group replaces join controls and exposes chat and leave',
    (tester) async {
      final radio = FakeNearby();
      final services = await fixture(tester, nearby: radio);
      final profile = await services.profiles.saveProfile(
        username: 'Me',
        email: 'me@test.com',
      );
      await services.chatSync.startGroup('Friends', profile);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DiscoveryScreen(displayName: 'Me', services: services),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hosting · waiting for members'), findsOneWidget);
      expect(find.text('Open chat'), findsOneWidget);
      expect(find.text('Find a group'), findsNothing);
      await tester.tap(find.text('Stop hosting'));
      await tester.pumpAndSettle();
      expect(find.text('Find a group'), findsOneWidget);
    },
  );
  testWidgets(
    'connection verification is available away from discovery and closes on disconnect',
    (tester) async {
      final radio = FakeNearby();
      final services = await fixture(tester, nearby: radio);
      final profile = await services.profiles.saveProfile(
        username: 'Me',
        email: 'me@test.com',
      );
      await services.chatSync.startGroup('Friends', profile);
      await tester.pumpWidget(MainApp(services: services));
      await tester.pumpAndSettle();
      radio.emit(
        const NearbyEvent(
          type: NearbyEventType.connectionRequest,
          endpointId: 'guest',
          name: 'Guest',
          authenticationToken: '1234',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1234'), findsOneWidget);
      radio.emit(
        const NearbyEvent(
          type: NearbyEventType.disconnected,
          endpointId: 'guest',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1234'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('message and chat deletion require explicit local confirmation', (
    tester,
  ) async {
    final services = await fixture(tester);
    final profile = await services.profiles.saveProfile(
      username: 'Me',
      email: 'me@test.com',
    );
    final group = await services.conversations.createGroup(
      name: 'Friends',
      ownerId: profile.id,
    );
    final message = await services.chatSync.sendMessage(
      groupId: group.id,
      text: 'Delete this',
      profile: profile,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ChatScreen(
          groupId: group.id,
          conversationTitle: group.name,
          services: services,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Message options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await services.messages.getMessage(message.id), isNotNull);
    await tester.tap(find.byTooltip('Message options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete for me'));
    await tester.pumpAndSettle();
    expect(await services.messages.getMessage(message.id), isNull);
    await tester.tap(find.byTooltip('Chat options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete chat'));
    await tester.pumpAndSettle();
    expect(find.text('Delete chat on this device?'), findsOneWidget);
    await tester.tap(find.text('Delete for me'));
    await tester.pumpAndSettle();
    expect(await services.conversations.getConversation(group.id), isNull);
  });
}
