import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/video.dart';
import '../domain/sorting.dart';
import 'app_state.dart';
import 'home_view_model.dart';
import 'map_screen.dart';
import 'widgets/test_id.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _Panel { none, filter, sort }

class _HomeScreenState extends State<HomeScreen> {
  _Panel _panel = _Panel.none;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return IdNode(
      'screen_home',
      child: Scaffold(
        appBar: AppBar(
          title: IdText(
            'video_count',
            text: 'Videos (${vm.totalCount})',
            child: Text('Videos (${vm.totalCount})'),
          ),
          actions: [
            IdNode(
              'refresh_control',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<HomeViewModel>().refresh(),
              ),
            ),
            IdNode(
              'filter_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => setState(
                  () => _panel = _panel == _Panel.filter ? _Panel.none : _Panel.filter,
                ),
              ),
            ),
            IdNode(
              'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => setState(
                  () => _panel = _panel == _Panel.sort ? _Panel.none : _Panel.sort,
                ),
              ),
            ),
            IdNode(
              'overflow_menu_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => setState(() => _menuOpen = !_menuOpen),
              ),
            ),
          ],
        ),
        floatingActionButton: IdNode(
          'map_nav_button',
          button: true,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('Map'),
          ),
        ),
        body: Stack(
          children: [
            _body(context, vm),
            if (_menuOpen) _logoutMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, HomeViewModel vm) {
    // Filter/sort panels REPLACE the list while open (cross-framework §D.2) so
    // their option text can't collide with item titles.
    if (_panel == _Panel.filter) return _filterPanel(context, vm);
    if (_panel == _Panel.sort) return _sortPanel(context, vm);

    switch (vm.status) {
      case ViewStatus.loading:
        return Center(
          child: IdNode(
            'loading_indicator',
            child: const CircularProgressIndicator(),
          ),
        );
      case ViewStatus.error:
        return _errorView(context, vm);
      case ViewStatus.empty:
        return const Center(child: Text('No videos found.'));
      case ViewStatus.content:
        return _list(context, vm);
    }
  }

  Widget _list(BuildContext context, HomeViewModel vm) {
    final videos = vm.visibleVideos;
    return RefreshIndicator(
      onRefresh: () => context.read<HomeViewModel>().refresh(),
      child: IdNode(
        'video_list',
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: videos.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => _row(context, videos[i]),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Video video) {
    return IdText(
      'video_list_item',
      text: video.title,
      button: true,
      child: InkWell(
        onTap: () => context.read<AppState>().openExternal(video.youtubeUrl),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumb(video),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.category,
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
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

  Widget _thumb(Video video) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 96,
        height: 54,
        child: video.thumbnailUrl.isEmpty
            ? const ColoredBox(color: Colors.black12, child: Icon(Icons.videocam))
            : Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Colors.black12,
                  child: Icon(Icons.videocam),
                ),
              ),
      ),
    );
  }

  Widget _errorView(BuildContext context, HomeViewModel vm) {
    return Center(
      child: IdNode(
        'error_view',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Something went wrong.'),
            const SizedBox(height: 12),
            IdNode(
              'error_retry_button',
              button: true,
              child: ElevatedButton(
                onPressed: () => context.read<HomeViewModel>().refresh(),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPanel(BuildContext context, HomeViewModel vm) {
    final categories = vm.categories;
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Filter by category',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _filterTile(context, label: 'All', value: null),
        for (final c in categories) _filterTile(context, label: c, value: c),
      ],
    );
  }

  Widget _filterTile(BuildContext context,
      {required String label, required String? value}) {
    return ListTile(
      title: Text(label),
      onTap: () {
        context.read<HomeViewModel>().applyFilter(value);
        setState(() => _panel = _Panel.none);
      },
    );
  }

  Widget _sortPanel(BuildContext context, HomeViewModel vm) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Sort by',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        for (final option in SortOption.values)
          ListTile(
            title: Text(option.label),
            onTap: () {
              context.read<HomeViewModel>().applySort(option);
              setState(() => _panel = _Panel.none);
            },
          ),
      ],
    );
  }

  Widget _logoutMenu(BuildContext context) {
    return Positioned(
      top: 4,
      right: 8,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: IdNode(
          'logout_button',
          button: true,
          child: InkWell(
            onTap: () {
              setState(() => _menuOpen = false);
              context.read<AppState>().signOut();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text('Logout'),
            ),
          ),
        ),
      ),
    );
  }
}
