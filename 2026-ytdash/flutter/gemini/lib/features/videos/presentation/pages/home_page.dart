import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/config/env_config.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/video_bloc.dart';
import '../../../../shared/external_link_manager.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFilterOpen = false;
  bool _isSortOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(LoadVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_home',
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              int count = 0;
              if (state is VideoLoaded) {
                count = state.allVideos.length;
              }
              return Semantics(
                identifier: 'video_count',
                child: Text('Videos ($count)'),
              );
            },
          ),
          actions: [
            Semantics(
              identifier: 'map_nav_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );
                },
              ),
            ),
            Semantics(
              identifier: 'filter_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _isFilterOpen = !_isFilterOpen;
                    _isSortOpen = false;
                  });
                },
              ),
            ),
            Semantics(
              identifier: 'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () {
                  setState(() {
                    _isSortOpen = !_isSortOpen;
                    _isFilterOpen = false;
                  });
                },
              ),
            ),
            Semantics(
              identifier: 'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
              ),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isFilterOpen) {
      return _buildFilterPanel();
    }
    if (_isSortOpen) {
      return _buildSortPanel();
    }

    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading || state is VideoInitial) {
          return Semantics(
            identifier: 'loading_indicator',
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is VideoError) {
          return Semantics(
            identifier: 'error_view',
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  Semantics(
                    identifier: 'error_retry_button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<VideoBloc>().add(LoadVideos()),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is VideoLoaded) {
          return Semantics(
            identifier: 'refresh_control',
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<VideoBloc>().add(RefreshVideos());
              },
              child: Semantics(
                identifier: 'video_list',
                child: ListView.builder(
                  itemCount: state.displayedVideos.length,
                  itemBuilder: (context, index) {
                    final video = state.displayedVideos[index];
                    return Semantics(
                      identifier: 'video_list_item',
                      child: ListTile(
                        leading: video.thumbnailUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: video.thumbnailUrl,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(width: 100),
                        title: Text(video.title),
                        subtitle: Text(video.description, maxLines: 2),
                        onTap: () {
                          ExternalLinkManager.of(
                            context,
                          ).openYoutubeVideo(video.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterPanel() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('All'),
                onTap: () {
                  context.read<VideoBloc>().add(ApplyFilter(null));
                  setState(() => _isFilterOpen = false);
                },
              ),
              ...AppConfig.channels.map((channel) {
                final category = channel['label']!;
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    context.read<VideoBloc>().add(ApplyFilter(category));
                    // The spec says we need filter_apply_button if it doesn't apply instantly.
                    // But if it applies instantly, we can omit it, but wait! The spec says "omit only if filtering applies instantly", BUT "The flows select the option by visible text ((?i)tech). If the list stays on screen... Replacing the list while the panel is open removes the collision."
                    // Also AC-FILTER-01 clicks `filter_apply_button`. So we MUST HAVE a button with identifier `filter_apply_button`!!
                  },
                );
              }),
            ],
          ),
        ),
        Semantics(
          identifier: 'filter_apply_button',
          button: true,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _isFilterOpen = false);
            },
            child: const Text('Apply Filter'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSortPanel() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Date — newest'),
                onTap: () {
                  context.read<VideoBloc>().add(ApplySort(ascending: false));
                },
              ),
              ListTile(
                title: const Text('Date — oldest'),
                onTap: () {
                  context.read<VideoBloc>().add(ApplySort(ascending: true));
                },
              ),
            ],
          ),
        ),
        Semantics(
          identifier: 'sort_apply_button',
          button: true,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _isSortOpen = false);
            },
            child: const Text('Apply Sort'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
