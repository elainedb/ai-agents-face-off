import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di.dart';
import '../../../videos/presentation/bloc/videos_bloc.dart';
import '../../../videos/presentation/pages/videos_page.dart';
import '../bloc/auth_bloc.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideosBloc>()..add(const VideosEvent.loadVideos()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.maybeWhen(
            authenticated: (user) {
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
                          radius: 40,
                          backgroundImage: NetworkImage(user.photoUrl!),
                        )
                      else
                        const CircleAvatar(
                          radius: 40,
                          child: Icon(Icons.person, size: 40),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      Builder(
                        builder: (context) => ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<VideosBloc>(),
                                  child: const VideosPage(),
                                ),
                              ),
                            );
                          },
                          child: const Text('Go to Videos'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}
