import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sorting_filtering.dart';
import 'home_view_model.dart';

const _sortLabels = {
  SortOrder.dateDescending: 'Date, Newest',
  SortOrder.dateAscending: 'Date, Oldest',
  SortOrder.titleAscending: 'Title, A-Z',
  SortOrder.titleDescending: 'Title, Z-A',
};

/// A full-screen panel that REPLACES the list while open (cross-framework-setup.md §D.2/§D.3):
/// the descending-date label deliberately ENDS with "Newest" so it satisfies the AC-SORT-01
/// flow's full-string regex `(?i)date.*(desc|newest)`.
class SortScreen extends ConsumerStatefulWidget {
  const SortScreen({super.key});

  @override
  ConsumerState<SortScreen> createState() => _SortScreenState();
}

class _SortScreenState extends ConsumerState<SortScreen> {
  late SortOrder _selected = ref.read(homeViewModelProvider.notifier).sortOrder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_sort',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sort')),
        body: ListView(
          children: [
            for (final order in SortOrder.values)
              RadioListTile<SortOrder>(
                title: Text(_sortLabels[order]!),
                value: order,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
              ),
          ],
        ),
        floatingActionButton: Semantics(
          identifier: 'sort_apply_button',
          button: true,
          container: true,
          child: FloatingActionButton.extended(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).setSort(_selected);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check),
            label: const Text('Apply'),
          ),
        ),
      ),
    );
  }
}
