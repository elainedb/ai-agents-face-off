import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/domain/entities/app_user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosBloc, VideosState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('YT Dash'),
            actions: [
              IconButton(
                tooltip: 'Open map',
                onPressed: state is VideosLoaded
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MapScreen(videos: state.filteredVideos),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.map_outlined),
              ),
              PopupMenuButton<String>(
                tooltip: user.email,
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    value: 'profile',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: user.hasPhoto
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.hasPhoto
                            ? null
                            : Text(user.name.characters.first.toUpperCase()),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CircleAvatar(
                    backgroundImage: user.hasPhoto
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.hasPhoto
                        ? null
                        : Text(user.name.characters.first.toUpperCase()),
                  ),
                ),
              ),
            ],
          ),
          body: switch (state) {
            VideosLoading() ||
            VideosInitial() => const Center(child: CircularProgressIndicator()),
            VideosError(:final message) => _VideosErrorView(message: message),
            VideosLoaded() => _VideosLoadedView(state: state),
          },
        );
      },
    );
  }
}

class _VideosLoadedView extends StatelessWidget {
  const _VideosLoadedView({required this.state});

  final VideosLoaded state;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        state.selectedChannel != null ||
        state.selectedCountry != null ||
        state.sortBy != SortBy.publishedDate ||
        state.sortOrder != SortOrder.descending;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VideosBloc>().add(const RefreshVideos());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FilterCard(state: state, hasActiveFilters: hasActiveFilters),
          const SizedBox(height: 12),
          Text(
            'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (state.filteredVideos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No videos matched the current filters.'),
              ),
            ),
          ...state.filteredVideos.map((video) => _VideoCard(video: video)),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.state, required this.hasActiveFilters});

  final VideosLoaded state;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VideosBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String?>(
              initialValue: state.selectedChannel,
              decoration: const InputDecoration(labelText: 'Channel'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All channels'),
                ),
                ...state.availableChannels.map(
                  (channel) => DropdownMenuItem<String?>(
                    value: channel,
                    child: Text(channel),
                  ),
                ),
              ],
              onChanged: (value) => bloc.add(FilterByChannel(value)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: state.selectedCountry,
              decoration: const InputDecoration(labelText: 'Country'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All countries'),
                ),
                ...state.availableCountries.map(
                  (country) => DropdownMenuItem<String?>(
                    value: country,
                    child: Text(country),
                  ),
                ),
              ],
              onChanged: (value) => bloc.add(FilterByCountry(value)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_SortOption>(
              initialValue: _SortOption(state.sortBy, state.sortOrder),
              decoration: const InputDecoration(labelText: 'Sort'),
              items: _SortOption.values
                  .map(
                    (option) => DropdownMenuItem<_SortOption>(
                      value: option,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  bloc.add(SortVideos(value.sortBy, value.sortOrder));
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasActiveFilters)
                  OutlinedButton(
                    onPressed: () => bloc.add(const ClearFilters()),
                    child: const Text('Clear filters'),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: state.isRefreshing
                      ? null
                      : () => bloc.add(const RefreshVideos()),
                  icon: state.isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VideosErrorView extends StatelessWidget {
  const _VideosErrorView({required this.message});

  final String message;

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
            FilledButton(
              onPressed: () =>
                  context.read<VideosBloc>().add(const LoadVideos()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final tags = video.tags.take(3).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => const ColoredBox(
                    color: Color(0x14000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, _, _) => const ColoredBox(
                    color: Color(0x14000000),
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(video.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(video.channelName),
            const SizedBox(height: 8),
            Text('Published: ${dateFormat.format(video.publishedAt)}'),
            if (video.recordingDate != null)
              Text('Recording: ${dateFormat.format(video.recordingDate!)}'),
            if (video.hasLocation) Text('Location: ${video.locationText}'),
            if (video.hasCoordinates)
              Text(
                'Coordinates: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
              ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...tags.map((tag) => Chip(label: Text(tag))),
                  if (video.tags.length > tags.length)
                    Chip(
                      label: Text('+${video.tags.length - tags.length} more'),
                    ),
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

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserLink = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(browserLink, mode: LaunchMode.externalApplication);
  }
}

class _SortOption extends Equatable {
  const _SortOption(this.sortBy, this.sortOrder);

  final SortBy sortBy;
  final SortOrder sortOrder;

  static const values = [
    _SortOption(SortBy.publishedDate, SortOrder.descending),
    _SortOption(SortBy.publishedDate, SortOrder.ascending),
    _SortOption(SortBy.recordingDate, SortOrder.descending),
    _SortOption(SortBy.recordingDate, SortOrder.ascending),
  ];

  String get label => switch ((sortBy, sortOrder)) {
    (SortBy.publishedDate, SortOrder.descending) => 'Published Date (Newest)',
    (SortBy.publishedDate, SortOrder.ascending) => 'Published Date (Oldest)',
    (SortBy.recordingDate, SortOrder.descending) => 'Recording Date (Newest)',
    (SortBy.recordingDate, SortOrder.ascending) => 'Recording Date (Oldest)',
  };

  @override
  List<Object?> get props => [sortBy, sortOrder];
}
