import 'dart:async';
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
              loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) =>
                _buildVideosContent(videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder),
              error: (message) => _buildErrorView(message),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideosContent(
    List<Video> allVideos,
    List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    return Column(
      children: [
        _buildFilterSortBar(selectedChannel, selectedCountry, sortBy, sortOrder),
        _buildVideoCount(allVideos.length, filteredVideos.length, selectedChannel, selectedCountry),
        Expanded(
          child: _buildVideosList(filteredVideos),
        ),
      ],
    );
  }

  Widget _buildFilterSortBar(
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    final videosBloc = context.read<VideosBloc>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Filter by Channel
          Expanded(
            child: PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tv, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    selectedChannel ?? 'All Channels',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
              onSelected: (value) {
                if (value.isEmpty) {
                  context.read<VideosBloc>().add(const VideosEvent.filterByChannel(null));
                } else {
                  context.read<VideosBloc>().add(VideosEvent.filterByChannel(value));
                }
              },
              itemBuilder: (context) {
                final channels = videosBloc.availableChannels;
                return [
                  const PopupMenuItem<String>(
                    value: '',
                    child: Text('All Channels', style: TextStyle(fontSize: 12)),
                  ),
                  ...channels.map((channel) => PopupMenuItem<String>(
                    value: channel,
                    child: Text(channel, style: const TextStyle(fontSize: 12)),
                  )),
                ];
              },
            ),
          ),
          const SizedBox(width: 8),

          // Filter by Country
          Expanded(
            child: PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    selectedCountry ?? 'All Countries',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
              onSelected: (value) {
                if (value.isEmpty) {
                  context.read<VideosBloc>().add(const VideosEvent.filterByCountry(null));
                } else {
                  context.read<VideosBloc>().add(VideosEvent.filterByCountry(value));
                }
              },
              itemBuilder: (context) {
                final countries = videosBloc.availableCountries;
                return [
                  const PopupMenuItem<String>(
                    value: '',
                    child: Text('All Countries', style: TextStyle(fontSize: 12)),
                  ),
                  ...countries.map((country) => PopupMenuItem<String>(
                    value: country,
                    child: Text(country, style: const TextStyle(fontSize: 12)),
                  )),
                ];
              },
            ),
          ),
          const SizedBox(width: 8),

          // Sort Button
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 16),
                const SizedBox(width: 4),
                Icon(
                  sortOrder == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                ),
              ],
            ),
            onSelected: (value) {
              final parts = value.split('_');
              final newSortBy = parts[0] == 'published' ? SortBy.publishedDate : SortBy.recordingDate;
              final newSortOrder = parts[1] == 'asc' ? SortOrder.ascending : SortOrder.descending;
              context.read<VideosBloc>().add(VideosEvent.sortVideos(newSortBy, newSortOrder));
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'published_desc',
                child: Text('Published Date (Newest)', style: TextStyle(fontSize: 12)),
              ),
              const PopupMenuItem<String>(
                value: 'published_asc',
                child: Text('Published Date (Oldest)', style: TextStyle(fontSize: 12)),
              ),
              const PopupMenuItem<String>(
                value: 'recording_desc',
                child: Text('Recording Date (Newest)', style: TextStyle(fontSize: 12)),
              ),
              const PopupMenuItem<String>(
                value: 'recording_asc',
                child: Text('Recording Date (Oldest)', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          // Clear Filters Button
          if (selectedChannel != null || selectedCountry != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () {
                context.read<VideosBloc>().add(const VideosEvent.clearFilters());
              },
              tooltip: 'Clear Filters',
            ),

          // Refresh Button
          BlocBuilder<VideosBloc, VideosState>(
            buildWhen: (previous, current) {
              if (previous is VideosLoaded && current is VideosLoaded) {
                return previous.isRefreshing != current.isRefreshing;
              }
              return previous.runtimeType != current.runtimeType;
            },
            builder: (context, state) {
              final isRefreshing = state is VideosLoaded ? state.isRefreshing : state is VideosLoading;
              return IconButton(
                icon: isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 16),
                onPressed: isRefreshing
                    ? null
                    : () {
                        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                      },
                tooltip: isRefreshing ? 'Refreshing...' : 'Refresh',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCount(int totalVideos, int filteredVideos, String? selectedChannel, String? selectedCountry) {
    final isFiltered = selectedChannel != null || selectedCountry != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Text(
        isFiltered
          ? 'Showing $filteredVideos of $totalVideos videos'
          : '$totalVideos videos',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
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
        final bloc = context.read<VideosBloc>();
        final completer = Completer<void>();

        // Listen for state changes to complete the refresh
        late StreamSubscription subscription;
        subscription = bloc.stream.listen((state) {
          if (state is VideosLoaded && !state.isRefreshing) {
            subscription.cancel();
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else if (state is VideosError) {
            subscription.cancel();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });

        bloc.add(const VideosEvent.refreshVideos());
        return completer.future;
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
    final publishedDate = dateFormat.format(video.publishedAt);
    final recordingDate = video.recordingDate != null
        ? dateFormat.format(video.recordingDate!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
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
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Channel
                    Row(
                      children: [
                        const Icon(Icons.tv, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.channelName,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Published Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Published: $publishedDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Recording Date (if available)
                    if (recordingDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.videocam, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Recorded: $recordingDate',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Location (if available)
                    if (video.locationText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              video.locationText,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // GPS Coordinates (if available)
                    if (video.hasCoordinates) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.gps_fixed, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Tags (if available)
                    if (video.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: video.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                      if (video.tags.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '+${video.tags.length - 3} more tags',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Tap action
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => _launchVideo(video.id),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
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