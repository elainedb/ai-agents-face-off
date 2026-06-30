import 'package:flutter/widgets.dart';

/// Stable Maestro selectors (constitution §3). Flutter surfaces a Semantics
/// `identifier` to the device automation layer as the element's `resource-id`.
///
/// Two helpers, because the merging rules differ:
///
/// * [IdNode] — a STRUCTURAL / interactive element whose id matters but whose
///   text does not need to co-locate on the same node. It uses
///   `explicitChildNodes: true` so the id node is preserved as its own node and
///   is NOT swallowed/merged into an ancestor (the bug that drops nested ids).
///
/// * [IdText] — a node that must carry BOTH its id AND its visible text on the
///   SAME node (so `assertVisible id:x text:"..."` resolves to one node, e.g.
///   `video_list_item`, `video_count`, `detail_video_url`). It sets the text as
///   the semantics `label` and excludes the child subtree's semantics so exactly
///   one leaf node carries id + text. Gestures on the child still work
///   (ExcludeSemantics removes semantics, not hit-testing).
class IdNode extends StatelessWidget {
  const IdNode(this.id, {super.key, required this.child, this.button = false});

  final String id;
  final Widget child;
  final bool button;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: id,
      button: button,
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }
}

class IdText extends StatelessWidget {
  const IdText(
    this.id, {
    super.key,
    required this.text,
    required this.child,
    this.button = false,
  });

  final String id;
  final String text;
  final Widget child;
  final bool button;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: id,
      label: text,
      button: button,
      container: true,
      child: ExcludeSemantics(child: child),
    );
  }
}
