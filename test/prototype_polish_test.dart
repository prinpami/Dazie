import 'dart:async';
import 'dart:io';
import 'package:dazie/services/app_services.dart';

import 'package:dazie/main.dart';
import 'package:dazie/models/app_settings.dart';
import 'package:dazie/screens/chat_screen.dart';
import 'package:dazie/screens/settings_screen.dart';
import 'package:dazie/screens/register_screen.dart';
import 'package:dazie/screens/login_screen.dart';
import 'package:dazie/services/nearby_failure.dart';
import 'package:dazie/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dazie/widgets/chat_bubble.dart';
import 'package:dazie/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'support/test_services.dart';

void main() {
  test(
    'saved appearance, legacy profile, and messages survive reopening storage',
    () async {
      final directory = await Directory.systemTemp.createTemp('dazie-storage-');
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/app.db';
      var services = await AppServices.open(
        testDatabasePath: path,
        nearbyService: FakeNearby(),
      );
      final profile = await services.profiles.saveProfile(
        username: 'Legacy',
        email: 'legacy@example.com',
      );
      final group = await services.conversations.createGroup(
        name: 'Saved',
        ownerId: profile.id,
      );
      final message = await services.chatSync.sendMessage(
        groupId: group.id,
        text: 'Persisted',
        profile: profile,
      );
      await services.settings.saveSettings(
        const AppSettings(activeStatus: false, appearance: 'Light'),
      );
      await services.close();
      services = await AppServices.open(
        testDatabasePath: path,
        nearbyService: FakeNearby(),
      );
      addTearDown(services.close);
      expect(services.settings.current.appearance, 'Light');
      expect(services.settings.current.activeStatus, false);
      expect(
        (await services.profiles.getCurrentProfile())!.toMap(),
        profile.toMap(),
      );
      expect(
        (await services.messages.getMessage(message.id))!.toMap(),
        message.toMap(),
      );
      expect(
        (await services.conversations.getConversation(group.id))!.ownerId,
        profile.id,
      );
    },
  );

  testWidgets(
    'message options support keyboard and a screen-reader action without a visible button',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: const ChatMessage(
                id: 'm',
                groupId: 'g',
                senderId: 'me',
                sender: 'Me',
                text: 'Hello',
                createdAt: '2026-10-04T00:00:00Z',
                isMine: true,
              ),
              onDelete: () {},
            ),
          ),
        ),
      );
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      final semanticWidget = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(ChatBubble),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Semantics &&
                    widget.properties.customSemanticsActions != null,
              ),
            )
            .first,
      );
      expect(
        semanticWidget.properties.customSemanticsActions!.keys.single.label,
        'Message options',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Delete message on this device'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'creation keeps existing accounts and adds another local account',
    () async {
      final services = await testServices();
      addTearDown(services.close);
      final old = await services.profiles.saveProfile(
        username: 'Original',
        email: 'old@example.com',
      );
      final group = await services.conversations.createGroup(
        name: 'Saved',
        ownerId: old.id,
      );
      final replacement = await services.profiles.createProfile(
        username: 'Replacement',
      );
      final current = (await services.profiles.getCurrentProfile())!;
      expect(current.toMap(), replacement.toMap());
      expect(
        (await services.profiles.getProfiles()).map((profile) => profile.id),
        containsAll([old.id, replacement.id]),
      );
      expect(
        (await services.conversations.getConversation(group.id))!.ownerId,
        old.id,
      );
    },
  );

  testWidgets('register route creates another account after logging out', (
    tester,
  ) async {
    final services = await testServices();
    addTearDown(services.close);
    final old = await services.profiles.saveProfile(
      username: 'Original',
      email: 'old@example.com',
    );
    await services.profiles.clearCurrentProfile();
    await tester.pumpWidget(MainApp(services: services));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Next account');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Start your first chat'), findsOneWidget);
    expect(
      (await services.profiles.getCurrentProfile())!.username,
      'Next account',
    );
    expect((await services.profiles.getProfiles()).length, 2);
    expect(
      (await services.profiles.getProfiles()).map((p) => p.id),
      contains(old.id),
    );
  });

  testWidgets('profile creation shows progress and rejects duplicate taps', (
    tester,
  ) async {
    final services = await testServices();
    addTearDown(services.close);
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(services: services),
        routes: {'/home': (_) => const Scaffold(body: Text('Saved'))},
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your name.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'New name');
    final gate = Completer<void>();
    final transaction = services.database.database.transaction(
      (_) => gate.future,
    );
    await tester.pump();
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    gate.complete();
    await tester.pumpAndSettle();
    await transaction;
    expect(find.text('Saved'), findsOneWidget);
    expect((await services.profiles.getCurrentProfile())!.email, isEmpty);
  });

  testWidgets('profile read and create failures have visible recovery', (
    tester,
  ) async {
    final services = await testServices();
    addTearDown(services.close);
    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(services: services)),
    );
    await tester.pumpAndSettle();
    await services.database.close();
    await tester.enterText(find.byType(TextFormField), 'Me');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Could not register. Try again.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.pumpWidget(MaterialApp(home: LoginScreen(services: services)));
    await tester.pumpAndSettle();
    expect(find.text('Could not load accounts.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'saved appearance applies to every route and follows system changes',
    (tester) async {
      final services = await testServices();
      addTearDown(services.close);
      await services.settings.saveSettings(
        const AppSettings(activeStatus: false, appearance: 'Dark'),
      );
      await tester.pumpWidget(MainApp(services: services));
      await tester.pumpAndSettle();
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(Scaffold).last)).brightness;
      expect(brightness(), Brightness.dark);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      for (final appearance in ['Light', 'Dark']) {
        await services.settings.saveSettings(
          AppSettings(activeStatus: false, appearance: appearance),
        );
        await tester.pumpAndSettle();
        final expected = appearance == 'Light'
            ? Brightness.light
            : Brightness.dark;
        expect(brightness(), expected);
        for (final route in [
          '/register',
          '/login',
          '/home',
          '/chat',
          '/discover',
          '/settings',
        ]) {
          nav.pushNamed(route);
          await tester.pumpAndSettle();
          expect(brightness(), expected, reason: '$route in $appearance');
          nav.pop();
          await tester.pumpAndSettle();
        }
      }
      await services.settings.saveSettings(
        const AppSettings(activeStatus: true, appearance: 'System'),
      );
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      for (final value in [Brightness.light, Brightness.dark]) {
        tester.platformDispatcher.platformBrightnessTestValue = value;
        await tester.pumpAndSettle();
        expect(brightness(), value);
      }
      expect((await services.settings.getSettings()).appearance, 'System');
    },
  );

  testWidgets(
    'appearance saves immediately; failed save preserves the selection',
    (tester) async {
      final services = await testServices();
      addTearDown(services.close);
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(displayName: 'Me', services: services),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active Status'), findsNothing);
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(services.settings.current.appearance, 'Dark');
      expect((await services.settings.getSettings()).appearance, 'Dark');
      await services.database.close();
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save appearance'), findsOneWidget);
      expect(services.settings.current.appearance, 'Dark');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'log out waits for nearby shutdown, retries failure, and keeps saved data',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final radio = FakeNearby();
      final services = await testServices(nearby: radio);
      addTearDown(services.close);
      final profile = await services.profiles.createProfile(username: 'Me');
      final group = await services.chatSync.startGroup('Saved group', profile);
      await services.chatSync.sendMessage(
        groupId: group.id,
        text: 'Keep me',
        profile: profile,
      );
      await tester.pumpWidget(MainApp(services: services));
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/settings', arguments: 'Me');
      await tester.pumpAndSettle();
      radio.stoppingGate = Completer<void>();
      radio.stoppingError = const NearbyFailure('Radio busy. Try again.');
      await tester.tap(find.text('Log out'));
      await tester.pump();
      expect(find.text('Logging out…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      radio.stoppingGate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Radio busy. Try again.'), findsOneWidget);
      expect(services.chatSync.isHosting, true);
      radio.stoppingGate = null;
      radio.stoppingError = null;
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(services.chatSync.hasSession, false);
      expect(radio.stopCalls, 2);
      expect(await services.profiles.getCurrentProfile(), isNull);
      expect(
        (await services.profiles.getProfiles()).map((item) => item.id),
        contains(profile.id),
      );
      expect(
        (await services.messages.getLatestMessages(group.id)).single.text,
        'Keep me',
      );
      expect(await services.conversations.getConversation(group.id), isNotNull);
    },
  );

  testWidgets('message stream distinguishes loading, empty, error and retry', (
    tester,
  ) async {
    final services = await testServices();
    addTearDown(services.close);
    final group = await services.conversations.createGroup(
      name: 'Saved group',
      ownerId: 'me',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ChatScreen(
          groupId: group.id,
          conversationTitle: group.name,
          services: services,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No messages yet. Say hello!'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
    final record = stringMapStoreFactory.store('messages').record('broken');
    await record.put(services.database.database, {'groupId': group.id});
    await tester.pumpAndSettle();
    expect(
      find.text('Could not load messages. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('No messages yet. Say hello!'), findsNothing);
    await record.delete(services.database.database);
    // Retry also works while the bad record is still present; subsequent valid
    // snapshots recover automatically after the local data is repaired.
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
