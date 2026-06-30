import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/video.dart';
import '../domain/video_query.dart';
import '../state/providers.dart';
import '../state/videos_controller.dart';
import 'identified.dart';
import 'map_screen.dart';

enum _Panel { none, filter, sort }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _Panel _panel = _Panel.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videosControllerProvider.notifier).load();
    });
  }

  void _openVideo(Video v) =>
      ref.read(externalLinkControllerProvider.notifier).open(v.youtubeUrl);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videosControllerProvider);

    return IdentifiedScope(
      'screen_home',
      child: Scaffold(
        appBar: AppBar(
          title: Identified(
            'video_count',
            label: '${state.totalCount} videos',
            child: Text('ytdash — ${state.totalCount} videos'),
          ),
          actions: [
            Identified(
              'filter_button',
              button: true,
              onTap: () => setState(
                  () => _panel = _panel == _Panel.filter ? _Panel.none : _Panel.filter),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: () => setState(() =>
                    _panel = _panel == _Panel.filter ? _Panel.none : _Panel.filter),
              ),
            ),
            Identified(
              'sort_button',
              button: true,
              onTap: () => setState(
                  () => _panel = _panel == _Panel.sort ? _Panel.none : _Panel.sort),
              child: IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
                onPressed: () => setState(() =>
                    _panel = _panel == _Panel.sort ? _Panel.none : _Panel.sort),
              ),
            ),
            Identified(
              'refresh_control',
              button: true,
              onTap: () => ref.read(videosControllerProvider.notifier).refresh(),
              child: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () =>
                    ref.read(videosControllerProvider.notifier).refresh(),
              ),
            ),
            Identified(
              'logout_button',
              button: true,
              onTap: () => ref.read(authControllerProvider.notifier).signOut(),
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
        floatingActionButton: Identified(
          'map_nav_button',
          button: true,
          onTap: _goToMap,
          child: FloatingActionButton.extended(
            onPressed: _goToMap,
            icon: const Icon(Icons.map),
            label: const Text('Map'),
          ),
        ),
        body: _body(state),
      ),
    );
  }

  void _goToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  Widget _body(VideosState state) {
    if (_panel == _Panel.filter) return _filterPanel(state);
    if (_panel == _Panel.sort) return _sortPanel(state);

    switch (state.status) {
      case VideosStatus.loading:
        return Identified(
          'loading_indicator',
          child: const Center(child: CircularProgressIndicator()),
        );
      case VideosStatus.error:
        return _errorView();
      case VideosStatus.empty:
        return const Center(child: Text('No videos available.'));
      case VideosStatus.content:
        return _list(state);
    }
  }

  Widget _errorView() {
    return IdentifiedScope(
      'error_view',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Could not load videos.'),
            const SizedBox(height: 12),
            Identified(
              'error_retry_button',
              button: true,
              onTap: () => ref.read(videosControllerProvider.notifier).load(),
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(videosControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(VideosState state) {
    return IdentifiedScope(
      'video_list',
      child: RefreshIndicator(
        onRefresh: () => ref.read(videosControllerProvider.notifier).refresh(),
        child: ListView.builder(
          itemCount: state.visible.length,
          itemBuilder: (context, i) => _row(state.visible[i]),
        ),
      ),
    );
  }

  Widget _row(Video v) {
    return Identified(
      'video_list_item',
      label: v.title,
      button: true,
      onTap: () => _openVideo(v),
      child: InkWell(
        onTap: () => _openVideo(v),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                height: 54,
                child: v.thumbnailUrl.isEmpty
                    ? _thumbPlaceholder()
                    : Image.network(
                        v.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _thumbPlaceholder(),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.category,
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      v.description,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _thumbPlaceholder() => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.ondemand_video, color: Colors.grey),
      );

  Widget _filterPanel(VideosState state) {
    final categories = availableCategories(state.all);
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Filter by category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: const Text('All'),
          selected: state.query.categoryFilter == null,
          onTap: () {
            ref.read(videosControllerProvider.notifier).setCategoryFilter(null);
            setState(() => _panel = _Panel.none);
          },
        ),
        for (final c in categories)
          ListTile(
            title: Text(c),
            selected: state.query.categoryFilter == c,
            onTap: () {
              ref.read(videosControllerProvider.notifier).setCategoryFilter(c);
              setState(() => _panel = _Panel.none);
            },
          ),
      ],
    );
  }

  Widget _sortPanel(VideosState state) {
    void choose(SortField f, SortDirection d) {
      ref.read(videosControllerProvider.notifier).setSort(f, d);
      setState(() => _panel = _Panel.none);
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Sort',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: const Text('Date — newest'),
          onTap: () => choose(SortField.date, SortDirection.descending),
        ),
        ListTile(
          title: const Text('Date — oldest'),
          onTap: () => choose(SortField.date, SortDirection.ascending),
        ),
        ListTile(
          title: const Text('Title — ascending'),
          onTap: () => choose(SortField.title, SortDirection.ascending),
        ),
        ListTile(
          title: const Text('Title — descending'),
          onTap: () => choose(SortField.title, SortDirection.descending),
        ),
      ],
    );
  }
}
