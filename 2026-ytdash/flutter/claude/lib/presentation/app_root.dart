import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// The auth gate: login vs. home. This is `MaterialApp.home`, i.e. the bottom of the Navigator
/// stack — the global external-open banner lives in `ExternalLaunchBanner` instead (wired via
/// `MaterialApp.builder` in `main.dart`), because a widget here would be covered by any route
/// pushed on top of it (e.g. the map screen), which would hide `external_open_url` from the map's
/// "open in YouTube" action (AC-MAP-03).
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return switch (authState) {
      AuthLoggedIn() => const HomeScreen(),
      AuthLoggedOut() => const LoginScreen(),
    };
  }
}
