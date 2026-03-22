import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_state.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/pages/map_screen.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BlocProvider.value(
                  value: context.read<VideosBloc>(),
                  child: const MapScreen(),
                )),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeMap(
                authenticated: (s) {
                  return PopupMenuButton(
                    icon: s.user.hasPhoto
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(s.user.photoUrl!),
                            radius: 16,
                          )
                        : const Icon(Icons.account_circle),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<AuthBloc>().add(const AuthEvent.signOut());
                      }
                    },
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
            error: (e) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            loaded: (s) => _buildLoaded(context, s),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, VideosLoaded state) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Column(
      children: [
        _buildFilters(context, state),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
            },
            child: ListView.builder(
              itemCount: state.filteredVideos.length,
              itemBuilder: (context, index) {
                final video = state.filteredVideos[index];
                return _buildVideoCard(context, video, dateFormat);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, VideosLoaded state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  key: ValueKey(state.selectedChannel),
                  decoration: const InputDecoration(labelText: 'Channel', isDense: true),
                  initialValue: state.selectedChannel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Channels')),
                    ...state.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  ],
                  onChanged: (val) => context.read<VideosBloc>().add(VideosEvent.filterByChannel(val)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  key: ValueKey(state.selectedCountry),
                  decoration: const InputDecoration(labelText: 'Country', isDense: true),
                  initialValue: state.selectedCountry,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Countries')),
                    ...state.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  ],
                  onChanged: (val) => context.read<VideosBloc>().add(VideosEvent.filterByCountry(val)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('${state.sortBy.name}_${state.sortOrder.name}'),
                  decoration: const InputDecoration(labelText: 'Sort By', isDense: true),
                  initialValue: '${state.sortBy.name}_${state.sortOrder.name}',
                  items: [
                    DropdownMenuItem(value: '${SortBy.publishedDate.name}_${SortOrder.descending.name}', child: const Text('Published Date (Newest)')),
                    DropdownMenuItem(value: '${SortBy.publishedDate.name}_${SortOrder.ascending.name}', child: const Text('Published Date (Oldest)')),
                    DropdownMenuItem(value: '${SortBy.recordingDate.name}_${SortOrder.descending.name}', child: const Text('Recording Date (Newest)')),
                    DropdownMenuItem(value: '${SortBy.recordingDate.name}_${SortOrder.ascending.name}', child: const Text('Recording Date (Oldest)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final parts = val.split('_');
                      final sortBy = SortBy.values.firstWhere((e) => e.name == parts[0]);
                      final sortOrder = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                      context.read<VideosBloc>().add(VideosEvent.sortVideos(sortBy, sortOrder));
                    }
                  },
                ),
              ),
              if (state.selectedChannel != null || state.selectedCountry != null || state.sortBy != SortBy.publishedDate || state.sortOrder != SortOrder.descending) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.read<VideosBloc>().add(const VideosEvent.clearFilters()),
                  child: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video, DateFormat dateFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
              ),
              Positioned.fill(
                child: Center(
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.red,
                    onPressed: () => _launchVideo(video.id),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(video.channelName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Published: ${dateFormat.format(video.publishedAt)}', style: Theme.of(context).textTheme.bodySmall),
                    if (video.hasRecordingDate)
                      Text('Recorded: ${dateFormat.format(video.recordingDate!)}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (video.hasLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(video.locationText, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ],
                if (video.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...video.tags.take(3).map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )),
                      if (video.tags.length > 3)
                        Chip(
                          label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )
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
    final Uri appUri = Uri.parse('youtube://watch?v=$videoId');
    final Uri webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Failed to launch
    }
  }
}
