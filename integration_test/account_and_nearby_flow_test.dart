import 'package:dazie/main.dart';
import 'package:dazie/screens/home_screen.dart';
import 'package:dazie/screens/settings_screen.dart';
import 'package:dazie/services/nearby_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/test_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('accounts, chats, settings, and nearby UI work on Android', (
    tester,
  ) async {
    final radio = FakeNearby();
    final services = await testServices(nearby: radio);
    addTearDown(services.close);

    await tester.pumpWidget(MainApp(services: services));
    await tester.pumpAndSettle();
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Mina');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final firstAccount = (await services.profiles.getCurrentProfile())!;
    await services.conversations.createGroup(
      name: 'Mina chat',
      ownerId: firstAccount.id,
    );
    await tester.pumpAndSettle();
    expect(find.text('Mina chat'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Return to welcome'), findsNothing);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Mina'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Mina chat'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Kai');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Mina chat'), findsNothing);
    expect(find.text('Start your first chat'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Find a nearby group'));
    await tester.pumpAndSettle();
    expect(find.text('Nearby chat'), findsOneWidget);
    expect(find.text('Bluetooth'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Find a group'), findsOneWidget);
    expect(find.text('Host a group'), findsOneWidget);

    final activeProfile = (await services.profiles.getCurrentProfile())!;
    await services.chatSync.connect('nearby-peer', activeProfile);
    radio.emit(
      const NearbyEvent(
        type: NearbyEventType.connectionRequest,
        endpointId: 'nearby-peer',
        name: 'Nearby friend',
        authenticationToken: '483921',
      ),
    );
    await settleEvents();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ACCEPT CONNECTION'), findsOneWidget);

    // A request can disappear while the confirmation sheet is still open.
    // This exercises the framework route cleanup that used to assert.
    radio.emit(
      const NearbyEvent(
        type: NearbyEventType.connectionFailed,
        endpointId: 'nearby-peer',
        message: 'Connection closed.',
      ),
    );
    await settleEvents();
    await tester.pumpAndSettle();
    expect(find.text('ACCEPT CONNECTION'), findsNothing);
    expect(tester.takeException(), isNull);

    final accounts = await services.profiles.getProfiles();
    expect(
      accounts.map((profile) => profile.username),
      unorderedEquals(['Mina', 'Kai']),
    );
  });
}
