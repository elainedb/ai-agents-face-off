import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A YouTube source channel to aggregate, with its user-facing category label.
class SourceChannel {
  const SourceChannel({required this.id, required this.label});

  final String id;

  /// User-facing category label (constitution: "category" = source-channel label).
  final String label;

  factory SourceChannel.fromJson(Map<String, dynamic> json) => SourceChannel(
        id: (json['id'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

/// Static, build-time configuration that is not a secret.
class AppConfig {
  const AppConfig({required this.channels, required this.fallbackApiKey, required this.fallbackBaseUrl});

  final List<SourceChannel> channels;

  /// Production defaults, used only outside UI-test-mode (when no extras arrive).
  /// The real key is supplied via --dart-define / launch extra, never committed.
  final String fallbackApiKey;
  final String fallbackBaseUrl;

  /// Loads the configured source channels from the bundled asset.
  static Future<AppConfig> load() async {
    final raw = await rootBundle.loadString('config/channels.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => SourceChannel.fromJson(e as Map<String, dynamic>))
        .where((c) => c.id.isNotEmpty)
        .toList();
    return AppConfig(
      channels: list,
      fallbackApiKey: const String.fromEnvironment('YOUTUBE_API_KEY'),
      fallbackBaseUrl: 'https://www.googleapis.com',
    );
  }
}
