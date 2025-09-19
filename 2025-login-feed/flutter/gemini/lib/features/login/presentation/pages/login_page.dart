import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_state.dart';
import 'package:flutter_gemini/features/login/presentation/widgets/login_button.dart';
import 'package:flutter_gemini/features/video/presentation/pages/video_list_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Google'),
      ),
      body: Center(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              success: (user) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoListPage(),
                  ),
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const LoginButton(),
              loading: () => const CircularProgressIndicator(),
              success: (_) => const SizedBox(),
              error: (_) => const LoginButton(),
            );
          },
        ),
      ),
    );
  }
}
