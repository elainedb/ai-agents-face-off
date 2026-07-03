import 'package:flutter/material.dart';
import 'package:ytdash_flutter/data/models/channel.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/ui/features/auth/view_models/auth_view_model.dart';
import 'package:ytdash_flutter/ui/features/home/view_models/video_view_model.dart';
import 'package:ytdash_flutter/ui/features/map/views/map_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthViewModel authViewModel;
  final VideoViewModel videoViewModel;
  final TestConfig config;
  final List<ChannelConfig> channels;

  const HomeScreen({
    super.key,
    required this.authViewModel,
    required this.videoViewModel,
    required this.config,
    required this.channels,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initial fetch of video data (refreshing the local cache)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.videoViewModel.loadVideos(
        forceRefresh: true,
        config: widget.config,
        channels: widget.channels,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_home',
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A), // Dark space theme
        appBar: AppBar(
          backgroundColor: const Color(0xFF16162A),
          elevation: 0,
          title: ListenableBuilder(
            listenable: widget.videoViewModel,
            builder: (context, _) {
              final count = widget.videoViewModel.displayedVideos.length;
              return Semantics(
                identifier: 'video_count',
                child: Text(
                  'Dashboard ($count)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          actions: [
            // Map Navigation Button
            Semantics(
              identifier: 'map_nav_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map, color: Color(0xFFFF0055)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        authViewModel: widget.authViewModel,
                        videoViewModel: widget.videoViewModel,
                        config: widget.config,
                      ),
                    ),
                  );
                },
                tooltip: 'Show Map',
              ),
            ),
            // Refresh Button (Backup refresh control)
            Semantics(
              identifier: 'refresh_control',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  widget.videoViewModel.loadVideos(
                    forceRefresh: true,
                    config: widget.config,
                    channels: widget.channels,
                  );
                },
                tooltip: 'Refresh',
              ),
            ),
            // Logout Button
            Semantics(
              identifier: 'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () {
                  widget.authViewModel.signOut();
                },
                tooltip: 'Sign Out',
              ),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: widget.videoViewModel,
          builder: (context, _) {
            final vm = widget.videoViewModel;

            // 1. Handling Loading indicator
            if (vm.isLoading && vm.allVideos.isEmpty) {
              return Semantics(
                identifier: 'loading_indicator',
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0055)),
                  ),
                ),
              );
            }

            // 2. Handling blocking Error View
            if (vm.errorMessage != null && vm.allVideos.isEmpty) {
              return Semantics(
                identifier: 'error_view',
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Semantics(
                          identifier: 'error_retry_button',
                          button: true,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0055),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {
                              vm.loadVideos(
                                forceRefresh: true,
                                config: widget.config,
                                channels: widget.channels,
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 3. Render either Filtering Panel, Sorting Panel, or Main List
            if (vm.isFilterPanelOpen) {
              return _buildFilterPanel(vm);
            }

            if (vm.isSortPanelOpen) {
              return _buildSortPanel(vm);
            }

            return _buildMainContent(vm);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(VideoViewModel vm) {
    return Column(
      children: [
        // Action Controls (Filter / Sort toggles)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF16162A),
          child: Row(
            children: [
              // Filter Button
              Expanded(
                child: Semantics(
                  identifier: 'filter_button',
                  button: true,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: vm.selectedCategory != null ? const Color(0xFFFF0055).withOpacity(0.1) : null,
                    ),
                    onPressed: () => vm.openFilterPanel(),
                    icon: Icon(
                      Icons.filter_list,
                      color: vm.selectedCategory != null ? const Color(0xFFFF0055) : Colors.white,
                    ),
                    label: Text(
                      vm.selectedCategory != null ? 'Filtered: ${vm.selectedCategory}' : 'Filter',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Sort Button
              Expanded(
                child: Semantics(
                  identifier: 'sort_button',
                  button: true,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => vm.openSortPanel(),
                    icon: const Icon(Icons.sort, color: Colors.white),
                    label: Text(
                      _getSortLabel(vm.selectedSort),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable List View
        Expanded(
          child: Semantics(
            identifier: 'video_list',
            container: true,
            child: RefreshIndicator(
              color: const Color(0xFFFF0055),
              backgroundColor: const Color(0xFF16162A),
              onRefresh: () => vm.loadVideos(
                forceRefresh: true,
                config: widget.config,
                channels: widget.channels,
              ),
              child: vm.displayedVideos.isEmpty
                  ? const Center(
                      child: Text(
                        'No videos found matching filters.',
                        style: TextStyle(color: Colors.white60, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: vm.displayedVideos.length,
                      itemBuilder: (context, index) {
                        final video = vm.displayedVideos[index];
                        return InkWell(
                          onTap: () {
                            widget.authViewModel.openVideoUrl(video.youtubeUrl, widget.config);
                          },
                          child: Card(
                            color: const Color(0xFF1C1C36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                Stack(
                                  children: [
                                    Image.network(
                                      video.thumbnailUrl,
                                      width: 140,
                                      height: 94,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.black26,
                                          width: 140,
                                          height: 94,
                                          child: const Icon(Icons.movie, color: Colors.white30),
                                        );
                                      },
                                    ),
                                    if (video.lat != null && video.lng != null)
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF0055),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(Icons.location_on, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                // Metadata details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          identifier: 'video_list_item',
                                          child: Text(
                                            video.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          video.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Category label
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.07),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                video.category.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFF7A00FF),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatDate(video.publishedAt),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.3),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(VideoViewModel vm) {
    // Collect all available category labels from channels
    final categories = widget.channels.map((c) => c.label).toList();

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // "All Categories" option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 16)),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: vm.tempSelectedCategory,
                    onChanged: (val) => vm.selectTempCategory(val),
                    activeColor: const Color(0xFFFF0055),
                  ),
                  onTap: () => vm.selectTempCategory(null),
                ),
                const Divider(color: Colors.white10),
                // Custom channel categories
                ...categories.map((category) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      category,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    leading: Radio<String?>(
                      value: category,
                      groupValue: vm.tempSelectedCategory,
                      onChanged: (val) => vm.selectTempCategory(val),
                      activeColor: const Color(0xFFFF0055),
                    ),
                    onTap: () => vm.selectTempCategory(category),
                  );
                }),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => vm.cancelFilter(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  identifier: 'filter_apply_button',
                  container: true,
                  button: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0055),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => vm.applyFilter(),
                    child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortPanel(VideoViewModel vm) {
    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort Options',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildSortOptionTile(
                  vm,
                  label: 'Date - Newest', // Must end with date.*(desc|newest)
                  option: SortOption.dateNewest,
                ),
                _buildSortOptionTile(
                  vm,
                  label: 'Date - Oldest',
                  option: SortOption.dateOldest,
                ),
                _buildSortOptionTile(
                  vm,
                  label: 'Title - A to Z',
                  option: SortOption.titleAsc,
                ),
                _buildSortOptionTile(
                  vm,
                  label: 'Title - Z to A',
                  option: SortOption.titleDesc,
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => vm.cancelSort(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  identifier: 'sort_apply_button',
                  container: true,
                  button: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0055),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => vm.applySort(),
                    child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptionTile(VideoViewModel vm, {required String label, required SortOption option}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      leading: Radio<SortOption>(
        value: option,
        groupValue: vm.tempSelectedSort,
        onChanged: (val) {
          if (val != null) vm.selectTempSort(val);
        },
        activeColor: const Color(0xFFFF0055),
      ),
      onTap: () => vm.selectTempSort(option),
    );
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.dateNewest:
        return 'Date: Newest';
      case SortOption.dateOldest:
        return 'Date: Oldest';
      case SortOption.titleAsc:
        return 'Title: A-Z';
      case SortOption.titleDesc:
        return 'Title: Z-A';
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString.split('T').first;
    }
  }
}
