import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/videos_bloc.dart';
import '../../domain/entities/video.dart';
import 'map_screen.dart';

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
              final state = context.read<VideosBloc>().state;
              state.maybeWhen(
                loaded: (videos, _, __, ___, ____, _____, ______) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(videos: videos),
                    ),
                  );
                },
                orElse: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wait for videos to load')),
                  );
                },
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                authenticated: (user) => PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(const AuthEvent.signOut());
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            radius: 15,
                            child: user.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      radius: 15,
                      child: user.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $message'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<VideosBloc>()
                        .add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry,
                sortBy, sortOrder, isRefreshing) {
              return Column(
                children: [
                  _buildFilters(context, state as Loaded),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Showing ${filteredVideos.length} of ${videos.length} videos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<VideosBloc>()
                            .add(const VideosEvent.refreshVideos());
                      },
                      child: ListView.builder(
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          return _VideoCard(video: filteredVideos[index]);
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

  Widget _buildFilters(BuildContext context, Loaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('All Channels'),
                  value: state.selectedChannel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Channels')),
                    ...state.availableChannels.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) => context
                      .read<VideosBloc>()
                      .add(VideosEvent.filterByChannel(val)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('All Countries'),
                  value: state.selectedCountry,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Countries')),
                    ...state.availableCountries.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) => context
                      .read<VideosBloc>()
                      .add(VideosEvent.filterByCountry(val)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<SortOption>(
                  isExpanded: true,
                  value: SortOption(state.sortBy, state.sortOrder),
                  items: [
                    const DropdownMenuItem(
                      value: SortOption(SortBy.publishedDate, SortOrder.descending),
                      child: Text('Published: Newest'),
                    ),
                    const DropdownMenuItem(
                      value: SortOption(SortBy.publishedDate, SortOrder.ascending),
                      child: Text('Published: Oldest'),
                    ),
                    const DropdownMenuItem(
                      value: SortOption(SortBy.recordingDate, SortOrder.descending),
                      child: Text('Recording: Newest'),
                    ),
                    const DropdownMenuItem(
                      value: SortOption(SortBy.recordingDate, SortOrder.ascending),
                      child: Text('Recording: Oldest'),
                    ),
                  ],
                  onChanged: (opt) {
                    if (opt != null) {
                      context.read<VideosBloc>().add(
                          VideosEvent.sortVideos(opt.sortBy, opt.sortOrder));
                    }
                  },
                ),
              ),
              if (state.selectedChannel != null ||
                  state.selectedCountry != null ||
                  state.sortBy != SortBy.publishedDate ||
                  state.sortOrder != SortOrder.descending)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => context
                      .read<VideosBloc>()
                      .add(const VideosEvent.clearFilters()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SortOption {
  final SortBy sortBy;
  final SortOrder sortOrder;

  const SortOption(this.sortBy, this.sortOrder);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOption &&
          runtimeType == other.runtimeType &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => sortBy.hashCode ^ sortOrder.hashCode;
}

class _VideoCard extends StatelessWidget {
  final Video video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.red,
                  onPressed: () => _launchVideo(video.id),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
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
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video.channelName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Published: ${dateFormat.format(video.publishedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (video.hasRecordingDate) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.videocam, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Recorded: ${dateFormat.format(video.recordingDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (video.hasLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          video.locationText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
                if (video.hasCoordinates) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text(
                      '${video.latitude?.toStringAsFixed(4)}, ${video.longitude?.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ],
                if (video.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...video.tags.take(3).map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          )),
                      if (video.tags.length > 3)
                        Chip(
                          label: Text(
                            '+${video.tags.length - 3} more',
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final youtubeDeepLink = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
    final youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      if (await canLaunchUrl(youtubeDeepLink)) {
        await launchUrl(youtubeDeepLink, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(youtubeWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch video: $e');
    }
  }
}
