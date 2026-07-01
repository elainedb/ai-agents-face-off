import 'package:flutter/material.dart';

/// Filter options panel. Replaces the video list while open (rather than overlaying it) so the
/// option labels (plain category names, e.g. "cronicas") don't collide with list-item titles that
/// might contain the same word — see cross-framework-setup.md §D.2.
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.categories,
    required this.current,
    required this.onApply,
  });

  final List<String> categories;
  final String? current;
  final ValueChanged<String?> onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Filter by category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              RadioListTile<String?>(
                title: const Text('All'),
                value: null,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
              ),
              for (final category in widget.categories)
                RadioListTile<String?>(
                  title: Text(category),
                  value: category,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Semantics(
            container: true,
            identifier: 'filter_apply_button',
            button: true,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selected),
              child: const Text('Apply'),
            ),
          ),
        ),
      ],
    );
  }
}
