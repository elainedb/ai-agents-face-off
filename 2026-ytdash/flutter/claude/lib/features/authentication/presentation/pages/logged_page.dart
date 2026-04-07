import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_claude/di.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/pages/videos_page.dart';

class LoggedPage extends StatelessWidget {
  final User user;

  const LoggedPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: VideosPage(user: user),
    );
  }
}
