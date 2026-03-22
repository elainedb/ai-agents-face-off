import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../../videos/presentation/bloc/videos_bloc.dart';
import '../../../videos/presentation/pages/videos_page.dart';
import '../../domain/entities/app_user.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideosBloc>(
      create: (_) => getIt<VideosBloc>()..add(const LoadVideos()),
      child: VideosPage(user: user),
    );
  }
}
