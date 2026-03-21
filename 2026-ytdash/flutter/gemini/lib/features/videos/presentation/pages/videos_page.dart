import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import 'map_screen.dart';
import '../../domain/entities/video.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              final videosBloc = context.read<VideosBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: videosBloc,
                    child: const MapScreen(),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                authenticated: (user) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<AuthBloc>().add(const AuthEvent.signOut());
                      }
                    },
                    icon: user.hasPhoto
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl!),
                            radius: 16,
                          )
                        : const Icon(Icons.account_circle),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (s) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.message, style: const TextStyle(color: Colors.red)),
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
            loaded: (loadedState) {
              return Column(
                children: [
                  _buildToolbar(context, state),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<VideosBloc>();
                        bloc.add(const VideosEvent.refreshVideos());
                        await bloc.stream.firstWhere((state) => state.maybeMap(
                          loaded: (s) => !s.isRefreshing,
                          error: (_) => true,
                          orElse: () => false,
                        ));
                      },
                      child: ListView.builder(
                        itemCount: loadedState.filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = loadedState.filteredVideos[index];
                          return _buildVideoCard(video);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, VideosState state) {
    return state.maybeMap(
      loaded: (loadedState) {
        final hasFilters = loadedState.selectedChannel != null || loadedState.selectedCountry != null || loadedState.sortBy != SortBy.publishedDate || loadedState.sortOrder != SortOrder.descending;

        return Container(
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      hint: const Text('Channel'),
                      value: loadedState.selectedChannel,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Channels')),
                        ...loadedState.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (val) {
                        context.read<VideosBloc>().add(VideosEvent.filterByChannel(val));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      hint: const Text('Country'),
                      value: loadedState.selectedCountry,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Countries')),
                        ...loadedState.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (val) {
                        context.read<VideosBloc>().add(VideosEvent.filterByCountry(val));
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: '${loadedState.sortBy.name}_${loadedState.sortOrder.name}',
                      items: const [
                        DropdownMenuItem(value: 'publishedDate_descending', child: Text('Published: Newest')),
                        DropdownMenuItem(value: 'publishedDate_ascending', child: Text('Published: Oldest')),
                        DropdownMenuItem(value: 'recordingDate_descending', child: Text('Recorded: Newest')),
                        DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Recorded: Oldest')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          final parts = val.split('_');
                          final by = SortBy.values.firstWhere((e) => e.name == parts[0]);
                          final order = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                          context.read<VideosBloc>().add(VideosEvent.sortVideos(by, order));
                        }
                      },
                    ),
                  ),
                  if (hasFilters) ...[
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        context.read<VideosBloc>().add(const VideosEvent.clearFilters());
                      },
                      tooltip: 'Clear filters',
                    )
                  ],
                  if (loadedState.isRefreshing)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                      },
                      tooltip: 'Refresh',
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Showing ${loadedState.filteredVideos.length} of ${loadedState.videos.length} videos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildVideoCard(Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              FloatingActionButton(
                backgroundColor: Colors.red,
                mini: true,
                onPressed: () => _launchVideo(video.id),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video.channelName,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Published: ${dateFormat.format(video.publishedAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (video.hasRecordingDate) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.videocam, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Recorded: ${dateFormat.format(video.recordingDate!)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
                if (video.hasLocation || video.hasCoordinates) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            if (video.hasLocation) video.locationText,
                            if (video.hasCoordinates) '(${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)})'
                          ].join(' '),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                if (video.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      ...video.tags.take(3).map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )),
                      if (video.tags.length > 3)
                        Chip(
                          label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUrl = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}