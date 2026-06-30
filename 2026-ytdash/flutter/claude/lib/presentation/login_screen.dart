import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import 'widgets/test_id.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return TestId(
      'screen_login',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('ytdash — Sign in')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.video_library, size: 72),
                const SizedBox(height: 24),
                const Text(
                  'YouTube Dashboard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TestId(
                  'login_google_button',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: auth.busy ? null : () => context.read<AuthController>().signIn(),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ),
                const SizedBox(height: 16),
                if (auth.busy)
                  const TestId(
                    'loading_indicator',
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (auth.errorMessage != null && !auth.signedIn)
                  TestId(
                    'login_error_message',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
