import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import 'map_screen.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_event.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              final state = context.read<VideosBloc>().state;
              if (state is VideosLoaded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(videos: state.filteredVideos),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEvent.signOut());
            },
          )
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is VideosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VideosError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is VideosLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideosLoaded state) {
    final availableChannels = state.videos.map((e) => e.channelName).toSet().toList()..sort();
    final availableCountries = state.videos.map((e) => e.country).whereType<String>().toSet().toList()..sort();

    return Column(
      children: [
        _buildFilters(context, state, availableChannels, availableCountries),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing ${state.filteredVideos.length} of ${state.videos.length} videos'),
              if (state.isRefreshing)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
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
                return _buildVideoCard(context, state.filteredVideos[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, VideosLoaded state, List<String> channels, List<String> countries) {
    bool hasFilters = state.selectedChannel != null || state.selectedCountry != null || 
        state.sortBy != SortBy.publishedDate || state.sortOrder != SortOrder.descending;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Channel'),
                  value: state.selectedChannel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Channels')),
                    ...channels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) => context.read<VideosBloc>().add(VideosEvent.filterByChannel(val)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Country'),
                  value: state.selectedCountry,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Countries')),
                    ...countries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) => context.read<VideosBloc>().add(VideosEvent.filterByCountry(val)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: '${state.sortBy.name}_${state.sortOrder.name}',
                  items: const [
                    DropdownMenuItem(value: 'publishedDate_descending', child: Text('Published: Newest')),
                    DropdownMenuItem(value: 'publishedDate_ascending', child: Text('Published: Oldest')),
                    DropdownMenuItem(value: 'recordingDate_descending', child: Text('Recording: Newest')),
                    DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Recording: Oldest')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    final parts = val.split('_');
                    final sortBy = parts[0] == 'publishedDate' ? SortBy.publishedDate : SortBy.recordingDate;
                    final sortOrder = parts[1] == 'descending' ? SortOrder.descending : SortOrder.ascending;
                    context.read<VideosBloc>().add(VideosEvent.sortVideos(sortBy, sortOrder));
                  },
                ),
              ),
              if (hasFilters)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => context.read<VideosBloc>().add(const VideosEvent.clearFilters()),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video) {
    final df = DateFormat('yyyy-MM-dd');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.red,
                mini: true,
                onPressed: () => _launchVideo(video.id),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(video.channelName, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text('Published: ${df.format(video.publishedAt)}'),
                if (video.hasRecordingDate)
                  Text('Recorded: ${df.format(video.recordingDate!)}'),
                if (video.hasLocation)
                  Text('Location: ${video.locationText}'),
                if (video.hasCoordinates)
                  Text('GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}'),
                if (video.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        ...video.tags.take(3).map((t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                        )),
                        if (video.tags.length > 3)
                          Chip(label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10))),
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchVideo(String id) async {
    final appUrl = Uri.parse('youtube://watch?v=$id');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$id');
    
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl);
    }
  }
}
