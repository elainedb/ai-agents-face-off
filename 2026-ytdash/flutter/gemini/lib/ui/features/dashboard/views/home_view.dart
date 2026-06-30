import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/test_config.dart';
import '../../../../domain/models/video.dart';
import '../../../core/utils/link_launcher.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/dashboard_view_model.dart';
import '../../map/views/map_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardViewModel = context.read<DashboardViewModel>();
      final testConfig = context.read<TestConfig>();
      dashboardViewModel.loadVideos(testConfig);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final testConfig = context.read<TestConfig>();

    return Semantics(
      identifier: 'screen_home',
      container: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0C20), // Premium Dark
        appBar: AppBar(
          backgroundColor: const Color(0xFF15102A),
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YT Dash',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              // video_count Semantics identifier
              Semantics(
                identifier: 'video_count',
                container: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF0000).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${dashboardViewModel.filteredVideos.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Map button
            Semantics(
              identifier: 'map_nav_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map_rounded, color: Colors.white),
                tooltip: 'Map View',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapView()),
                  );
                },
              ),
            ),
            // Filter button
            Semantics(
              identifier: 'filter_button',
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: dashboardViewModel.selectedCategory != null ? const Color(0xFFFF3B30) : Colors.white,
                ),
                tooltip: 'Filter Category',
                onPressed: () {
                  dashboardViewModel.toggleFilterPanel();
                },
              ),
            ),
            // Sort button
            Semantics(
              identifier: 'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                tooltip: 'Sort List',
                onPressed: () {
                  dashboardViewModel.toggleSortPanel();
                },
              ),
            ),
            // Logout button
            Semantics(
              identifier: 'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await authViewModel.logout(testConfig);
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            Positioned.fill(
              child: _buildBody(context, dashboardViewModel, testConfig),
            ),

            // Top-level captured URL banner (globally positioned overlay)
            if (dashboardViewModel.capturedUrl != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Semantics(
                  identifier: 'external_open_url',
                  container: true,
                  child: Container(
                    color: const Color(0xFF1E3A8A), // Rich deep blue
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dashboardViewModel.capturedUrl!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              dashboardViewModel.clearCapturedUrl();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Top-level deep-link error banner (globally positioned overlay)
            if (dashboardViewModel.externalOpenError != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Semantics(
                  identifier: 'external_open_error',
                  container: true,
                  child: Container(
                    color: const Color(0xFF7F1D1D), // Dark crimson red
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dashboardViewModel.externalOpenError!,
                              style: const TextStyle(
                                color: Color(0xFFFECACA),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              dashboardViewModel.clearExternalOpenError();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardViewModel dashboardViewModel,
    TestConfig testConfig,
  ) {
    if (dashboardViewModel.isLoading) {
      return Semantics(
        identifier: 'loading_indicator',
        container: true,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF0000),
          ),
        ),
      );
    }

    if (dashboardViewModel.errorMessage != null && dashboardViewModel.allVideos.isEmpty) {
      return Semantics(
        identifier: 'error_view',
        container: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  dashboardViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Semantics(
                  identifier: 'error_retry_button',
                  button: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => dashboardViewModel.loadVideos(testConfig, forceRefresh: true),
                    child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rule D.2: If the Filter panel is open, completely REPLACE the list view
    if (dashboardViewModel.isFilterPanelOpen) {
      return _buildFilterPanel(context, dashboardViewModel);
    }

    // Rule D.2: If the Sort panel is open, completely REPLACE the list view
    if (dashboardViewModel.isSortPanelOpen) {
      return _buildSortPanel(context, dashboardViewModel);
    }

    // Default view: video_list Scrollable Container
    if (dashboardViewModel.filteredVideos.isEmpty) {
      return const Center(
        child: Text(
          'No videos match your criteria.',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      );
    }

    return Semantics(
      identifier: 'refresh_control',
      container: true,
      child: RefreshIndicator(
        onRefresh: () => dashboardViewModel.loadVideos(testConfig, forceRefresh: true),
        color: const Color(0xFFFF0000),
        child: Semantics(
          identifier: 'video_list',
          container: true,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            cacheExtent: 10000,
            itemCount: dashboardViewModel.filteredVideos.length,
            itemBuilder: (context, index) {
              final video = dashboardViewModel.filteredVideos[index];
              return _buildVideoTile(context, video, dashboardViewModel, testConfig);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTile(
    BuildContext context,
    Video video,
    DashboardViewModel dashboardViewModel,
    TestConfig testConfig,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF15102A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await LinkLauncher.launch(
            video.youtubeUrl,
            testConfig: testConfig,
            dashboardViewModel: dashboardViewModel,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Rounded compact thumbnail with category tag overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 56,
                      child: video.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.black26,
                                child: const Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 24),
                              ),
                            )
                          : Container(color: Colors.black26),
                    ),
                  ),
                  if (video.latitude != null && video.longitude != null)
                    const Positioned(
                      bottom: 4,
                      left: 4,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xCC000000),
                        child: Icon(Icons.location_on_rounded, color: Color(0xFFFF3B30), size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Right: Title, description, category, date
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
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            video.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_rounded, color: Colors.white30, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(video.publishedAt),
                          style: const TextStyle(color: Colors.white30, fontSize: 10),
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

  Widget _buildFilterPanel(BuildContext context, DashboardViewModel dashboardViewModel) {
    String? localSelected = dashboardViewModel.selectedCategory;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => dashboardViewModel.setFilterPanelOpen(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: dashboardViewModel.categories.length,
                  itemBuilder: (context, index) {
                    final cat = dashboardViewModel.categories[index];
                    final isSel = (cat == 'All' && localSelected == null) || (localSelected == cat);

                    return Card(
                      color: isSel ? const Color(0xFFFF0000).withOpacity(0.15) : const Color(0xFF15102A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFFF0000).withOpacity(0.4) : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          cat,
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF3B30))
                            : const Icon(Icons.circle_outlined, color: Colors.white24),
                        onTap: () {
                          setLocalState(() {
                            localSelected = (cat == 'All') ? null : cat;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                identifier: 'filter_apply_button',
                button: true,
                container: true,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      dashboardViewModel.selectCategory(localSelected);
                      dashboardViewModel.applyFilter();
                    },
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortPanel(BuildContext context, DashboardViewModel dashboardViewModel) {
    String localSelected = dashboardViewModel.selectedSort;

    final List<Map<String, String>> sortOptions = [
      {'key': 'date_desc', 'label': 'Date — desc'},
      {'key': 'date_asc', 'label': 'Date — asc'},
      {'key': 'title_asc', 'label': 'Title — asc'},
    ];

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Videos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => dashboardViewModel.setSortPanelOpen(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortOptions.length,
                  itemBuilder: (context, index) {
                    final opt = sortOptions[index];
                    final isSel = localSelected == opt['key'];

                    return Card(
                      color: isSel ? const Color(0xFFFF0000).withOpacity(0.15) : const Color(0xFF15102A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFFF0000).withOpacity(0.4) : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          opt['label']!,
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF3B30))
                            : const Icon(Icons.circle_outlined, color: Colors.white24),
                        onTap: () {
                          setLocalState(() {
                            localSelected = opt['key']!;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                identifier: 'sort_apply_button',
                button: true,
                container: true,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      dashboardViewModel.selectSort(localSelected);
                      dashboardViewModel.applySort();
                    },
                    child: const Text(
                      'Apply Sort',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoString;
    }
  }
}
