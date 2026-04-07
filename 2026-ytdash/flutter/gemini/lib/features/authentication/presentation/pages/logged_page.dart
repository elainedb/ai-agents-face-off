import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_event.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/pages/videos_page.dart';
import 'package:ytdash_flutter_gemini/di.dart';

class LoggedPage extends StatelessWidget {
  final User user;

  const LoggedPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEvent.signOut());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.hasPhoto)
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl!),
                radius: 50,
              )
            else
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<VideosBloc>(
                      create: (_) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
                      child: const VideosPage(),
                    ),
                  ),
                );
              },
              child: const Text('Go to Videos'),
            ),
          ],
        ),
      ),
    );
  }
}

