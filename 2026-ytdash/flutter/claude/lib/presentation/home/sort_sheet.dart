import 'package:flutter/material.dart';

import '../../domain/sorting/video_sort.dart';

/// Sort options panel. Replaces the video list while open, same rationale as [FilterSheet].
class SortSheet extends StatefulWidget {
  const SortSheet({super.key, required this.current, required this.onApply});

  final SortKey? current;
  final ValueChanged<SortKey> onApply;

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  late SortKey _selected = widget.current ?? SortKey.dateDesc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sort by',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final key in SortKey.values)
                RadioListTile<SortKey>(
                  title: Text(sortKeyLabel(key)),
                  value: key,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v!),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Semantics(
            container: true,
            identifier: 'sort_apply_button',
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
