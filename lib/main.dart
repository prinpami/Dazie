import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

// I keep the first four routes here so it is easy to see the demo's flow.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dazie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        late final Widget screen;

        // The home route gets a display name from the local demo form.
        switch (settings.name) {
          case '/':
            screen = const OnboardingScreen();
            break;
          case '/login':
            screen = const LoginScreen();
            break;
          case '/register':
            screen = const RegisterScreen();
            break;
          case '/home':
            screen = HomeScreen(
              displayName: settings.arguments as String? ?? 'taylor',
            );
            break;
          case '/settings':
            screen = SettingsScreen(
              displayName: settings.arguments as String? ?? 'taylor',
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
