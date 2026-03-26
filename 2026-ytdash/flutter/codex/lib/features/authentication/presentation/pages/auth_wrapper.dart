import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../videos/presentation/bloc/videos_bloc.dart';
import '../../../videos/presentation/bloc/videos_event.dart';
import 'logged_page.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import 'login_page.dart';
import '../../../../di.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocProvider(
            create: (_) => sl<VideosBloc>()..add(const LoadVideos()),
            child: LoggedPage(user: state.user),
          );
        }

        if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginPage();
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
