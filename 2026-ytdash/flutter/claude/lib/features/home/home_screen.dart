import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/video.dart';
import '../../state/home_controller.dart';
import '../../state/providers.dart';
import '../map/map_screen.dart';
import 'filter_screen.dart';
import 'sort_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Semantics(
      identifier: 'screen_home',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            identifier: 'video_count',
            container: true,
            child: Text('Videos (${state.allVideos.length})'),
          ),
          actions: [
            Semantics(
              identifier: 'refresh_control',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
            ),
            Semantics(
              identifier: 'filter_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const FilterScreen())),
              ),
            ),
            Semantics(
              identifier: 'sort_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SortScreen())),
              ),
            ),
            Semantics(
              identifier: 'map_nav_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
              ),
            ),
            Semantics(
              identifier: 'logout_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
        body: _Body(state: state, controller: controller),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state, required this.controller});

  final HomeState state;
  final HomeController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case HomeStatus.loading:
        return Center(
          child: Semantics(
            identifier: 'loading_indicator',
            container: true,
            child: const CircularProgressIndicator(),
          ),
        );
      case HomeStatus.error:
        return Center(
          child: Semantics(
            identifier: 'error_view',
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  identifier: 'error_retry_button',
                  container: true,
                  button: true,
                  child: ElevatedButton(
                    onPressed: controller.refresh,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      case HomeStatus.empty:
        return const Center(child: Text('No videos match the current filter.'));
      case HomeStatus.content:
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: Semantics(
            identifier: 'video_list',
            container: true,
            child: ListView.builder(
              itemCount: state.displayedVideos.length,
              itemBuilder: (context, index) =>
                  _VideoRow(video: state.displayedVideos[index]),
            ),
          ),
        );
    }
  }
}

class _VideoRow extends ConsumerWidget {
  const _VideoRow({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      identifier: 'video_list_item',
      container: true,
      child: InkWell(
        onTap: () => ref
            .read(externalLinkControllerProvider.notifier)
            .open(video.youtubeUrl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  video.thumbnailUrl,
                  width: 96,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 72,
                    color: Colors.black12,
                    child: const Icon(Icons.movie),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.category,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
