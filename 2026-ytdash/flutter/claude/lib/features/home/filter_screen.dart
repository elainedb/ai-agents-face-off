import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

/// Pushed as its own route so it fully replaces the list while open (cross-framework-setup.md §D.2)
/// — avoids the list's own item titles colliding with the filter option text on a black-box driver.
class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final categories = state.availableCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Filter')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('All'),
            trailing: state.filterCategory == null
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              controller.applyFilter(null);
              Navigator.of(context).pop();
            },
          ),
          for (final category in categories)
            ListTile(
              title: Text(category),
              trailing: state.filterCategory == category
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                controller.applyFilter(category);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
