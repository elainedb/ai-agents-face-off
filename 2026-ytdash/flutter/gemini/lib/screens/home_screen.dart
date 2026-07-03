import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final AppStateNotifier appState;
  final AuthService authService;
  final VoidCallback onNavigateToMap;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.authService,
    required this.onNavigateToMap,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAppStateChanged);
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.fetchVideos();
    });
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleRefresh() async {
    await widget.appState.fetchVideos(forceRefresh: true);
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    widget.onLogout();
  }

  Future<void> _launchVideo(Video video) async {
    if (widget.appState.config.captureExternalLinks) {
      widget.appState.captureUrl(video.youtubeUrl);
    } else {
      try {
        final Uri url = Uri.parse(video.youtubeUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        widget.appState.setExternalOpenError('Failed to launch YouTube app: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return Semantics(
      identifier: 'screen_home',
      container: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 4,
          title: Semantics(
            identifier: 'video_count',
            container: true,
            child: Text(
              'YT Dash (${state.videos.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Semantics(
              identifier: 'refresh_control',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _handleRefresh,
                tooltip: 'Refresh Videos',
              ),
            ),
            Semantics(
              identifier: 'filter_button',
              container: true,
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: state.selectedCategory != null ? Colors.amberAccent : Colors.white,
                ),
                onPressed: () {
                  state.setSortPanelOpen(false);
                  state.setFilterPanelOpen(!state.isFilterPanelOpen);
                },
                tooltip: 'Filter',
              ),
            ),
            Semantics(
              identifier: 'sort_button',
              container: true,
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.sort_rounded,
                  color: state.selectedSort != null ? Colors.amberAccent : Colors.white,
                ),
                onPressed: () {
                  state.setFilterPanelOpen(false);
                  state.setSortPanelOpen(!state.isSortPanelOpen);
                },
                tooltip: 'Sort',
              ),
            ),
            Semantics(
              identifier: 'map_nav_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map_rounded, color: Colors.white),
                onPressed: widget.onNavigateToMap,
                tooltip: 'Map View',
              ),
            ),
            Semantics(
              identifier: 'logout_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: _handleLogout,
                tooltip: 'Sign Out',
              ),
            ),
          ],
        ),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AppStateNotifier state) {
    if (state.isLoading) {
      return Center(
        child: Semantics(
          identifier: 'loading_indicator',
          container: true,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.videos.isEmpty) {
      return Semantics(
        identifier: 'error_view',
        container: true,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Semantics(
                  identifier: 'error_retry_button',
                  container: true,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.isFilterPanelOpen) {
      return _buildFilterPanel(state);
    }

    if (state.isSortPanelOpen) {
      return _buildSortPanel(state);
    }

    if (state.videos.isEmpty) {
      return const Center(
        child: Text(
          'No videos found matching your filters.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return _buildVideoList(state);
  }

  Widget _buildVideoList(AppStateNotifier state) {
    return Semantics(
      identifier: 'video_list',
      container: true,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.redAccent,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: state.videos.length,
          itemBuilder: (context, index) {
            final video = state.videos[index];
            return _buildVideoItem(video);
          },
        ),
      ),
    );
  }

  Widget _buildVideoItem(Video video) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _launchVideo(video),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 56,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, size: 24, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      identifier: 'video_list_item',
                      container: true,
                      child: Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            video.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(video.publishedAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        ),
                      ],
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

  Widget _buildFilterPanel(AppStateNotifier state) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          // Dynamic category items based on configured channels + clear option
          Expanded(
            child: ListView(
              children: [
                _buildCategoryItem(state, null, 'All Categories'),
                _buildCategoryItem(state, 'cronicas', 'Cronicas'),
                _buildCategoryItem(state, 'bike', 'Bike'),
                _buildCategoryItem(state, 'mnt', 'MNT'),
                _buildCategoryItem(state, 'mct', 'MCT'),
                _buildCategoryItem(state, 'tech', 'Tech'),
                _buildCategoryItem(state, 'music', 'Music'),
                _buildCategoryItem(state, 'news', 'News'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            identifier: 'filter_apply_button',
            container: true,
            button: true,
            child: ElevatedButton(
              onPressed: () {
                state.applyFilterAndSort();
                state.setFilterPanelOpen(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(AppStateNotifier state, String? categoryValue, String label) {
    final isSelected = state.selectedCategory?.toLowerCase() == categoryValue?.toLowerCase();
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.amberAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.amberAccent) : null,
      onTap: () {
        state.selectCategory(categoryValue);
      },
    );
  }

  Widget _buildSortPanel(AppStateNotifier state) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sort Videos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildSortItem(state, 'date_desc', 'Date - Newest'),
                _buildSortItem(state, 'date_asc', 'Date - Oldest'),
                _buildSortItem(state, 'title_asc', 'Title - A to Z'),
                _buildSortItem(state, 'title_desc', 'Title - Z to A'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            identifier: 'sort_apply_button',
            container: true,
            button: true,
            child: ElevatedButton(
              onPressed: () {
                state.applyFilterAndSort();
                state.setSortPanelOpen(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Sort', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(AppStateNotifier state, String sortValue, String label) {
    final isSelected = state.selectedSort == sortValue;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.amberAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.amberAccent) : null,
      onTap: () {
        state.selectSort(sortValue);
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
