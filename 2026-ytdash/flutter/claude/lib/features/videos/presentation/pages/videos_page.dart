import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/pages/map_screen.dart';

class VideosPage extends StatelessWidget {
  final User user;

  const VideosPage({super.key, required this.user});

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
                  return BlocProvider.value(
                    value: context.read<VideosBloc>(),
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
                radius: 16,
                backgroundImage: user.hasPhoto
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.hasPhoto ? null : Text(user.name[0]),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user.email,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthEvent.signOut());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _buildError(context, message),
            loaded: (videos, filteredVideos, selectedChannel,
                selectedCountry, sortBy, sortOrder, isRefreshing) {
              return _buildLoaded(
                context,
                videos,
                filteredVideos,
                selectedChannel,
                selectedCountry,
                sortBy,
                sortOrder,
                isRefreshing,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<VideosBloc>()
                  .add(const VideosEvent.loadVideos());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<Video> allVideos,
    List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
    bool isRefreshing,
  ) {
    final bloc = context.read<VideosBloc>();
    final hasActiveFilter = selectedChannel != null ||
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
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Channels'),
                  ),
                  ...bloc.availableChannels.map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (value) {
                  bloc.add(VideosEvent.filterByChannel(value));
                },
              ),
              // Country filter
              DropdownButton<String?>(
                value: selectedCountry,
                hint: const Text('Country'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Countries'),
                  ),
                  ...bloc.availableCountries.map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (value) {
                  bloc.add(VideosEvent.filterByCountry(value));
                },
              ),
              // Sort dropdown
              DropdownButton<String>(
                value: '${sortBy.name}_${sortOrder.name}',
                items: const [
                  DropdownMenuItem(
                    value: 'publishedDate_descending',
                    child: Text('Published (Newest)'),
                  ),
                  DropdownMenuItem(
                    value: 'publishedDate_ascending',
                    child: Text('Published (Oldest)'),
                  ),
                  DropdownMenuItem(
                    value: 'recordingDate_descending',
                    child: Text('Recorded (Newest)'),
                  ),
                  DropdownMenuItem(
                    value: 'recordingDate_ascending',
                    child: Text('Recorded (Oldest)'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  final parts = value.split('_');
                  final sb = SortBy.values
                      .firstWhere((e) => e.name == parts[0]);
                  final so = SortOrder.values
                      .firstWhere((e) => e.name == parts[1]);
                  bloc.add(VideosEvent.sortVideos(sb, so));
                },
              ),
              if (hasActiveFilter)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                  onPressed: () {
                    bloc.add(const VideosEvent.clearFilters());
                  },
                ),
              // Refresh button
              isRefreshing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        bloc.add(const VideosEvent.refreshVideos());
                      },
                    ),
            ],
          ),
        ),
        // Video count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${filteredVideos.length} of ${allVideos.length} videos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Video list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(const VideosEvent.refreshVideos());
              // Wait for state change
              await bloc.stream.firstWhere(
                  (s) => s is VideosLoaded && !s.isRefreshing ||
                      s is! VideosLoaded);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (_, a) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, a, b) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                // Play button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.red,
                  onPressed: () => _launchVideo(video.id),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              video.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Channel
            Text(
              video.channelName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            // Dates
            Text('Published: ${dateFormat.format(video.publishedAt)}'),
            if (video.hasRecordingDate)
              Text(
                  'Recorded: ${dateFormat.format(video.recordingDate!)}'),
            // Location
            if (video.hasLocation)
              Text('Location: ${video.locationText}'),
            if (video.hasCoordinates)
              Text(
                'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            // Tags
            if (video.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  ...video.tags.take(3).map(
                        (tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  if (video.tags.length > 3)
                    Chip(
                      label: Text('+${video.tags.length - 3} more',
                          style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    // Try deep link first
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    // Fall back to browser
    final browserUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');
    await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
  }
}
