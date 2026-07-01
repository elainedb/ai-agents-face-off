import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sorting/video_sort.dart';
import '../../state/providers.dart';

const _sortLabels = <SortOption, String>{
  // Labels are chosen to satisfy Maestro's full-string `matches()` regex used by AC-SORT-01
  // ("(?i)date.*(desc|newest)" — no wildcards at the string boundaries): the label must both START
  // with "Date" and END with "Newest"/"desc" verbatim (cross-framework-setup.md §D.3).
  SortOption.dateNewest: 'Date - Newest',
  SortOption.dateOldest: 'Date - Oldest',
  SortOption.titleAToZ: 'Title A-Z',
  SortOption.titleZToA: 'Title Z-A',
};

/// Pushed as its own route so it fully replaces the list while open (cross-framework-setup.md §D.2).
class SortScreen extends ConsumerWidget {
  const SortScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Sort')),
      body: ListView(
        children: [
          for (final option in SortOption.values)
            ListTile(
              title: Text(_sortLabels[option]!),
              trailing: state.sortOption == option
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                controller.applySort(option);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
