import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_gemini/di.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/pages/videos_page.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: const VideosPage(),
    );
  }
}
