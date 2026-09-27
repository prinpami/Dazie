import 'package:dazie/main.dart';
import 'package:dazie/screens/home_screen.dart';
import 'package:dazie/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('brand images and fonts are bundled', () async {
    const assetPaths = [
      'assets/images/BackButton.png',
      'assets/images/Create.png',
      'assets/images/DAZIE.png',
      'assets/images/Dazie_Logo.png',
      'assets/images/Discovery.png',
      'assets/images/Dropdown.png',
      'assets/images/Facebook.png',
      'assets/images/Google.png',
      'assets/images/HamburgerMenu.png',
      'assets/images/PhoneCall.png',
      'assets/images/RadarButton.png',
      'assets/images/PFP.svg',
      'assets/images/Vector.png',
      'assets/images/Vector-1.png',
      'assets/images/Vector-2.png',
      'assets/images/Vector-3.png',
      'assets/fonts/Fredoka-VariableFont_wdth,wght.ttf',
      'assets/fonts/NunitoSans-VariableFont_YTLC,opsz,wdth,wght.ttf',
      'assets/fonts/NunitoSans-Italic-VariableFont_YTLC,opsz,wdth,wght.ttf',
    ];

    for (final assetPath in assetPaths) {
      final data = await rootBundle.load(assetPath);
      expect(data.lengthInBytes, greaterThan(0), reason: assetPath);
    }
  });

  testWidgets('local registration opens the searchable chat list', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Stay connected, even offline.'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Stay connected, even offline.')))
          .brightness,
      Brightness.light,
    );

    final getStartedButton = find.text('GET STARTED');
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();
    expect(find.text('Sign up'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sampleuser');
    await tester.enterText(fields.at(1), 'sampleuser@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');
    final registerButton = find.text('REGISTER');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Taylor Morgan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Family');
    await tester.pumpAndSettle();
    expect(find.text('Family GC'), findsOneWidget);
    expect(find.text('Group Chat Placeholder'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('@sampleuser'), findsOneWidget);
  });

  testWidgets('welcome and account screens match mockup field sizing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.bySemanticsLabel('Dazie mascot')),
      const Size(160, 160),
    );
    expect(tester.getSize(find.byType(FilledButton)), const Size(304, 48));

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextFormField).first),
      const Size(304, 47),
    );

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('home mockup uses its fixed-width search and orange avatars', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const HomeScreen(displayName: 'taylor'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(TextField)), const Size(350, 28));
    expect(tester.getSize(find.byType(CircleAvatar).first), const Size(58, 58));
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('nearby demo connects locally and opens chat and compass', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sampleuser');
    await tester.enterText(fields.at(1), 'sampleuser@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Discover nearby friends'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Device discovery is not active.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Mia Santos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONNECT'));
    await tester.pumpAndSettle();
    expect(find.text('Connected in this demo'), findsOneWidget);

    await tester.tap(find.text('MESSAGE Mia Santos'));
    await tester.pumpAndSettle();
    expect(
      find.text('Local demo · messages stay on this device'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'See you soon');
    await tester.tap(find.byTooltip('Send message on this device'));
    await tester.pumpAndSettle();
    expect(find.text('See you soon'), findsOneWidget);

    await tester.tap(find.byTooltip('Open friend direction preview'));
    await tester.pumpAndSettle();
    expect(find.text('Friend direction'), findsOneWidget);
    expect(find.text('LAST KNOWN · 4 MIN AGO'), findsOneWidget);
  });
}
