import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';

class VideosPage extends StatelessWidget {
  final User user;

  const VideosPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return VideosView(user: user);
  }
}

class VideosView extends StatefulWidget {
  final User user;

  const VideosView({super.key, required this.user});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  @override
  void initState() {
    super.initState();
    context.read<VideosBloc>().add(const VideosEvent.loadVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos'),
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const AuthEvent.signOut());
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: state.maybeWhen(
                        loading: () => const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Logging out...'),
                          ],
                        ),
                        orElse: () => const Text('Logout'),
                      ),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.user.hasPhoto
                      ? CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(widget.user.photoUrl!),
                        )
                      : const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        child: BlocBuilder<VideosBloc, VideosState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: Text('Welcome! Loading videos...'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (videos) => _buildVideosList(videos),
              error: (message) => _buildErrorView(message),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideosList(List<Video> videos) {
    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No videos found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
      },
      child: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildVideoTile(video);
        },
      ),
    );
  }

  Widget _buildVideoTile(Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(video.publishedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: video.thumbnailUrl,
            width: 120,
            height: 68,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 120,
              height: 68,
              color: Colors.grey[300],
              child: const Icon(Icons.play_arrow, size: 30),
            ),
            errorWidget: (context, url, error) => Container(
              width: 120,
              height: 68,
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 30),
            ),
          ),
        ),
        title: Text(
          video.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              video.channelName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _launchVideo(video.id),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading videos',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<VideosBloc>().add(const VideosEvent.loadVideos());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    // Try YouTube app first, then fallback to web browser
    final youtubeAppUrl = 'youtube://watch?v=$videoId';
    final youtubeWebUrl = 'https://www.youtube.com/watch?v=$videoId';

    try {
      // Try YouTube app first
      final youtubeAppUri = Uri.parse(youtubeAppUrl);
      if (await canLaunchUrl(youtubeAppUri)) {
        await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to web browser
      final youtubeWebUri = Uri.parse(youtubeWebUrl);

      // Try external application first
      if (await canLaunchUrl(youtubeWebUri)) {
        try {
          await launchUrl(youtubeWebUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          // If external app fails, try platform default
          try {
            await launchUrl(youtubeWebUri, mode: LaunchMode.platformDefault);
            return;
          } catch (e2) {
            // Final fallback to in-app browser
            await launchUrl(youtubeWebUri, mode: LaunchMode.inAppWebView);
            return;
          }
        }
      }

      // If both fail, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch video: $videoId'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Copy Link',
              onPressed: () {
                // In a real app, you'd copy to clipboard here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Link: $youtubeWebUrl'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}