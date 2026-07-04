import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authError = ref.watch(authErrorProvider);

    return Scaffold(
      body: Semantics(
        identifier: 'screen_login',
        container: true,
        explicitChildNodes: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (authError != null)
                Semantics(
                  identifier: 'login_error_message',
                  child: Text(
                    authError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              Semantics(
                identifier: 'login_google_button',
                button: true,
                child: ElevatedButton(
                  onPressed: () async {
                    ref.read(authErrorProvider.notifier).state = null;
                    final authRepo = ref.read(authRepositoryProvider);
                    final result = await authRepo.signIn();
                    if (result.success) {
                      ref.read(authStateProvider.notifier).state = true;
                    } else {
                      ref.read(authErrorProvider.notifier).state = result.error;
                    }
                  },
                  child: const Text('Sign in with Google'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
