import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    widget.authService.addListener(_onAuthStatusChanged);
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthStatusChanged);
    super.dispose();
  }

  void _onAuthStatusChanged() {
    if (widget.authService.status == AuthStatus.authenticated) {
      widget.onLoginSuccess();
    }
    if (mounted) {
      setState(() {
        _isLoggingIn = widget.authService.status == AuthStatus.authenticating;
      });
    }
  }

  Future<void> _handleLogin() async {
    await widget.authService.login();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_login',
      container: true,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.video_library_rounded,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'YT Dash',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Premium YouTube Feed Aggregator',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (_isLoggingIn)
                      Center(
                        child: Semantics(
                          identifier: 'loading_indicator',
                          container: true,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                          ),
                        ),
                      )
                    else
                      Semantics(
                        identifier: 'login_google_button',
                        container: true,
                        button: true,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 24,
                              color: Colors.blue,
                            ),
                          ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (widget.authService.errorMessage != null &&
                        (widget.authService.status == AuthStatus.unauthorizedError ||
                            widget.authService.status == AuthStatus.failureError)) ...[
                      const SizedBox(height: 24),
                      Semantics(
                        identifier: 'login_error_message',
                        container: true,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.authService.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
