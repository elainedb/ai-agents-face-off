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
                    ? CachedNetworkImageProvider(user.photoUrl!)
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
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (e) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.message, textAlign: TextAlign.center),
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
            loaded: (s) => _buildLoadedContent(context, s),
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, VideosLoaded state) {
    final bloc = context.read<VideosBloc>();
    final hasActiveFilter = state.selectedChannel != null ||
        state.selectedCountry != null ||
        state.sortBy != SortBy.publishedDate ||
        state.sortOrder != SortOrder.descending;

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              // Channel filter
              DropdownButton<String?>(
                value: state.selectedChannel,
                hint: const Text('Channel'),
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
                value: state.selectedCountry,
                hint: const Text('Country'),
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
              if (hasActiveFilter)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                  onPressed: () =>
                      bloc.add(const VideosEvent.clearFilters()),
                ),
              IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: state.isRefreshing
                    ? null
                    : () =>
                        bloc.add(const VideosEvent.refreshVideos()),
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
              'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
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
              await bloc.stream.firstWhere(
                  (s) => s is VideosLoaded && !s.isRefreshing);
            },
            child: ListView.builder(
              itemCount: state.filteredVideos.length,
              itemBuilder: (context, index) =>
                  _VideoCard(video: state.filteredVideos[index]),
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

  Future<void> _launchVideo() async {
    final deepLink = Uri.parse('youtube://watch?v=${video.id}');
    final webUrl =
        Uri.parse('https://www.youtube.com/watch?v=${video.id}');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

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
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                    // Play button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _launchVideo,
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
                  const SizedBox(height: 2),
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
      runSpacing: 2,
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
}
