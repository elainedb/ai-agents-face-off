import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A configured source channel to aggregate.
class SourceChannel {
  const SourceChannel({required this.id, required this.label});
  final String id;
  final String label;
}

/// Static app configuration: the set of source channels (bundled asset) and the
/// default production whitelist. Both are overridable at runtime (the whitelist
/// via the `authorizedEmails` extra). No secrets live here — the API key arrives
/// at runtime via the `apiKey` extra (constitution §4) or production config.
class AppConfig {
  /// Default production base host. The app appends `/youtube/v3/...` itself.
  static const String defaultApiBaseUrl = 'https://www.googleapis.com';

  /// Default production whitelist (overridable via the `authorizedEmails` extra).
  static const List<String> defaultAuthorizedEmails = [
    'user1@example.com',
    'user2@example.com',
  ];

  static List<SourceChannel>? _cached;

  /// Load and cache `config/channels.json` (bundled asset).
  static Future<List<SourceChannel>> loadChannels() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('config/channels.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => SourceChannel(
              id: (e['id'] as String),
              label: (e['label'] as String?) ?? '',
            ))
        .where((c) => c.id.isNotEmpty)
        .toList();
    _cached = list;
    return list;
  }
}
