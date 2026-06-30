import 'package:flutter/widgets.dart';

/// Wraps a widget with a stable, localization-independent automation identifier
/// (constitution §3). Uses the Flutter `Semantics.identifier` field (not `label`) so Maestro sees
/// it as the element `id`. For asserted rows we also merge descendant text so a single node carries
/// both the id and its title (cross-framework-setup §D.4).
class TestId extends StatelessWidget {
  const TestId(
    this.id, {
    super.key,
    required this.child,
    this.button = false,
    this.merge = false,
    this.container = false,
  });

  final String id;
  final Widget child;
  final bool button;
  final bool merge;
  final bool container;

  @override
  Widget build(BuildContext context) {
    final semantics = Semantics(
      identifier: id,
      button: button,
      container: container,
      child: child,
    );
    // Flutter puts a widget's clickable/text semantics on its OWN node, separate from an ancestor
    // `identifier` node — so Maestro sees the label but no `id`. Merging collapses them into a
    // single node that carries BOTH the identifier and the text/clickable (verified on-device).
    // Large container nodes (screens, the list) must stay un-merged so their children remain
    // individually addressable.
    final shouldMerge = merge || !container;
    return shouldMerge ? MergeSemantics(child: semantics) : semantics;
  }
}
