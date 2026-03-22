import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../widgets/video_card.dart';
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
            actions: <Widget>[
              IconButton(
                onPressed: state is VideosLoaded
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MapScreen(
                              videos: state.filteredVideos,
                              onOpenVideo: _openVideo,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.map_outlined),
                tooltip: 'Map',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const AuthEvent.signOut());
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
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
                        : Text(user.name.isNotEmpty ? user.name[0] : '?'),
                  ),
                ),
              ),
            ],
          ),
          body: state is VideosLoaded
              ? _LoadedView(state: state, user: user, onOpenVideo: _openVideo)
              : state is VideosError
              ? _ErrorView(message: state.message)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> _openVideo(Video video) async {
    final appUri = Uri.parse('youtube://watch?v=${video.id}');
    final webUri = Uri.parse('https://www.youtube.com/watch?v=${video.id}');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.state,
    required this.user,
    required this.onOpenVideo,
  });

  final VideosLoaded state;
  final User user;
  final Future<void> Function(Video video) onOpenVideo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: user.hasPhoto
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.hasPhoto
                            ? null
                            : Text(user.name.isNotEmpty ? user.name[0] : '?'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(user.email),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: state.isRefreshing
                            ? null
                            : () => context.read<VideosBloc>().add(
                                const VideosEvent.refreshVideos(),
                              ),
                        icon: state.isRefreshing
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _FilterDropdown<String>(
                        hint: 'Channel',
                        value: state.selectedChannel,
                        items: state.availableChannels,
                        onChanged: (value) => context.read<VideosBloc>().add(
                          VideosEvent.filterByChannel(value),
                        ),
                      ),
                      _FilterDropdown<String>(
                        hint: 'Country',
                        value: state.selectedCountry,
                        items: state.availableCountries,
                        onChanged: (value) => context.read<VideosBloc>().add(
                          VideosEvent.filterByCountry(value),
                        ),
                      ),
                      _FilterDropdown<String>(
                        hint: 'Sort',
                        value: '${state.sortBy.name}-${state.sortOrder.name}',
                        items: const <String>[
                          'publishedDate-descending',
                          'publishedDate-ascending',
                          'recordingDate-descending',
                          'recordingDate-ascending',
                        ],
                        labelBuilder: (value) => switch (value) {
                          'publishedDate-descending' =>
                            'Published Date (Newest)',
                          'publishedDate-ascending' =>
                            'Published Date (Oldest)',
                          'recordingDate-descending' =>
                            'Recording Date (Newest)',
                          'recordingDate-ascending' =>
                            'Recording Date (Oldest)',
                          _ => value,
                        },
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          final parts = value.split('-');
                          context.read<VideosBloc>().add(
                            VideosEvent.sortVideos(
                              parts.first == 'recordingDate'
                                  ? SortBy.recordingDate
                                  : SortBy.publishedDate,
                              parts.last == 'ascending'
                                  ? SortOrder.ascending
                                  : SortOrder.descending,
                            ),
                          );
                        },
                      ),
                      if (state.hasActiveFilters)
                        OutlinedButton(
                          onPressed: () => context.read<VideosBloc>().add(
                            const VideosEvent.clearFilters(),
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
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<VideosBloc>().add(const VideosEvent.refreshVideos());
            },
            child: state.filteredVideos.isEmpty
                ? ListView(
                    children: const <Widget>[
                      SizedBox(height: 120),
                      Center(
                        child: Text('No videos match the current filters.'),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.filteredVideos.length,
                    itemBuilder: (context, index) {
                      final video = state.filteredVideos[index];
                      return VideoCard(
                        video: video,
                        onPlay: () => onOpenVideo(video),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
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
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<VideosBloc>().add(const VideosEvent.loadVideos());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: <DropdownMenuItem<T>>[
          DropdownMenuItem<T>(value: null, child: Text('All $hint')),
          ...items.map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder?.call(item) ?? item.toString()),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
