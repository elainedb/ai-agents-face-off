import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_event.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/pages/videos_page.dart';

class LoggedPage extends StatelessWidget {
  final User user;

  const LoggedPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: VideosPage(
        user: user,
        onLogout: () {
          context.read<AuthBloc>().add(const AuthEvent.signOut());
        },
      ),
    );
  }
}
