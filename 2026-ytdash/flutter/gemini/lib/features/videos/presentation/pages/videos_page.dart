import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  final User user;

  const VideosPage({super.key, required this.user});

  Future<void> _launchVideo(String videoId) async {
    final Uri appUri = Uri.parse('youtube://watch?v=$videoId');
    final Uri webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Dash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              final state = context.read<VideosBloc>().state;
              state.maybeMap(
                error: (_) {}, // Do nothing
                orElse: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BlocProvider.value(
                      value: context.read<VideosBloc>(),
                      child: const MapScreen(),
                    )),
                  );
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: user.hasPhoto
                ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!))
                : const CircleAvatar(child: Icon(Icons.person)),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthEvent.signOut());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('${user.name}\n${user.email}'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error.message, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            loaded: (loadedState) {
              return Column(
                children: [
                  _buildFilters(context, loadedState),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                      },
                      child: loadedState.filteredVideos.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text('No videos found for selected filters.')),
                              ],
                            )
                          : ListView.builder(
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

  Widget _buildFilters(BuildContext context, VideosState state) {
    final bool hasFilters = state.maybeMap(
      loaded: (s) => s.selectedChannel != null || s.selectedCountry != null || 
                     s.sortBy != SortBy.publishedDate || s.sortOrder != SortOrder.descending,
      orElse: () => false,
    );

    return state.maybeMap(
      loaded: (loadedState) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Channel'),
                    value: loadedState.selectedChannel,
                    items: state.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => context.read<VideosBloc>().add(VideosEvent.filterByChannel(val)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Country'),
                    value: loadedState.selectedCountry,
                    items: state.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                    value: '${loadedState.sortBy.name}_${loadedState.sortOrder.name}',
                    items: const [
                      DropdownMenuItem(value: 'publishedDate_descending', child: Text('Published: Newest')),
                      DropdownMenuItem(value: 'publishedDate_ascending', child: Text('Published: Oldest')),
                      DropdownMenuItem(value: 'recordingDate_descending', child: Text('Recording: Newest')),
                      DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Recording: Oldest')),
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
                if (hasFilters) ...[
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.clearFilters()),
                    tooltip: 'Clear filters',
                  )
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Showing ${loadedState.filteredVideos.length} of ${loadedState.videos.length} videos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (loadedState.isRefreshing)
              const LinearProgressIndicator(),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildVideoCard(Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final String pubDate = dateFormat.format(video.publishedAt);
    final String recDate = video.recordingDate != null ? dateFormat.format(video.recordingDate!) : 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                onPressed: () => _launchVideo(video.id),
                backgroundColor: Colors.red,
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(video.channelName, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text('Published: $pubDate'),
                Text('Recorded: $recDate'),
                if (video.hasLocation)
                  Text('Location: ${video.locationText}'),
                if (video.hasCoordinates)
                  Text('GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    ...video.tags.take(3).map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                        )),
                    if (video.tags.length > 3)
                      Chip(
                        label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
