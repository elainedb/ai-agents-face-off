import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/test_config.dart';
import 'core/di/injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/screens/app_navigator.dart';
import 'presentation/bloc/video/video_bloc.dart';
import 'presentation/bloc/video/video_event.dart';
import 'presentation/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  
  await TestConfig.init();
  await configureDependencies();
  
  if (!TestConfig.instance.uiTestMode) {
    try {
      debugPrint('Initializing Firebase...');
      await Firebase.initializeApp();
      debugPrint('Firebase initialized.');
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  } else {
    debugPrint('Skipping Firebase init in uiTestMode');
  }

  debugPrint('Calling runApp...');
  runApp(const MyApp());
  debugPrint('runApp called.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<VideoBloc>(
          create: (_) => getIt<VideoBloc>()..add(FetchVideos()),
        ),
      ],
      child: MaterialApp(
        title: 'YouTube Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const AppNavigator(),
        routes: {
          '/map': (context) => const MapScreen(),
        },
      ),
    );
  }
}
