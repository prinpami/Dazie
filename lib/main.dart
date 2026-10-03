import 'package:flutter/material.dart';

import 'services/app_services.dart';
import 'widgets/peer_connect_sheet.dart';
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

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.services});

  final AppServices services;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _showingRequest = false;
  Route<dynamic>? _requestRoute;
  String? _requestEndpoint;
  AppServices get services => widget.services;

  @override
  void initState() {
    super.initState();
    services.chatSync.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    services.chatSync.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (!mounted) return;
    if (_requestRoute != null &&
        _requestEndpoint != null &&
        !services.chatSync.requests.any(
          (request) => request.endpointId == _requestEndpoint,
        )) {
      final route = _requestRoute!;
      _requestRoute = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = _navigatorKey.currentState;
        // Let the modal route run its normal pop transition. Removing an
        // active bottom-sheet route directly can tear down its overlay subtree
        // while Flutter is still deactivating its elements.
        if (mounted && route.isCurrent && navigator != null) {
          navigator.pop();
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
    if (_showingRequest || services.chatSync.requests.isEmpty) return;
    _showingRequest = true;
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = _navigatorKey.currentState?.overlay?.context;
      if (!mounted || context == null || services.chatSync.requests.isEmpty) {
        _showingRequest = false;
        return;
      }
      final request = services.chatSync.requests.first;
      _requestEndpoint = request.endpointId;
      final accepted = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          _requestRoute = ModalRoute.of(sheetContext);
          return SafeArea(
            child: SingleChildScrollView(
              child: PeerConnectSheet(
                peerName: request.name,
                verificationCode: request.authenticationToken,
                onConnect: () => Navigator.pop(sheetContext, true),
                onDecline: () => Navigator.pop(sheetContext, false),
              ),
            ),
          );
        },
      );
      _requestRoute = null;
      _requestEndpoint = null;
      if (!mounted) return;
      try {
        if (services.chatSync.requests.any(
          (item) => item.endpointId == request.endpointId,
        )) {
          if (accepted == true) {
            await services.chatSync.acceptConnection(request.endpointId);
          } else {
            await services.chatSync.rejectConnection(request.endpointId);
          }
        }
      } catch (_) {
        /* The session exposes actionable errors to the screen. */
      }
      _showingRequest = false;
      _onSessionChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
