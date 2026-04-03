import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../domain/entities/user.dart';
import '../../../videos/presentation/bloc/videos_bloc.dart';
import '../../../videos/presentation/pages/videos_page.dart';
import '../bloc/auth_bloc.dart';

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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
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
