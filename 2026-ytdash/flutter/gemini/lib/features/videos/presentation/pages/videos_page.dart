import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import 'map_screen.dart';

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
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<VideosBloc>(),
                    child: const MapScreen(),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                authenticated: (user) => PopupMenuButton(
                  icon: user.hasPhoto 
                      ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!))
                      : const Icon(Icons.account_circle),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Sign Out'),
                      onTap: () {
                        context.read<AuthBloc>().add(const AuthEvent.signOut());
                      },
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              );
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
                  Text('Error: $message', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VideosBloc>().add(const VideosEvent.loadVideos()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
              return Column(
                children: [
                  _FiltersSection(state: state as VideosLoaded),
                  if (isRefreshing) const LinearProgressIndicator(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                        // Simple delay to let the refresh animation play slightly
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = filteredVideos[index];
                          return _VideoCard(video: video);
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
}

class _FiltersSection extends StatelessWidget {
  final VideosLoaded state;

  const _FiltersSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool hasFilters = state.selectedChannel != null || state.selectedCountry != null || state.sortBy != SortBy.publishedDate || state.sortOrder != SortOrder.descending;

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: state.selectedChannel,
                  hint: const Text('All Channels'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Channels')),
                    ...state.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  ],
                  onChanged: (value) => context.read<VideosBloc>().add(VideosEvent.filterByChannel(value)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: state.selectedCountry,
                  hint: const Text('All Countries'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Countries')),
                    ...state.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  ],
                  onChanged: (value) => context.read<VideosBloc>().add(VideosEvent.filterByCountry(value)),
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
                    DropdownMenuItem(value: 'recordingDate_descending', child: Text('Recorded: Newest')),
                    DropdownMenuItem(value: 'recordingDate_ascending', child: Text('Recorded: Oldest')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final parts = value.split('_');
                      final sortBy = SortBy.values.firstWhere((e) => e.name == parts[0]);
                      final sortOrder = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                      context.read<VideosBloc>().add(VideosEvent.sortVideos(sortBy, sortOrder));
                    }
                  },
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.read<VideosBloc>().add(const VideosEvent.clearFilters()),
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;

  const _VideoCard({required this.video});

  Future<void> _launchVideo() async {
    final nativeUrl = Uri.parse('youtube://watch?v=${video.id}');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=${video.id}');
    
    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final pubDate = dateFormat.format(video.publishedAt);
    final recDate = video.hasRecordingDate ? dateFormat.format(video.recordingDate!) : 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                ),
              ),
              IconButton(
                iconSize: 64,
                icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                onPressed: _launchVideo,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(video.channelName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pub: $pubDate', style: Theme.of(context).textTheme.bodySmall),
                    Text('Rec: $recDate', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (video.hasLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                      ...video.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                        child: Text(tag, style: const TextStyle(fontSize: 10)),
                      )),
                      if (video.tags.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                          child: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
