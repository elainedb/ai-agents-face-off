import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/test_config.dart';
import 'features/login/login_screen.dart';
import 'features/home/home_screen.dart';
import 'state/auth_controller.dart';
import 'state/providers.dart';
import 'widgets/external_link_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required so the semantics (accessibility) tree is built for Maestro to select on, even though
  // no human accessibility service is active (cross-framework-setup.md §A).
  SemanticsBinding.instance.ensureSemantics();
  final config = await TestConfig.load();
  runApp(
    ProviderScope(
      overrides: [testConfigProvider.overrideWithValue(config)],
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ExternalLinkBanner(),
          ),
        ],
      ),
      home: const AuthGate(),
    );
  }
}

/// Root gate: shows the login screen or the authenticated home screen based on [AuthState].
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.status == AuthStatus.authenticated) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
