import 'dart:convert';

import 'package:dazie/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _captureKey = ValueKey<String>('screen-capture');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont(
      'Fredoka',
      'assets/fonts/Fredoka-VariableFont_wdth,wght.ttf',
    );
    await _loadFont(
      'Nunito Sans',
      'assets/fonts/NunitoSans-VariableFont_YTLC,opsz,wdth,wght.ttf',
    );
    final manifest = jsonDecode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List<dynamic>;
    final icons = manifest.cast<Map<String, dynamic>>().firstWhere(
      (entry) => entry['family'] == 'MaterialIcons',
    );
    final iconAsset =
        (icons['fonts'] as List<dynamic>).first['asset'] as String;
    await _loadFont('MaterialIcons', iconAsset);
  });

  testWidgets('onboarding screenshot', (tester) async {
    await _openApp(tester);
    await _saveScreen(tester, 'onboarding');
  });

  testWidgets('login screenshot', (tester) async {
    await _openApp(tester);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'login');
  });

  testWidgets('registration screenshot', (tester) async {
    await _openApp(tester);
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'register');
  });

  testWidgets('home screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await _saveScreen(tester, 'home');
  });

  testWidgets('settings screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'settings');
  });

  testWidgets('chat screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await tester.tap(find.text('Taylor Morgan'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'chat');
  });

  testWidgets('discovery screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await tester.tap(find.bySemanticsLabel('Discover nearby friends'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'discovery');
  });

  testWidgets('peer connection sheet screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await tester.tap(find.bySemanticsLabel('Discover nearby friends'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mia Santos'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'peer_connect');
  });

  testWidgets('compass screenshot', (tester) async {
    await _openApp(tester);
    await _openHome(tester);
    await tester.tap(find.text('Taylor Morgan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open friend direction preview'));
    await tester.pumpAndSettle();
    await _saveScreen(tester, 'compass');
  });
}

Future<void> _openApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const RepaintBoundary(key: _captureKey, child: MainApp()),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 250)),
  );
  await tester.pumpAndSettle();
}

Future<void> _openHome(WidgetTester tester) async {
  await tester.tap(find.text('GET STARTED'));
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'sampleuser');
  await tester.enterText(fields.at(1), 'sampleuser@example.com');
  await tester.enterText(fields.at(2), 'example123');
  await tester.enterText(fields.at(3), 'example123');
  await tester.tap(find.text('REGISTER'));
  await tester.pumpAndSettle();
}

Future<void> _saveScreen(WidgetTester tester, String name) async {
  await expectLater(
    find.byKey(_captureKey),
    matchesGoldenFile('screenshots/$name.png'),
  );
}

Future<void> _loadFont(String family, String assetPath) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(assetPath));
  await loader.load();
}
