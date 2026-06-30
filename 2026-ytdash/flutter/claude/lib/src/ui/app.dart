import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'external_link_overlay.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class YtDashApp extends StatelessWidget {
  const YtDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ytdash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const _RootGate(),
      // Mount the external-link banner above every route (list + map).
      builder: (context, child) => Stack(
        children: [
          ?child,
          const ExternalLinkOverlay(),
        ],
      ),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn =
        ref.watch(authControllerProvider.select((s) => s.isSignedIn));
    return signedIn ? const HomeScreen() : const LoginScreen();
  }
}
