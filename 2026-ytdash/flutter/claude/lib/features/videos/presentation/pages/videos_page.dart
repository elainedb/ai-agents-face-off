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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: user.hasPhoto
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.hasPhoto ? null : Text(user.name.isNotEmpty ? user.name[0] : '?'),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthEvent.signOut());
              }
            },
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
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.map(
            initial: (_) =>
                const Center(child: CircularProgressIndicator()),
            loading: (_) =>
                const Center(child: CircularProgressIndicator()),
            loaded: (s) => _buildLoadedContent(context, s),
            error: (s) => _buildErrorContent(context, s.message),
          );
        },
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildLoadedContent(BuildContext context, VideosLoaded state) {
    final bloc = context.read<VideosBloc>();

    return Column(
      children: [
        // Filter/Sort toolbar
        _buildToolbar(context, state, bloc),
        // Video count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        // Video list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(const VideosEvent.refreshVideos());
              // Wait for state to change from refreshing
              await bloc.stream.firstWhere(
                  (s) => s is VideosLoaded && !s.isRefreshing ||
                      s is! VideosLoaded);
            },
            child: ListView.builder(
              itemCount: state.filteredVideos.length,
              itemBuilder: (context, index) =>
                  _buildVideoCard(context, state.filteredVideos[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(
      BuildContext context, VideosLoaded state, VideosBloc bloc) {
    final hasFilters = state.selectedChannel != null ||
        state.selectedCountry != null ||
        state.sortBy != SortBy.publishedDate ||
        state.sortOrder != SortOrder.descending;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Channel filter
          DropdownButton<String?>(
            hint: const Text('Channel'),
            value: state.selectedChannel,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Channels')),
              ...bloc.availableChannels.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (v) =>
                bloc.add(VideosEvent.filterByChannel(v)),
          ),
          // Country filter
          DropdownButton<String?>(
            hint: const Text('Country'),
            value: state.selectedCountry,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Countries')),
              ...bloc.availableCountries.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (v) =>
                bloc.add(VideosEvent.filterByCountry(v)),
          ),
          // Sort dropdown
          DropdownButton<String>(
            value: '${state.sortBy.name}_${state.sortOrder.name}',
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
            onChanged: (v) {
              if (v == null) return;
              final parts = v.split('_');
              final sortBy = parts[0] == 'publishedDate'
                  ? SortBy.publishedDate
                  : SortBy.recordingDate;
              final sortOrder = parts[1] == 'descending'
                  ? SortOrder.descending
                  : SortOrder.ascending;
              bloc.add(VideosEvent.sortVideos(sortBy, sortOrder));
            },
          ),
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear filters',
              onPressed: () =>
                  bloc.add(const VideosEvent.clearFilters()),
            ),
          if (state.isRefreshing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  bloc.add(const VideosEvent.refreshVideos()),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              video.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Channel name
            Text(
              video.channelName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            // Published date
            Text(
              'Published: ${dateFormat.format(video.publishedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // Recording date
            if (video.hasRecordingDate)
              Text(
                'Recorded: ${dateFormat.format(video.recordingDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            // Location
            if (video.hasLocation)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(video.locationText,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            if (video.hasCoordinates)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            // Tags
            if (video.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ...video.tags.take(3).map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )),
                    if (video.tags.length > 3)
                      Chip(
                        label: Text('+${video.tags.length - 3} more',
                            style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            // Play button
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                heroTag: 'play_${video.id}',
                backgroundColor: Colors.red,
                onPressed: () => _launchVideo(video.id),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }
}
