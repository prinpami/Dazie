import 'dart:io';
import 'package:dazie/models/app_settings.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:dazie/screens/onboarding_screen.dart';
import 'package:dazie/screens/register_screen.dart';
import 'package:dazie/screens/login_screen.dart';
import 'package:dazie/screens/settings_screen.dart';
import 'package:dazie/screens/home_screen.dart';
import 'package:dazie/widgets/peer_connect_sheet.dart';
import 'package:dazie/screens/discovery_screen.dart';
import 'package:dazie/screens/chat_screen.dart';
import 'package:dazie/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final body = FontLoader('Nunito Sans')
      ..addFont(
        rootBundle.load(
          'assets/fonts/NunitoSans-VariableFont_YTLC,opsz,wdth,wght.ttf',
        ),
      );
    final heading = FontLoader('Fredoka')
      ..addFont(
        rootBundle.load('assets/fonts/Fredoka-VariableFont_wdth,wght.ttf'),
      );
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([body.load(), heading.load(), icons.load()]);
  });
  testWidgets(
    'profile and chat fit a narrow screen with keyboard and 2x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final services = await testServices();
      addTearDown(services.close);
      Widget app(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: child,
      );
      await tester.pumpWidget(app(RegisterScreen(services: services)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField));
      await tester.enterText(find.byType(TextFormField), 'Me');
      expect(tester.takeException(), isNull);
      final profile = await services.profiles.createProfile(username: 'Me');
      final group = await services.conversations.createGroup(
        name: 'Friends',
        ownerId: profile.id,
      );
      await tester.pumpWidget(
        app(
          ChatScreen(
            groupId: group.id,
            conversationTitle: group.name,
            services: services,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'A draft');
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomRight(find.byTooltip('Send message')).dy,
        lessThanOrEqualTo(400),
      );
    },
  );
  for (final scale in [1.0, 2.0]) {
    for (final dark in [false, true]) {
      for (final width in [320.0, 390.0]) {
        testWidgets(
          'all screens fit $width at ${scale}x text in ${dark ? 'dark' : 'light'} theme',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 844);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final services = await testServices();
            addTearDown(services.close);
            await services.settings.saveSettings(
              AppSettings(
                activeStatus: true,
                appearance: dark ? 'Dark' : 'Light',
              ),
            );
            const key = ValueKey('all-screen-capture');
            Widget app(Widget child) => MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: RepaintBoundary(key: key, child: child),
            );
            Future<void> check(String name, Widget screen) async {
              await tester.pumpWidget(app(screen));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: name);
              await capture(
                tester,
                key,
                '$name-${dark ? 'dark' : 'light'}-${width.toInt()}-${scale.toInt()}x',
              );
            }

            await check('onboarding', const OnboardingScreen());
            await tester.ensureVisible(find.text('Login'));
            expect(
              tester
                  .getSize(find.widgetWithText(OutlinedButton, 'Login'))
                  .height,
              greaterThanOrEqualTo(48),
            );
            await check('register', RegisterScreen(services: services));
            await tester.tap(find.text('Create account'));
            await tester.pumpAndSettle();
            expect(find.text('Enter your name.'), findsOneWidget);
            expect(tester.takeException(), isNull);
            final profile = await services.profiles.createProfile(
              username: scale == 1
                  ? 'Taylor'
                  : 'A long display name for a local profile',
            );
            final group = await services.conversations.createGroup(
              name: scale == 1
                  ? 'Friends and family'
                  : 'Friends and family with a long group name',
              ownerId: profile.id,
            );
            await services.chatSync.sendMessage(
              groupId: group.id,
              text: 'A saved message waiting for the group to reconnect.',
              profile: profile,
            );
            await check('login', LoginScreen(services: services));
            await check(
              'home',
              HomeScreen(
                displayName: profile.username,
                profileId: profile.id,
                services: services,
              ),
            );
            await check(
              'settings',
              SettingsScreen(displayName: profile.username, services: services),
            );
            expect(find.text('Log out'), findsOneWidget);
            expect(tester.takeException(), isNull);
            await check(
              'discovery',
              DiscoveryScreen(
                displayName: profile.username,
                services: services,
              ),
            );
            await check(
              'chat',
              ChatScreen(
                groupId: group.id,
                conversationTitle: group.name,
                services: services,
              ),
            );
            await tester.longPress(
              find.text('A saved message waiting for the group to reconnect.'),
            );
            await tester.pumpAndSettle();
            expect(find.text('Delete message on this device'), findsOneWidget);
            expect(tester.takeException(), isNull);
            Navigator.of(
              tester.element(find.text('Delete message on this device')),
            ).pop();
            await tester.pumpAndSettle();
            await check(
              'peer_connect',
              Scaffold(
                body: SingleChildScrollView(
                  child: PeerConnectSheet(
                    peerName: 'Nearby group member',
                    verificationCode: '1234',
                    onConnect: () {},
                    onDecline: () {},
                  ),
                ),
              ),
            );
          },
        );
      }
    }
  }
  for (final width in [320.0, 390.0]) {
    testWidgets('discovery and chat fit width $width with large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final services = await testServices();
      addTearDown(services.close);
      final profile = await services.profiles.saveProfile(
        username: 'Me',
        email: 'me@test.com',
      );
      const captureKey = ValueKey('capture');
      Widget app(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 844),
            textScaler: TextScaler.linear(1.4),
          ),
          child: RepaintBoundary(key: captureKey, child: child),
        ),
      );
      await tester.pumpWidget(
        app(DiscoveryScreen(displayName: 'Me', services: services)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, captureKey, 'discovery-${width.toInt()}');
      final group = await services.chatSync.startGroup(
        'Friends and family',
        profile,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, captureKey, 'hosting-${width.toInt()}');
      await services.chatSync.sendMessage(
        groupId: group.id,
        text: 'A saved message waiting for the group to reconnect.',
        profile: profile,
      );
      await tester.pumpWidget(
        app(
          ChatScreen(
            groupId: group.id,
            conversationTitle: group.name,
            services: services,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, captureKey, 'chat-${width.toInt()}');
    });
  }
}

Future<void> capture(WidgetTester tester, Key key, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_UI')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('/tmp/dazie-ui').create(recursive: true);
    await File(
      '/tmp/dazie-ui/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
