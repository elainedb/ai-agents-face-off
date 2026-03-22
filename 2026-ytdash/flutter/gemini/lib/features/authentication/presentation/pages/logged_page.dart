import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_gemini/di.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/pages/videos_page.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/user.dart';

class LoggedPage extends StatelessWidget {
  final User user;

  const LoggedPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEvent.signOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.hasPhoto)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoUrl!),
              )
            else
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<VideosBloc>()
                        ..add(const VideosEvent.loadVideos()),
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
