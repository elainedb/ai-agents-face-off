import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_event.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_state.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/pages/map_screen.dart';

class VideosPage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const VideosPage({super.key, required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  final bloc = context.read<VideosBloc>();
                  return BlocProvider.value(
                    value: bloc,
                    child: const MapScreen(),
                  );
                }),
              );
            },
          ),
          PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: user.hasPhoto
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.hasPhoto ? null : Text(user.name[0]),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user.email,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) {
              if (value == 'logout') onSignOut();
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
                  Text(message, textAlign: TextAlign.center),
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
              return _buildLoadedContent(
                context,
                videos: videos,
                filteredVideos: filteredVideos,
                selectedChannel: selectedChannel,
                selectedCountry: selectedCountry,
                sortBy: sortBy,
                sortOrder: sortOrder,
                isRefreshing: isRefreshing,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context, {
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
    required bool isRefreshing,
  }) {
    final bloc = context.read<VideosBloc>();
    final hasActiveFilters = selectedChannel != null ||
        selectedCountry != null ||
        sortBy != SortBy.publishedDate ||
        sortOrder != SortOrder.descending;

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Channel filter
              DropdownButton<String?>(
                value: selectedChannel,
                hint: const Text('Channel'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Channels')),
                  ...bloc.availableChannels.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (value) =>
                    bloc.add(VideosEvent.filterByChannel(value)),
              ),
              // Country filter
              DropdownButton<String?>(
                value: selectedCountry,
                hint: const Text('Country'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Countries')),
                  ...bloc.availableCountries.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (value) =>
                    bloc.add(VideosEvent.filterByCountry(value)),
              ),
              // Sort dropdown
              DropdownButton<String>(
                value: '${sortBy.name}_${sortOrder.name}',
                items: const [
                  DropdownMenuItem(
                      value: 'publishedDate_descending',
                      child: Text('Published (Newest)')),
                  DropdownMenuItem(
                      value: 'publishedDate_ascending',
                      child: Text('Published (Oldest)')),
                  DropdownMenuItem(
                      value: 'recordingDate_descending',
                      child: Text('Recorded (Newest)')),
                  DropdownMenuItem(
                      value: 'recordingDate_ascending',
                      child: Text('Recorded (Oldest)')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  final parts = value.split('_');
                  final sb = SortBy.values.firstWhere((e) => e.name == parts[0]);
                  final so =
                      SortOrder.values.firstWhere((e) => e.name == parts[1]);
                  bloc.add(VideosEvent.sortVideos(sb, so));
                },
              ),
              if (hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                  onPressed: () => bloc.add(const VideosEvent.clearFilters()),
                ),
              // Refresh
              isRefreshing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () =>
                          bloc.add(const VideosEvent.refreshVideos()),
                    ),
            ],
          ),
        ),
        // Video count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Showing ${filteredVideos.length} of ${videos.length} videos',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 4),
        // Video list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(const VideosEvent.refreshVideos());
              // Wait for state to change from refreshing
              await bloc.stream.firstWhere((s) {
                if (s is VideosLoaded) return !s.isRefreshing;
                return true;
              });
            },
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) =>
                  _VideoCard(video: filteredVideos[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 90,
                child: Stack(
                  children: [
                    Image.network(
                      video.thumbnailUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          width: 120,
                          height: 90,
                          child: const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        width: 120,
                        height: 90,
                        child: const Icon(Icons.error),
                      ),
                    ),
                    // Play button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _launchVideo(video.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(video.channelName,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('Published: ${dateFormat.format(video.publishedAt)}',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (video.hasRecordingDate)
                    Text(
                        'Recorded: ${dateFormat.format(video.recordingDate!)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  if (video.hasLocation)
                    Text(video.locationText,
                        style: Theme.of(context).textTheme.bodySmall),
                  if (video.hasCoordinates)
                    Text(
                        'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  if (video.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildTags(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final displayTags = video.tags.take(3).toList();
    final remaining = video.tags.length - 3;

    return Wrap(
      spacing: 4,
      children: [
        ...displayTags.map((tag) => Chip(
              label: Text(tag, style: const TextStyle(fontSize: 10)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            )),
        if (remaining > 0)
          Text('+$remaining more',
              style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
