import 'package:flutter/material.dart';

/// Wraps a leaf/interactive widget with a stable, localization-independent
/// `identifier` (constitution §3). Uses [Semantics.identifier] (Flutter 3.19+),
/// surfaced to Maestro as the element `id`. [label] carries the text that
/// `text:` assertions match. `excludeSemantics` collapses the subtree into a
/// single node so the id and its text resolve to the same element — including
/// inside popups/sheets, which need their own id exposure (constitution §5a).
class Identified extends StatelessWidget {
  const Identified(
    this.id, {
    required this.child,
    this.label,
    this.button = false,
    this.onTap,
    super.key,
  });

  final String id;
  final Widget child;
  final String? label;
  final bool button;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: id,
      label: label,
      button: button,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Marks a screen/container root with a stable `identifier` while keeping its
/// descendants individually addressable (so `video_list`, rows, buttons, etc.
/// remain matchable beneath it).
class IdentifiedScope extends StatelessWidget {
  const IdentifiedScope(this.id, {required this.child, super.key});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: id,
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }
}
