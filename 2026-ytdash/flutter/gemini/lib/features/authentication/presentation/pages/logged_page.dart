import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di.dart';
import '../../../../features/videos/presentation/bloc/videos_bloc.dart';
import '../../../../features/videos/presentation/bloc/videos_event.dart';
import '../../../../features/videos/presentation/pages/videos_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.maybeWhen(
            authenticated: (user) => Scaffold(
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
                        radius: 40,
                      ),
                    const SizedBox(height: 16),
                    Text('Name: ${user.name}', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}'),
                    const SizedBox(height: 32),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<VideosBloc>(),
                                  child: const VideosPage(),
                                ),
                              ),
                            );
                          },
                          child: const Text('Go to Videos'),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
            orElse: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
