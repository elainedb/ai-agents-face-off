import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final http.Client _client;
  final Map<String, String> _cache = {};
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> reverseGeocode(double lat, double lng) async {
    // Cache key with 3-decimal precision
    final cacheKey = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Nominatim usage policy requires rate limiting to 1 request per second
    final now = DateTime.now();
    final difference = now.difference(_lastRequestTime);
    if (difference.inMilliseconds < 1000) {
      await Future<void>.delayed(Duration(milliseconds: 1000 - difference.inMilliseconds));
    }

    _lastRequestTime = DateTime.now();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=en',
      );
      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'ytdash_flutter/1.0 (user1@example.com)',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final String? displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Keep it reasonably short
          final parts = displayName.split(',');
          final shortName = parts.length > 3
              ? '${parts[0].trim()}, ${parts[1].trim()}, ${parts[2].trim()}'
              : displayName;
          _cache[cacheKey] = shortName;
          return shortName;
        }
      }
    } catch (_) {
      // Ignore errors and fallback
    }

    return 'Location ($cacheKey)';
  }
}
