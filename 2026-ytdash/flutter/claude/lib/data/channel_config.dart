import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A configured source channel to aggregate (config/channels.json). `label` is the user-facing
/// category attached to every video fetched from this channel (youtube-api.md mapping).
class SourceChannel {
  const SourceChannel({required this.id, required this.label});
  final String id;
  final String label;

  factory SourceChannel.fromJson(Map<String, dynamic> json) =>
      SourceChannel(id: json['id'] as String, label: json['label'] as String);
}

/// Loads the configured channel set bundled as an asset. There is NO catch-all endpoint — the
/// repository iterates every channel and merges/dedupes (youtube-api.md).
Future<List<SourceChannel>> loadChannels() async {
  final raw = await rootBundle.loadString('assets/channels.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => SourceChannel.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}
