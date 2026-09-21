import 'package:dazie/main.dart';
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
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Stay connected,\neven offline.'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Stay connected,\neven offline.')))
          .brightness,
      Brightness.dark,
    );

    final getStartedButton = find.text('GET STARTED');
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();
    expect(find.text('Create your profile'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ada Lovelace');
    final createProfileButton = find.text('CREATE LOCAL PROFILE');
    await tester.ensureVisible(createProfileButton);
    await tester.tap(createProfileButton);
    await tester.pumpAndSettle();

    expect(find.text('Your chats'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Family');
    await tester.pumpAndSettle();
    expect(find.text('Family GC'), findsOneWidget);
    expect(find.text('Group Chat Placeholder'), findsNothing);
  });
}
