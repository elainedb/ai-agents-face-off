import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YT Dash'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Open map',
            onPressed: () {
              final state = context.read<VideosBloc>().state;
              if (state is! VideosLoaded) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MapScreen(videos: state.filteredVideos),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthEvent.signOut());
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(user.name),
                    Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundImage: user.hasPhoto ? NetworkImage(user.photoUrl!) : null,
                child: user.hasPhoto ? null : Text(user.name.characters.first.toUpperCase()),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<VideosBloc>().add(const VideosEvent.loadVideos());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            loaded: (
              videos,
              filteredVideos,
              selectedChannel,
              selectedCountry,
              sortBy,
              sortOrder,
              isRefreshing,
            ) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _HeaderCard(
                      user: user,
                      videos: videos,
                      filteredVideos: filteredVideos,
                      selectedChannel: selectedChannel,
                      selectedCountry: selectedCountry,
                      sortBy: sortBy,
                      sortOrder: sortOrder,
                      isRefreshing: isRefreshing,
                    ),
                    const SizedBox(height: 16),
                    if (filteredVideos.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No videos match the current filters.'),
                        ),
                      )
                    else
                      ...filteredVideos.map((video) => _VideoCard(video: video)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.user,
    required this.videos,
    required this.filteredVideos,
    required this.selectedChannel,
    required this.selectedCountry,
    required this.sortBy,
    required this.sortOrder,
    required this.isRefreshing,
  });

  final User user;
  final List<Video> videos;
  final List<Video> filteredVideos;
  final String? selectedChannel;
  final String? selectedCountry;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VideosBloc>();
    final availableChannels = videos.map((video) => video.channelName).toSet().toList()..sort();
    final availableCountries = videos
        .where((video) => video.country?.isNotEmpty ?? false)
        .map((video) => video.country!)
        .toSet()
        .toList()
      ..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(user.name, style: Theme.of(context).textTheme.titleLarge),
            Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _DropdownField<String?>(
                  label: 'Channel',
                  value: selectedChannel,
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(value: null, child: Text('All channels')),
                    ...availableChannels.map(
                      (channel) => DropdownMenuItem<String?>(
                        value: channel,
                        child: Text(channel),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    bloc.add(VideosEvent.filterByChannel(value));
                  },
                ),
                _DropdownField<String?>(
                  label: 'Country',
                  value: selectedCountry,
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(value: null, child: Text('All countries')),
                    ...availableCountries.map(
                      (country) => DropdownMenuItem<String?>(
                        value: country,
                        child: Text(country),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    bloc.add(VideosEvent.filterByCountry(value));
                  },
                ),
                _DropdownField<String>(
                  label: 'Sort',
                  value: '${sortBy.name}_${sortOrder.name}',
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'publishedDate_descending',
                      child: Text('Published Date (Newest)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'publishedDate_ascending',
                      child: Text('Published Date (Oldest)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'recordingDate_descending',
                      child: Text('Recording Date (Newest)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'recordingDate_ascending',
                      child: Text('Recording Date (Oldest)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    final parts = value.split('_');
                    bloc.add(
                      VideosEvent.sortVideos(
                        SortBy.values.byName(parts[0]),
                        SortOrder.values.byName(parts[1]),
                      ),
                    );
                  },
                ),
                OutlinedButton(
                  onPressed: isRefreshing
                      ? null
                      : () {
                          bloc.add(const VideosEvent.refreshVideos());
                        },
                  child: isRefreshing
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Refresh'),
                ),
                if (selectedChannel != null ||
                    selectedCountry != null ||
                    sortBy != SortBy.publishedDate ||
                    sortOrder != SortOrder.descending)
                  TextButton(
                    onPressed: () {
                      bloc.add(const VideosEvent.clearFilters());
                    },
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Showing ${filteredVideos.length} of ${videos.length} videos'),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final tags = video.tags.take(3).toList();
    final overflowCount = video.tags.length - tags.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (video.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  video.thumbnailUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(video.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(video.channelName),
            Text('Published: ${_formatDate(video.publishedAt)}'),
            if (video.recordingDate != null)
              Text('Recording: ${_formatDate(video.recordingDate!)}'),
            if (video.hasLocation) Text('Location: ${video.locationText}'),
            if (video.hasCoordinates)
              Text(
                'Coordinates: ${video.latitude!.toStringAsFixed(4)}, '
                '${video.longitude!.toStringAsFixed(4)}',
              ),
            if (tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ...tags.map((tag) => Chip(label: Text(tag))),
                  if (overflowCount > 0) Chip(label: Text('+$overflowCount more')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                heroTag: 'play_${video.id}',
                backgroundColor: Colors.red,
                onPressed: () => _launchVideo(video.id),
                child: const Icon(Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _launchVideo(String videoId) async {
    final appUri = Uri.parse('youtube://watch?v=$videoId');
    final webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
