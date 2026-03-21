import 'package:cached_network_image/cached_network_image.dart';
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
  final VoidCallback onLogout;

  const VideosPage({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Dashboard'),
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
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('Logout (${user.email})'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: user.hasPhoto
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl!),
                      radius: 16,
                    )
                  : CircleAvatar(
                      radius: 16,
                      child: Text(user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?'),
                    ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () =>
                const Center(child: CircularProgressIndicator()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
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
            loaded: (videos, filteredVideos, selectedChannel,
                selectedCountry, sortBy, sortOrder, isRefreshing) {
              final bloc = context.read<VideosBloc>();
              return Column(
                children: [
                  _buildToolbar(context, bloc, selectedChannel,
                      selectedCountry, sortBy, sortOrder, isRefreshing),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing ${filteredVideos.length} of ${videos.length} videos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
                        itemBuilder: (context, index) =>
                            _buildVideoCard(context, filteredVideos[index]),
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

  Widget _buildToolbar(
    BuildContext context,
    VideosBloc bloc,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
    bool isRefreshing,
  ) {
    final hasActiveFilter = selectedChannel != null ||
        selectedCountry != null ||
        sortBy != SortBy.publishedDate ||
        sortOrder != SortOrder.descending;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DropdownButton<String?>(
            hint: const Text('Channel'),
            value: selectedChannel,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Channels')),
              ...bloc.availableChannels
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (value) => bloc.add(VideosEvent.filterByChannel(value)),
          ),
          DropdownButton<String?>(
            hint: const Text('Country'),
            value: selectedCountry,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Countries')),
              ...bloc.availableCountries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (value) => bloc.add(VideosEvent.filterByCountry(value)),
          ),
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
              final sb = SortBy.values.firstWhere((e) => e.name == parts[0]);
              final so = SortOrder.values.firstWhere((e) => e.name == parts[1]);
              bloc.add(VideosEvent.sortVideos(sb, so));
            },
          ),
          if (hasActiveFilter)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear filters',
              onPressed: () =>
                  bloc.add(const VideosEvent.clearFilters()),
            ),
          if (isRefreshing)
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
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  child: FloatingActionButton.small(
                    heroTag: 'play_${video.id}',
                    backgroundColor: Colors.red,
                    onPressed: () => _launchVideo(video.id),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              video.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              video.channelName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Published: ${dateFormat.format(video.publishedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (video.hasRecordingDate)
              Text(
                'Recorded: ${dateFormat.format(video.recordingDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (video.hasLocation)
              Text(
                'Location: ${video.locationText}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (video.hasCoordinates)
              Text(
                'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (video.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  ...video.tags.take(3).map((tag) => Chip(
                        label: Text(tag,
                            style: const TextStyle(fontSize: 10)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )),
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
