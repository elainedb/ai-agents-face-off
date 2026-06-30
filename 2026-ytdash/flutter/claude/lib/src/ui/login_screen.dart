import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';
import '../state/providers.dart';
import 'identified.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final signingIn = auth.status == AuthStatus.signingIn;

    return IdentifiedScope(
      'screen_login',
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ytdash',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('YouTube Dashboard'),
                  const SizedBox(height: 32),
                  if (signingIn)
                    Identified(
                      'loading_indicator',
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Identified(
                      'login_google_button',
                      button: true,
                      label: 'Sign in with Google',
                      onTap: () =>
                          ref.read(authControllerProvider.notifier).signIn(),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                        onPressed: () =>
                            ref.read(authControllerProvider.notifier).signIn(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (auth.status == AuthStatus.error &&
                      auth.errorMessage != null)
                    Identified(
                      'login_error_message',
                      label: auth.errorMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
