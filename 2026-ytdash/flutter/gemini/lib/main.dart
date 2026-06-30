import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'data/models/test_config.dart';
import 'data/repositories/preference_repository.dart';
import 'data/services/geocoding_service.dart';
import 'data/services/youtube_api_client.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/auth/views/login_view.dart';
import 'ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'ui/features/dashboard/views/home_view.dart';
import 'ui/features/map/view_models/map_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Rule A / §3: Call ensureSemantics() so that stable semantics tree builds for Maestro
  SemanticsBinding.instance.ensureSemantics();

  // Load UI test mode configuration from intent extras
  final testConfig = await TestConfig.load();

  runApp(
    MultiProvider(
      providers: [
        // Configuration
        Provider<TestConfig>.value(value: testConfig),

        // Repositories
        Provider<PreferenceRepository>(create: (_) => PreferenceRepository()),

        // Services
        Provider<YoutubeApiClient>(create: (_) => YoutubeApiClient()),
        Provider<GeocodingService>(create: (_) => GeocodingService()),

        // ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) {
            final vm = AuthViewModel(prefRepository: context.read<PreferenceRepository>());
            vm.init();
            return vm;
          },
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (context) => DashboardViewModel(
            apiClient: context.read<YoutubeApiClient>(),
            prefRepository: context.read<PreferenceRepository>(),
          ),
        ),
        ChangeNotifierProvider<MapViewModel>(
          create: (context) => MapViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'YouTube Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF0000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF0000),
          secondary: Color(0xFF2563EB),
          background: Color(0xFF0F0C20),
          surface: Color(0xFF15102A),
        ),
        useMaterial3: true,
      ),
      home: authViewModel.isAuthenticated ? const HomeView() : const LoginView(),
    );
  }
}
