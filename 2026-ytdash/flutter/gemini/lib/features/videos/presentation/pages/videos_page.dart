import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
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
              Navigator.of(context).push(
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
                      ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!), radius: 14)
                      : const CircleAvatar(child: Icon(Icons.person, size: 14), radius: 14),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Logout'),
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
            error: (message) => _buildError(context, message),
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
              return Column(
                children: [
                  _buildFilters(context, state),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing ${filteredVideos.length} of ${videos.length} videos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  if (isRefreshing && filteredVideos.isEmpty)
                    const LinearProgressIndicator(),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: video.thumbnailUrl,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey, height: 200),
                                      errorWidget: (context, url, error) => Container(color: Colors.grey, height: 200, child: const Icon(Icons.error)),
                                    ),
                                    FloatingActionButton(
                                      mini: true,
                                      backgroundColor: Colors.red,
                                      onPressed: () => _launchVideo(video.id),
                                      child: const Icon(Icons.play_arrow, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        video.channelName,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(video.publishedAt),
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          if (video.hasRecordingDate) ...[
                                            const SizedBox(width: 16),
                                            const Icon(Icons.videocam, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('yyyy-MM-dd').format(video.recordingDate!),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (video.hasLocation) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                video.locationText,
                                                style: Theme.of(context).textTheme.bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (video.tags.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 4,
                                          children: [
                                            ...video.tags.take(3).map((tag) => Chip(
                                              label: Text('#$tag', style: const TextStyle(fontSize: 10)),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            )),
                                            if (video.tags.length > 3)
                                              Chip(
                                                label: Text('+${video.tags.length - 3} more', style: const TextStyle(fontSize: 10)),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                          ],
                                        )
                                      ],
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
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
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
  }

  Widget _buildFilters(BuildContext context, VideosState state) {
    return state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
        final hasFilters = selectedChannel != null || selectedCountry != null || sortBy != SortBy.publishedDate || sortOrder != SortOrder.descending;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Channel'),
                        value: selectedChannel,
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text('All Channels')),
                          ...state.availableChannels.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (value) {
                          context.read<VideosBloc>().add(VideosEvent.filterByChannel(value));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Country'),
                        value: selectedCountry,
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text('All Countries')),
                          ...state.availableCountries.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (value) {
                          context.read<VideosBloc>().add(VideosEvent.filterByCountry(value));
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
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
                            final by = SortBy.values.firstWhere((e) => e.name == parts[0]);
                            final order = SortOrder.values.firstWhere((e) => e.name == parts[1]);
                            context.read<VideosBloc>().add(VideosEvent.sortVideos(by, order));
                          }
                        },
                      ),
                    ),
                  ),
                  if (hasFilters)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear Filters',
                      onPressed: () {
                        context.read<VideosBloc>().add(const VideosEvent.clearFilters());
                      },
                    ),
                  IconButton(
                    icon: isRefreshing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: isRefreshing ? null : () {
                      context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUrl = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore
    }
  }
}