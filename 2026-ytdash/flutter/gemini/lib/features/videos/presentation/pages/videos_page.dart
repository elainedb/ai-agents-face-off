import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  final state = context.read<VideosBloc>().state;
                  state.maybeWhen(
                    loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(videos: filteredVideos),
                        ),
                      );
                    },
                    orElse: () {},
                  );
                },
              );
            }
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                authenticated: (user) => PopupMenuButton(
                  icon: user.hasPhoto
                      ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!), radius: 12)
                      : const Icon(Icons.person),
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
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
              return Column(
                children: [
                  _buildToolbar(context, videos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Showing ${filteredVideos.length} of ${videos.length} videos'),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                      },
                      child: ListView.builder(
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = filteredVideos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                      onPressed: () => _launchVideo(video.id),
                                      backgroundColor: Colors.red,
                                      child: const Icon(Icons.play_arrow, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(video.title, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 4),
                                      Text(video.channelName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                                      const SizedBox(height: 8),
                                      Text('Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}'),
                                      if (video.hasRecordingDate)
                                        Text('Recorded: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}'),
                                      if (video.hasLocation)
                                        Text('Location: ${video.locationText}'),
                                      if (video.hasCoordinates)
                                        Text('GPS: ${video.latitude}, ${video.longitude}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8.0,
                                        children: [
                                          ...video.tags.take(3).map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero)),
                                          if (video.tags.length > 3)
                                            Chip(label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (message) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VideosBloc>().add(const VideosEvent.loadVideos());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, List videos, String? selectedChannel, String? selectedCountry, SortBy sortBy, SortOrder sortOrder, bool isRefreshing) {
    final bloc = context.read<VideosBloc>();
    final channels = bloc.getAvailableChannels(videos.cast());
    final countries = bloc.getAvailableCountries(videos.cast());
    
    bool hasFilters = selectedChannel != null || selectedCountry != null || sortBy != SortBy.publishedDate || sortOrder != SortOrder.descending;

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Channel'),
                  value: selectedChannel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Channels')),
                    ...channels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (value) => bloc.add(VideosEvent.filterByChannel(value)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Country'),
                  value: selectedCountry,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Countries')),
                    ...countries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (value) => bloc.add(VideosEvent.filterByCountry(value)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: '${sortBy.name}_${sortOrder.name}',
                  items: const [
                    DropdownMenuItem(value: 'publishedDate_descending', child: Text('Published: Newest')),
                    DropdownMenuItem(value: 'publishedDate_ascending', child: Text('Published: Oldest')),
                    DropdownMenuItem(value: 'recordingDate_descending', child: Text('Recorded: Newest')),
                    DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Recorded: Oldest')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final parts = value.split('_');
                      final newSortBy = SortBy.values.firstWhere((e) => e.name == parts[0]);
                      final newSortOrder = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                      bloc.add(VideosEvent.sortVideos(newSortBy, newSortOrder));
                    }
                  },
                ),
              ),
              if (hasFilters)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => bloc.add(const VideosEvent.clearFilters()),
                  tooltip: 'Clear Filters',
                ),
              IconButton(
                icon: isRefreshing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
                onPressed: isRefreshing ? null : () => bloc.add(const VideosEvent.refreshVideos()),
                tooltip: 'Refresh',
              ),
            ],
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
      await launchUrl(webUrl);
    }
  }
}
