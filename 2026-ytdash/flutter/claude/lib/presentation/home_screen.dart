import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/video.dart';
import '../domain/video_query.dart';
import 'auth_controller.dart';
import 'external_open_controller.dart';
import 'map_screen.dart';
import 'video_controller.dart';
import 'widgets/test_id.dart';

enum _Panel { none, filter, sort }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Panel _panel = _Panel.none;
  String? _pendingFilter;
  SortOption _pendingSort = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vc = context.read<VideoController>();
      if (vc.allVideos.isEmpty) vc.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VideoController>();
    return TestId(
      'screen_home',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: TestId(
            'video_count',
            child: Text('Videos (${vc.totalCount})'),
          ),
          actions: [
            TestId(
              'refresh_control',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => context.read<VideoController>().load(forceRefresh: true),
              ),
            ),
            TestId(
              'filter_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: () => setState(() {
                  _pendingFilter = vc.filterCategory;
                  _panel = _Panel.filter;
                }),
              ),
            ),
            TestId(
              'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
                onPressed: () => setState(() {
                  _pendingSort = vc.sortOption == SortOption.none
                      ? SortOption.dateDesc
                      : vc.sortOption;
                  _panel = _Panel.sort;
                }),
              ),
            ),
            TestId(
              'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => context.read<AuthController>().signOut(),
              ),
            ),
          ],
        ),
        floatingActionButton: TestId(
          'map_nav_button',
          button: true,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.map),
            label: const Text('Map'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
          ),
        ),
        body: _body(context, vc),
      ),
    );
  }

  Widget _body(BuildContext context, VideoController vc) {
    // Filter/sort panels REPLACE the list while open so their option text can't collide with item
    // titles for a black-box driver (cross-framework-setup §D.2).
    switch (_panel) {
      case _Panel.filter:
        return _filterPanel(context, vc);
      case _Panel.sort:
        return _sortPanel(context, vc);
      case _Panel.none:
        break;
    }

    if (vc.state == ViewState.loading && vc.allVideos.isEmpty) {
      return const Center(
        child: TestId('loading_indicator', child: CircularProgressIndicator()),
      );
    }
    if (vc.state == ViewState.error) {
      return _errorView(context, vc);
    }
    if (vc.state == ViewState.empty) {
      return const Center(child: Text('No videos available.'));
    }
    return _list(context, vc);
  }

  Widget _list(BuildContext context, VideoController vc) {
    final videos = vc.visibleVideos;
    return TestId(
      'video_list',
      container: true,
      child: RefreshIndicator(
        onRefresh: () => context.read<VideoController>().load(forceRefresh: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) => _row(context, videos[index]),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Video video) {
    return TestId(
      'video_list_item',
      button: true,
      merge: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: SizedBox(
            width: 64,
            height: 48,
            child: video.thumbnailUrl.isEmpty
                ? const Icon(Icons.image)
                : Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
                  ),
          ),
          title: Text(video.title),
          subtitle: Text(
            video.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(video.category),
          onTap: () => context.read<ExternalOpenController>().open(video.youtubeUrl),
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, VideoController vc) {
    return TestId(
      'error_view',
      container: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(vc.errorMessage ?? 'Something went wrong.'),
            const SizedBox(height: 16),
            TestId(
              'error_retry_button',
              button: true,
              child: ElevatedButton(
                onPressed: () => context.read<VideoController>().load(forceRefresh: true),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPanel(BuildContext context, VideoController vc) {
    final categories = vc.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Filter by category', style: TextStyle(fontSize: 18)),
        ),
        Expanded(
          child: ListView(
            children: [
              _filterTile(context, label: 'All', value: null),
              for (final c in categories) _filterTile(context, label: c, value: c),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TestId(
            'filter_apply_button',
            button: true,
            child: ElevatedButton(
              onPressed: () {
                context.read<VideoController>().setFilter(_pendingFilter);
                setState(() => _panel = _Panel.none);
              },
              child: const Text('Apply filter'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterTile(BuildContext context, {required String label, required String? value}) {
    final selected = _pendingFilter == value;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => setState(() => _pendingFilter = value),
    );
  }

  Widget _sortPanel(BuildContext context, VideoController vc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Sort videos', style: TextStyle(fontSize: 18)),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final o in SortOption.selectable)
                ListTile(
                  title: Text(o.label),
                  trailing: _pendingSort == o ? const Icon(Icons.check) : null,
                  onTap: () => setState(() => _pendingSort = o),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TestId(
            'sort_apply_button',
            button: true,
            child: ElevatedButton(
              onPressed: () {
                context.read<VideoController>().setSort(_pendingSort);
                setState(() => _panel = _Panel.none);
              },
              child: const Text('Apply sort'),
            ),
          ),
        ),
      ],
    );
  }
}
