
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';

class LoggedScreen extends StatelessWidget {
  const LoggedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<LoginBloc>().add(const LoginEvent.signOut());
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
