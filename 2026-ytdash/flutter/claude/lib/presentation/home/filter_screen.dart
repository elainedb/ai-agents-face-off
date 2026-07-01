import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'home_view_model.dart';

/// A full-screen panel that REPLACES the list while open (cross-framework-setup.md §D.2) — this
/// avoids a black-box driver confusing a filter option's text with a matching video title still
/// visible behind it.
class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late String? _selected = ref
      .read(homeViewModelProvider.notifier)
      .filterCategory;

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider);
    return Semantics(
      identifier: 'screen_filter',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Filter')),
        body: channelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('$e')),
          data: (channels) => ListView(
            children: [
              RadioListTile<String?>(
                title: const Text('All'),
                value: null,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
              ),
              for (final channel in channels)
                RadioListTile<String?>(
                  title: Text(channel.label),
                  value: channel.label,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                ),
            ],
          ),
        ),
        floatingActionButton: Semantics(
          identifier: 'filter_apply_button',
          button: true,
          container: true,
          child: FloatingActionButton.extended(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).setFilter(_selected);
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
