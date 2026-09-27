import 'package:flutter/material.dart';

import 'services/app_services.dart';
import 'screens/chat_screen.dart';
import 'screens/compass_screen.dart';
import 'screens/discovery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.open();
  runApp(MainApp(services: services));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dazie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        late final Widget screen;
        final arguments = settings.arguments;
        final routeValues = arguments is Map ? arguments : const {};

        // The home route gets a display name from the local demo form.
        switch (settings.name) {
          case '/':
            screen = const OnboardingScreen();
            break;
          case '/login':
            screen = LoginScreen(services: services);
            break;
          case '/register':
            screen = RegisterScreen(services: services);
            break;
          case '/home':
            screen = HomeScreen(
              displayName: settings.arguments as String? ?? 'taylor',
              services: services,
            );
            break;
          case '/settings':
            screen = SettingsScreen(
              displayName: settings.arguments as String? ?? 'taylor',
              services: services,
            );
            break;
          case '/chat':
            screen = ChatScreen(
              groupId: routeValues['id'] as String? ?? '',
              conversationTitle: routeValues['title'] as String? ?? 'Family GC',
              services: services,
            );
            break;
          case '/discover':
            screen = DiscoveryScreen(
              displayName: settings.arguments as String? ?? 'taylor',
              services: services,
            );
            break;
          case '/compass':
            screen = CompassScreen(
              friendName: settings.arguments as String? ?? 'Jordan Lee',
            );
            break;
          default:
            screen = const OnboardingScreen();
            break;
        }

        return MaterialPageRoute<void>(
          builder: (_) => screen,
          settings: settings,
        );
      },
    );
  }
}
