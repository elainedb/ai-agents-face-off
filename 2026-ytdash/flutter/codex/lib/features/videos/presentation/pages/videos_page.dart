import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosBloc, VideosState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('YT Dash'),
            actions: [
              if (state is VideosLoaded)
                IconButton(
                  onPressed: state.isRefreshing
                      ? null
                      : () => context.read<VideosBloc>().add(
                          const RefreshVideos(),
                        ),
                  icon: state.isRefreshing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              PopupMenuButton<String>(
                tooltip: user.email,
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CircleAvatar(
                    backgroundImage: user.hasPhoto
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.hasPhoto
                        ? null
                        : Text(user.name.characters.first),
                  ),
                ),
              ),
            ],
          ),
          body: switch (state) {
            VideosInitial() ||
            VideosLoading() => const Center(child: CircularProgressIndicator()),
            VideosError(:final message) => _VideosError(
              message: message,
              onRetry: () => context.read<VideosBloc>().add(const LoadVideos()),
            ),
            VideosLoaded() => _VideosLoadedView(user: user, state: state),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _VideosLoadedView extends StatelessWidget {
  const _VideosLoadedView({required this.user, required this.state});

  final User user;
  final VideosLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<VideosBloc>().add(const RefreshVideos());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.hasPhoto
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        radius: 26,
                        child: user.hasPhoto
                            ? null
                            : Text(user.name.characters.first),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(user.email),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MapScreen(videos: state.filteredVideos),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Map'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildDropdown<String?>(
                        context: context,
                        label: 'Channel',
                        value: state.selectedChannel,
                        items: state.availableChannels,
                        onChanged: (value) => context.read<VideosBloc>().add(
                          FilterByChannel(value),
                        ),
                      ),
                      _buildDropdown<String?>(
                        context: context,
                        label: 'Country',
                        value: state.selectedCountry,
                        items: state.availableCountries,
                        onChanged: (value) => context.read<VideosBloc>().add(
                          FilterByCountry(value),
                        ),
                      ),
                      _buildSortDropdown(context),
                      if (state.hasActiveFilters)
                        OutlinedButton(
                          onPressed: () => context.read<VideosBloc>().add(
                            const ClearFilters(),
                          ),
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...state.filteredVideos.map((video) => _VideoCard(video: video)),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem<T>(value: null, child: const Text('All')),
          ...items.map(
            (item) => DropdownMenuItem<T>(value: item as T, child: Text(item)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    final currentValue = '${state.sortBy.name}:${state.sortOrder.name}';
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: const InputDecoration(
          labelText: 'Sort',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: 'publishedDate:descending',
            child: Text('Published Date (Newest)'),
          ),
          DropdownMenuItem(
            value: 'publishedDate:ascending',
            child: Text('Published Date (Oldest)'),
          ),
          DropdownMenuItem(
            value: 'recordingDate:descending',
            child: Text('Recording Date (Newest)'),
          ),
          DropdownMenuItem(
            value: 'recordingDate:ascending',
            child: Text('Recording Date (Oldest)'),
          ),
        ],
        onChanged: (value) {
          if (value == null) {
            return;
          }
          final parts = value.split(':');
          context.read<VideosBloc>().add(
            SortVideos(
              SortBy.values.firstWhere((element) => element.name == parts[0]),
              SortOrder.values.firstWhere(
                (element) => element.name == parts[1],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final visibleTags = video.tags.take(3).toList();
    final extraTags = video.tags.length - visibleTags.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: 156,
                height: 96,
                fit: BoxFit.cover,
                placeholder: (_, url) => Container(
                  width: 156,
                  height: 96,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (_, error, stackTrace) => Container(
                  width: 156,
                  height: 96,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(video.channelName),
                  Text('Published: ${dateFormatter.format(video.publishedAt)}'),
                  if (video.recordingDate != null)
                    Text(
                      'Recorded: ${dateFormatter.format(video.recordingDate!)}',
                    ),
                  if (video.hasLocation)
                    Text('Location: ${video.locationText}'),
                  if (video.hasCoordinates)
                    Text(
                      'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                    ),
                  if (visibleTags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...visibleTags.map((tag) => Chip(label: Text(tag))),
                        if (extraTags > 0)
                          Chip(label: Text('+$extraTags more')),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'play-${video.id}',
              backgroundColor: Colors.red,
              onPressed: () => _launchVideo(video.id),
              child: const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
  }
}

class _VideosError extends StatelessWidget {
  const _VideosError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
