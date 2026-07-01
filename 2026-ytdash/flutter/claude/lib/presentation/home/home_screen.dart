import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_notifier.dart';
import '../map/map_screen.dart';
import 'filter_screen.dart';
import 'home_view_model.dart';
import 'home_view_state.dart';
import 'sort_screen.dart';
import 'video_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Semantics(
      identifier: 'screen_home',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: _Title(state: state),
          actions: [
            Semantics(
              identifier: 'refresh_control',
              button: true,
              container: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: viewModel.refresh,
              ),
            ),
            Semantics(
              identifier: 'filter_button',
              button: true,
              container: true,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const FilterScreen())),
              ),
            ),
            Semantics(
              identifier: 'sort_button',
              button: true,
              container: true,
              child: IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SortScreen())),
              ),
            ),
            Semantics(
              identifier: 'map_nav_button',
              button: true,
              container: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                tooltip: 'Map',
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
              ),
            ),
            Semantics(
              identifier: 'logout_button',
              button: true,
              container: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
        body: _Body(state: state, onRetry: viewModel.refresh),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.state});

  final HomeViewState state;

  @override
  Widget build(BuildContext context) {
    final count = switch (state) {
      HomeContent(:final totalCount) => totalCount,
      HomeEmpty() => 0,
      _ => null,
    };
    if (count == null) return const Text('Videos');
    return Semantics(
      identifier: 'video_count',
      container: true,
      child: Text('Videos ($count)'),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onRetry});

  final HomeViewState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      HomeLoading() => Center(
        child: Semantics(
          identifier: 'loading_indicator',
          container: true,
          child: const CircularProgressIndicator(),
        ),
      ),
      HomeError(:final message) => Center(
        child: Semantics(
          identifier: 'error_view',
          container: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(message, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              Semantics(
                identifier: 'error_retry_button',
                button: true,
                container: true,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      HomeEmpty() => const Center(child: Text('No videos found.')),
      HomeContent(:final displayedVideos) => Semantics(
        identifier: 'video_list',
        container: true,
        child: RefreshIndicator(
          onRefresh: onRetry,
          child: displayedVideos.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No videos match this filter.'),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: displayedVideos.length,
                  itemBuilder: (context, index) =>
                      VideoListItem(video: displayedVideos[index]),
                ),
        ),
      ),
    };
  }
}
