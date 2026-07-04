import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers.dart';
import '../test_config.dart';
import 'map_screen.dart';

final externalUrlProvider = StateProvider<String?>((ref) => null);
final externalErrorProvider = StateProvider<String?>((ref) => null);

Future<void> openExternalUrl(WidgetRef ref, String url) async {
  if (TestConfig.instance.captureExternalLinks) {
    ref.read(externalUrlProvider.notifier).state = url;
  } else {
    try {
      final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!launched) {
        ref.read(externalErrorProvider.notifier).state = 'Could not launch $url';
      }
    } catch (e) {
      ref.read(externalErrorProvider.notifier).state = 'Could not launch $url';
    }
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoListProvider);

    return Semantics(
      identifier: 'screen_home',
      container: true,
      explicitChildNodes: true,
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            identifier: 'video_count',
            container: true,
            child: Text('Videos: ${state.videos.length}'),
          ),
          actions: [
            Semantics(
              identifier: 'map_nav_button',
              container: true,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
              ),
            ),
            Semantics(
              identifier: 'filter_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, ref, state),
              ),
            ),
            Semantics(
              identifier: 'sort_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortDialog(context, ref),
              ),
            ),
            Semantics(
              identifier: 'logout_button',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  ref.read(authStateProvider.notifier).state = false;
                },
              ),
            ),
          ],
        ),
        body: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, VideoListState state) {
    if (state.isLoading && state.videos.isEmpty) {
      return Semantics(
        identifier: 'loading_indicator',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.videos.isEmpty) {
      return Semantics(
        identifier: 'error_view',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error!),
              Semantics(
                identifier: 'error_retry_button',
                button: true,
                child: ElevatedButton(
                  onPressed: () => ref.read(videoListProvider.notifier).load(force: true),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videos = state.visibleVideos;
    final externalUrl = ref.watch(externalUrlProvider);

    return Stack(
      children: [
        Semantics(
          identifier: 'refresh_control',
          child: RefreshIndicator(
            onRefresh: () => ref.read(videoListProvider.notifier).load(force: true),
            child: Semantics(
              identifier: 'video_list',
              container: true,
              explicitChildNodes: true,
              child: ListView.builder(
                key: const Key('video_list'),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return Semantics(
                    identifier: 'video_list_item',
                    container: true,
                    child: ListTile(
                      leading: video.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              video.thumbnailUrl,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(width: 100, child: Icon(Icons.broken_image));
                              },
                            )
                          : const SizedBox(width: 100, height: 60),
                      title: Text(video.title),
                      subtitle: Text(video.description),
                      onTap: () {
                        openExternalUrl(ref, video.youtubeUrl);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (externalUrl != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Semantics(
              identifier: 'external_open_url',
              container: true,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16),
                child: Text(externalUrl, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref, VideoListState state) {
    final categories = state.videos.map((v) => v.category).toSet().toList()..sort();
    
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Filter')),
          body: ListView(
            children: [
              ...categories.map((category) => ListTile(
                title: Text(category),
                onTap: () {
                  ref.read(videoListProvider.notifier).setFilter(category);
                  _applyAndPop(context);
                },
              )),
              ListTile(
                title: const Text('Clear Filter'),
                onTap: () {
                  ref.read(videoListProvider.notifier).setFilter(null);
                  _applyAndPop(context);
                },
              ),
            ],
          ),
        );
      },
    ));
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sort')),
          body: Column(
            children: [
              ListTile(
                title: const Text('Date newest'),
                onTap: () {
                  ref.read(videoListProvider.notifier).setSort(dateDesc: true);
                  _applyAndPop(context);
                },
              ),
              ListTile(
                title: const Text('Date oldest'),
                onTap: () {
                  ref.read(videoListProvider.notifier).setSort(dateDesc: false);
                  _applyAndPop(context);
                },
              ),
            ],
          ),
        );
      },
    ));
  }

  void _applyAndPop(BuildContext context) {
    // The ACs look for `filter_apply_button` and `sort_apply_button` (optional if instant, but let's provide them if we have to, wait... "Confirms a sort (omit only if sorting applies instantly)")
    // So we can omit the apply buttons.
    Navigator.of(context).pop();
  }
}
