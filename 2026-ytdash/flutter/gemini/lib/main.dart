import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'services/api_service.dart';
import 'services/cache_service.dart';
import 'services/test_config.dart';
import 'services/auth_service.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call ensureSemantics as mandated for Maestro testing
  SemanticsBinding.instance.ensureSemantics();

  // Load the test config from launch intent extras
  final config = await TestConfig.load();

  // Default values or overrides from intent extras
  final String apiBaseUrl = config.apiBaseUrl ?? 'https://www.googleapis.com';
  
  // Real API key fallback if launch extra is not provided
  final String apiKey = config.apiKey ?? 'YOUR_YOUTUBE_API_KEY';

  final authService = AuthService(config: config);
  final apiService = ApiService(apiBaseUrl: apiBaseUrl, apiKey: apiKey);
  final cacheService = CacheService();
  final appState = AppStateNotifier(
    apiService: apiService,
    cacheService: cacheService,
    config: config,
  );

  runApp(MyApp(
    authService: authService,
    appState: appState,
  ));
}

class MyApp extends StatefulWidget {
  final AuthService authService;
  final AppStateNotifier appState;

  const MyApp({
    super.key,
    required this.authService,
    required this.appState,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppScreen { login, home, map }

class _MyAppState extends State<MyApp> {
  AppScreen _currentScreen = AppScreen.login;

  @override
  void initState() {
    super.initState();
    widget.authService.addListener(_onAuthChanged);
    widget.appState.addListener(_onAppStateChanged);
    
    // Check initial auth state
    if (widget.authService.isAuthenticated) {
      _currentScreen = AppScreen.home;
    } else {
      _currentScreen = AppScreen.login;
    }
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthChanged);
    widget.appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        if (widget.authService.isAuthenticated) {
          _currentScreen = AppScreen.home;
        } else {
          _currentScreen = AppScreen.login;
        }
      });
    }
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _buildActiveScreen(),
            _buildGlobalCapturedUrlBanner(),
            _buildGlobalErrorBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveScreen() {
    switch (_currentScreen) {
      case AppScreen.login:
        return LoginScreen(
          authService: widget.authService,
          onLoginSuccess: () {
            setState(() {
              _currentScreen = AppScreen.home;
            });
          },
        );
      case AppScreen.home:
        return HomeScreen(
          appState: widget.appState,
          authService: widget.authService,
          onNavigateToMap: () {
            setState(() {
              _currentScreen = AppScreen.map;
            });
          },
          onLogout: () {
            setState(() {
              _currentScreen = AppScreen.login;
            });
          },
        );
      case AppScreen.map:
        return MapScreen(
          appState: widget.appState,
          onBack: () {
            setState(() {
              _currentScreen = AppScreen.home;
            });
          },
        );
    }
  }

  Widget _buildGlobalCapturedUrlBanner() {
    final state = widget.appState;
    if (state.capturedUrl == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Semantics(
        identifier: 'external_open_url',
        container: true,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15803D), // Premium Green
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.capturedUrl!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => state.clearCapturedUrl(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalErrorBanner() {
    final state = widget.appState;
    if (state.externalOpenError == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Semantics(
        identifier: 'external_open_error',
        container: true,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB91C1C), // Premium Red
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.externalOpenError!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => state.clearExternalOpenError(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
