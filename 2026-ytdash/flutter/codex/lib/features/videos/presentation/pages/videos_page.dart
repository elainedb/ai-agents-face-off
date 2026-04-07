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
    return Scaffold(
      appBar: AppBar(
        title: const Text('YT Dash'),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: user.email,
            onSelected: (String value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const SignOutRequested());
              }
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundImage: user.hasPhoto
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.hasPhoto ? null : Text(user.name.substring(0, 1)),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (BuildContext context, VideosState state) {
          return switch (state) {
            VideosLoading() => const Center(child: CircularProgressIndicator()),
            VideosError() => _ErrorView(
              message: state.message,
              onRetry: () => context.read<VideosBloc>().add(const LoadVideos()),
            ),
            VideosLoaded() => _LoadedView(
              state: state,
              user: user,
              onWatch: (Video video) => _watchVideo(video.id),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }

  Future<void> _watchVideo(String id) async {
    final Uri deepLink = Uri.parse('youtube://watch?v=$id');
    final Uri browser = Uri.parse('https://www.youtube.com/watch?v=$id');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    await launchUrl(browser, mode: LaunchMode.externalApplication);
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.state,
    required this.user,
    required this.onWatch,
  });

  final VideosLoaded state;
  final User user;
  final ValueChanged<Video> onWatch;

  @override
  Widget build(BuildContext context) {
    final VideosBloc bloc = context.read<VideosBloc>();

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const RefreshVideos()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(user.email),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              DropdownButton<String?>(
                value: state.selectedChannel,
                hint: const Text('Channel'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All channels'),
                  ),
                  ...state.availableChannels.map(
                    (String channel) => DropdownMenuItem<String?>(
                      value: channel,
                      child: Text(channel),
                    ),
                  ),
                ],
                onChanged: (String? value) {
                  bloc.add(FilterByChannel(value));
                },
              ),
              DropdownButton<String?>(
                value: state.selectedCountry,
                hint: const Text('Country'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All countries'),
                  ),
                  ...state.availableCountries.map(
                    (String country) => DropdownMenuItem<String?>(
                      value: country,
                      child: Text(country),
                    ),
                  ),
                ],
                onChanged: (String? value) {
                  bloc.add(FilterByCountry(value));
                },
              ),
              DropdownButton<String>(
                value: '${state.sortBy.name}-${state.sortOrder.name}',
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'publishedDate-descending',
                    child: Text('Published Date (Newest)'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'publishedDate-ascending',
                    child: Text('Published Date (Oldest)'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'recordingDate-descending',
                    child: Text('Recording Date (Newest)'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'recordingDate-ascending',
                    child: Text('Recording Date (Oldest)'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  final List<String> parts = value.split('-');
                  bloc.add(
                    SortVideos(
                      parts[0] == 'publishedDate'
                          ? SortBy.publishedDate
                          : SortBy.recordingDate,
                      parts[1] == 'ascending'
                          ? SortOrder.ascending
                          : SortOrder.descending,
                    ),
                  );
                },
              ),
              if (state.hasActiveFilters)
                OutlinedButton(
                  onPressed: () => bloc.add(const ClearFilters()),
                  child: const Text('Clear filters'),
                ),
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
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MapScreen(
                        videos: state.filteredVideos,
                        onWatchVideo: onWatch,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Map'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Showing ${state.filteredVideos.length} of ${state.videos.length} videos',
          ),
          const SizedBox(height: 16),
          if (state.filteredVideos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text('No videos match the current filters.'),
              ),
            ),
          ...state.filteredVideos.map(
            (Video video) =>
                VideoCard(video: video, onWatch: () => onWatch(video)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
