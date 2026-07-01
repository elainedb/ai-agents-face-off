import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/external_launch.dart';
import '../../core/ui_state.dart';
import '../../domain/entities/video.dart';
import '../auth/auth_controller.dart';
import '../map/map_screen.dart';
import 'filter_sheet.dart';
import 'home_controller.dart';
import 'sort_sheet.dart';

enum _Panel { none, filter, sort }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _Panel _panel = _Panel.none;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final countText = state.totalLoadedCount?.toString() ?? '…';

    return Semantics(
      container: true,
      identifier: 'screen_home',
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            container: true,
            identifier: 'video_count',
            child: Text('Videos ($countText)'),
          ),
          actions: [
            Semantics(
              container: true,
              identifier: 'refresh_control',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
            ),
            Semantics(
              container: true,
              identifier: 'filter_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => setState(() => _panel = _Panel.filter),
              ),
            ),
            Semantics(
              container: true,
              identifier: 'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => setState(() => _panel = _Panel.sort),
              ),
            ),
            Semantics(
              container: true,
              identifier: 'map_nav_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
              ),
            ),
            Semantics(
              container: true,
              identifier: 'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
        body: _buildBody(state, controller),
      ),
    );
  }

  Widget _buildBody(HomeState state, HomeController controller) {
    switch (_panel) {
      case _Panel.filter:
        return FilterSheet(
          categories: state.availableCategories,
          current: state.filterLabel,
          onApply: (label) {
            controller.setFilter(label);
            setState(() => _panel = _Panel.none);
          },
        );
      case _Panel.sort:
        return SortSheet(
          current: state.sortKey,
          onApply: (key) {
            controller.setSort(key);
            setState(() => _panel = _Panel.none);
          },
        );
      case _Panel.none:
        return _buildVideosView(state, controller);
    }
  }

  Widget _buildVideosView(HomeState state, HomeController controller) {
    final videosState = state.videos;
    if (videosState is UiLoading<List<Video>>) {
      return Semantics(
        container: true,
        identifier: 'loading_indicator',
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (videosState is UiError<List<Video>>) {
      return Semantics(
        container: true,
        identifier: 'error_view',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load videos: ${videosState.message}'),
              const SizedBox(height: 12),
              Semantics(
                container: true,
                identifier: 'error_retry_button',
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
    }
    if (videosState is UiEmpty<List<Video>>) {
      return const Center(child: Text('No videos found.'));
    }

    final visible = state.visible;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: Semantics(
        container: true,
        identifier: 'video_list',
        child: ListView.builder(
          itemCount: visible.length,
          itemBuilder: (context, index) => _VideoRow(video: visible[index]),
        ),
      ),
    );
  }
}

class _VideoRow extends ConsumerWidget {
  const _VideoRow({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      identifier: 'video_list_item',
      child: ListTile(
        leading: SizedBox(
          width: 64,
          height: 48,
          child: video.thumbnailUrl.isEmpty
              ? const Icon(Icons.image_not_supported)
              : Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
        ),
        title: Text(video.title),
        subtitle: Text(
          video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () =>
            ref.read(externalLaunchProvider.notifier).open(video.youtubeUrl),
      ),
    );
  }
}
