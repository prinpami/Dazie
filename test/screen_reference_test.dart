import 'dart:io';
import 'dart:ui' as ui;
import 'package:dazie/screens/discovery_screen.dart';
import 'package:dazie/screens/chat_screen.dart';
import 'package:dazie/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_services.dart';

void main() {
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
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  await tester.runAsync(() async {
    await Directory('/tmp/dazie-ui').create(recursive: true);
    await File(
      '/tmp/dazie-ui/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
  });
  image.dispose();
}
