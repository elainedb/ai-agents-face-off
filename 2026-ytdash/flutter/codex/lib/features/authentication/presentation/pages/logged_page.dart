import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../../videos/presentation/bloc/videos_bloc.dart';
import '../../../videos/presentation/pages/videos_page.dart';
import '../../domain/entities/user.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideosBloc>(
      create: (_) => sl<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: VideosPage(user: user),
    );
  }
}
