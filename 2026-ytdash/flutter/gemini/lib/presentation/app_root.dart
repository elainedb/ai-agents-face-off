import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authStateProvider);
    final externalUrl = ref.watch(externalUrlProvider);
    final externalError = ref.watch(externalErrorProvider);

    return Scaffold(
      body: Stack(
        children: [
          isAuthenticated ? const HomeScreen() : const LoginScreen(),
          
          if (externalUrl != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          identifier: 'external_open_url',
                          child: Text(externalUrl, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => ref.read(externalUrlProvider.notifier).state = null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            
          if (externalError != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          identifier: 'external_open_error',
                          child: Text(externalError, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => ref.read(externalErrorProvider.notifier).state = null,
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
