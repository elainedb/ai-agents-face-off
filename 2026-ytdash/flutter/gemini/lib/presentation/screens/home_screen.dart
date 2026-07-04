import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';
import '../../core/utils/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_home',
      container: true,
      explicitChildNodes: true,
      child: Scaffold(
        key: const Key('screen_home'),
        appBar: AppBar(
        title: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            final count = state is VideoLoaded ? state.filteredVideos.length : 0;
            return Semantics(
              identifier: 'video_count',
              container: true,
              child: Text('Videos (Count: $count)'),
            );
          },
        ),
        actions: [
          Semantics(
            identifier: 'refresh_control',
            button: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<VideoBloc>().add(FetchVideos());
              },
            ),
          ),
          Semantics(
            identifier: 'sort_button',
            button: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => _showSortBottomSheet(context),
            ),
          ),
          Semantics(
            identifier: 'filter_button',
            button: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
          Semantics(
            identifier: 'map_nav_button',
            button: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
          ),
          Semantics(
            identifier: 'logout_button',
            button: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ),
        ],
      ),
      body: Semantics(
        identifier: 'video_list',
        container: true,
        explicitChildNodes: true,
        child: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VideoError) {
              return Semantics(
                identifier: 'error_view',
                container: true,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => context.read<VideoBloc>().add(FetchVideos()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is VideoLoaded) {
              return ListView.builder(
                itemCount: state.filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = state.filteredVideos[index];
                  // Move Semantics explicitly to the text element that the test is looking for
                  return Semantics(
                    identifier: 'video_list_item',
                    label: '${video.title}\n${video.category} • ${video.formattedDuration}',
                    container: true,
                    child: ExcludeSemantics(
                      child: Card(
                        child: ListTile(
                          leading: Semantics(
                            identifier: 'video_thumbnail_${video.id}',
                            image: true,
                            container: true,
                            child: Image.network(video.thumbnailUrl, width: 100, fit: BoxFit.cover),
                          ),
                          title: Semantics(
                            label: video.title,
                            child: Text(video.title),
                          ),
                          subtitle: Text('${video.category} • ${video.formattedDuration}'),
                          onTap: () {
                            launchExternalUrl(context, 'https://www.youtube.com/watch?v=${video.id}');
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ));
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  context.read<VideoBloc>().add(const SortVideos(false));
                },
                child: const Text('Date Desc'),
              ),
              TextButton(
                onPressed: () {
                  context.read<VideoBloc>().add(const SortVideos(true));
                },
                child: const Text('Date Asc'),
              ),
              Semantics(
                identifier: 'sort_apply_button',
                button: true,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Get unique categories from current state
    final state = context.read<VideoBloc>().state;
    final categories = <String>{};
    if (state is VideoLoaded) {
      for (var v in state.videos) {
        categories.add(v.category);
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                onTap: () {
                  context.read<VideoBloc>().add(const FilterVideos(''));
                },
              ),
              for (var category in categories)
                ListTile(
                  title: Text(category),
                  onTap: () {
                    context.read<VideoBloc>().add(FilterVideos(category));
                },
              ),
              Semantics(
                identifier: 'filter_apply_button',
                button: true,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
