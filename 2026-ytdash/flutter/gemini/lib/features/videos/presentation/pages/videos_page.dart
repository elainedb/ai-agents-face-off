import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import '../../domain/entities/video.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  final User user;

  const VideosPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<VideosBloc>(),
                    child: const MapScreen(),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<void>(
            icon: user.hasPhoto
                ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!))
                : const CircleAvatar(child: Icon(Icons.person)),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  context.read<AuthBloc>().add(const AuthEvent.signOut());
                },
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
            loaded: (loadedState) => _buildLoadedBody(context, loadedState),
            error: (errorState) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorState.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, VideosLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
      },
      child: Column(
        children: [
          _buildToolbar(context, state),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (state.isRefreshing) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: state.filteredVideos.length,
              itemBuilder: (context, index) {
                final video = state.filteredVideos[index];
                return _VideoCard(video: video);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, VideosLoaded state) {
    final bloc = context.read<VideosBloc>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DropdownButton<String>(
              hint: const Text('Channel'),
              value: state.selectedChannel,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Channels')),
                ...state.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (val) => bloc.add(VideosEvent.filterByChannel(val)),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              hint: const Text('Country'),
              value: state.selectedCountry,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Countries')),
                ...state.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (val) => bloc.add(VideosEvent.filterByCountry(val)),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: '${state.sortBy.name}_${state.sortOrder.name}',
              items: const [
                DropdownMenuItem(value: 'publishedDate_descending', child: Text('Pub Date: Newest')),
                DropdownMenuItem(value: 'publishedDate_ascending', child: Text('Pub Date: Oldest')),
                DropdownMenuItem(value: 'recordingDate_descending', child: Text('Rec Date: Newest')),
                DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Rec Date: Oldest')),
              ],
              onChanged: (val) {
                if (val != null) {
                  final parts = val.split('_');
                  final by = SortBy.values.firstWhere((e) => e.name == parts[0]);
                  final order = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                  bloc.add(VideosEvent.sortVideos(by, order));
                }
              },
            ),
            if (state.selectedChannel != null || state.selectedCountry != null || state.sortBy != SortBy.publishedDate || state.sortOrder != SortOrder.descending)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => bloc.add(const VideosEvent.clearFilters()),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  
  const _VideoCard({required this.video});

  Future<void> _launchVideo(String id) async {
    final nativeUrl = Uri.parse('youtube://watch?v=$id');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$id');
    if (await canLaunchUrl(nativeUrl)) {
      await launchUrl(nativeUrl);
    } else {
      await launchUrl(webUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                placeholder: (context, url) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => const SizedBox(height: 200, child: Center(child: Icon(Icons.error))),
              ),
              FloatingActionButton(
                onPressed: () => _launchVideo(video.id),
                backgroundColor: Colors.red,
                mini: true,
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(video.channelName, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('Published: ${dateFormat.format(video.publishedAt)}'),
                if (video.hasRecordingDate)
                  Text('Recorded: ${dateFormat.format(video.recordingDate!)}'),
                if (video.hasLocation)
                   Text('Location: ${video.locationText} ${video.hasCoordinates ? "(${video.latitude}, ${video.longitude})" : ""}'),
                if (video.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        ...video.tags.take(3).map((t) => Chip(label: Text(t), padding: EdgeInsets.zero, labelStyle: const TextStyle(fontSize: 10))),
                        if (video.tags.length > 3)
                          Chip(label: Text('+${video.tags.length - 3} more'), padding: EdgeInsets.zero, labelStyle: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
