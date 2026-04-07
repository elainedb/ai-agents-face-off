import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/domain/entities/app_user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/videos_bloc.dart';
import '../widgets/video_card.dart';
import 'map_screen.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YT Dash'),
        actions: [
          PopupMenuButton<String>(
            tooltip: user.email,
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          return switch (state) {
            VideosLoading() => const Center(child: CircularProgressIndicator()),
            VideosError() => _ErrorView(message: state.message),
            VideosLoaded() => _LoadedView(user: user, state: state),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.user, required this.state});

  final AppUser user;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            user.hasPhoto ? NetworkImage(user.photoUrl!) : null,
                        child: user.hasPhoto
                            ? null
                            : Text(user.name.characters.first.toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(user.email),
                          ],
                        ),
                      ),
                      if (state.isRefreshing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StringDropdown(
                        label: 'Channel',
                        value: state.selectedChannel,
                        options: state.availableChannels,
                        onChanged: (value) {
                          context.read<VideosBloc>().add(FilterByChannel(value));
                        },
                      ),
                      _StringDropdown(
                        label: 'Country',
                        value: state.selectedCountry,
                        options: state.availableCountries,
                        onChanged: (value) {
                          context.read<VideosBloc>().add(FilterByCountry(value));
                        },
                      ),
                      _SortDropdown(
                        sortBy: state.sortBy,
                        sortOrder: state.sortOrder,
                        onChanged: (sortBy, sortOrder) {
                          context.read<VideosBloc>().add(SortVideos(sortBy, sortOrder));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          context.read<VideosBloc>().add(const RefreshVideos());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MapScreen(videos: state.filteredVideos),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Map'),
                      ),
                      if (state.hasActiveFilters)
                        TextButton(
                          onPressed: () {
                            context.read<VideosBloc>().add(const ClearFilters());
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.filteredVideos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No videos match the current filters.')),
            )
          else
            for (final video in state.filteredVideos)
              VideoCard(
                video: video,
                onPlay: () => _launchVideo(video.id),
              ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserLink = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    await launchUrl(browserLink, mode: LaunchMode.externalApplication);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

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
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                context.read<VideosBloc>().add(const LoadVideos());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StringDropdown extends StatelessWidget {
  const _StringDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('All')),
          ...options.map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.sortBy,
    required this.sortOrder,
    required this.onChanged,
  });

  final SortBy sortBy;
  final SortOrder sortOrder;
  final void Function(SortBy, SortOrder) onChanged;

  @override
  Widget build(BuildContext context) {
    final current = _SortValue(sortBy, sortOrder);
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<_SortValue>(
        initialValue: current,
        decoration: const InputDecoration(
          labelText: 'Sort',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: _SortValue(SortBy.publishedDate, SortOrder.descending),
            child: Text('Published Date (Newest)'),
          ),
          DropdownMenuItem(
            value: _SortValue(SortBy.publishedDate, SortOrder.ascending),
            child: Text('Published Date (Oldest)'),
          ),
          DropdownMenuItem(
            value: _SortValue(SortBy.recordingDate, SortOrder.descending),
            child: Text('Recording Date (Newest)'),
          ),
          DropdownMenuItem(
            value: _SortValue(SortBy.recordingDate, SortOrder.ascending),
            child: Text('Recording Date (Oldest)'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value.sortBy, value.sortOrder);
          }
        },
      ),
    );
  }
}

class _SortValue {
  const _SortValue(this.sortBy, this.sortOrder);

  final SortBy sortBy;
  final SortOrder sortOrder;

  @override
  bool operator ==(Object other) {
    return other is _SortValue &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(sortBy, sortOrder);
}
