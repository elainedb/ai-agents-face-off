import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'widgets/test_id.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return IdNode(
      'screen_login',
      child: Scaffold(
        appBar: AppBar(title: const Text('ytdash — Sign in')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill, size: 72, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'YouTube Dashboard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                IdNode(
                  'login_google_button',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AppState>().signIn(),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ),
                const SizedBox(height: 16),
                if (appState.loginError != null)
                  IdText(
                    'login_error_message',
                    text: appState.loginError!,
                    child: Text(
                      appState.loginError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
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
