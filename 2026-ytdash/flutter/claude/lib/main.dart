import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_shell.dart';
import 'core/providers.dart';
import 'core/test_config.dart';
import 'domain/auth/auth_state.dart';
import 'presentation/auth/auth_notifier.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensures the semantics tree is built from the first frame, so Maestro (which drives the app
  // via accessibility/resource ids) can see it immediately (cross-framework-setup.md §A).
  SemanticsBinding.instance.ensureSemantics();

  final testConfig = await TestConfig.load();

  runApp(
    ProviderScope(
      overrides: [testConfigProvider.overrideWithValue(testConfig)],
      child: const YtdashApp(),
    ),
  );
}

class YtdashApp extends StatelessWidget {
  const YtdashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ytdash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) =>
          AppShell(child: child ?? const SizedBox.shrink()),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return switch (auth) {
      AuthSignedIn() => const HomeScreen(),
      _ => const LoginScreen(),
    };
  }
}
