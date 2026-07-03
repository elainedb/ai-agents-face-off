import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final Map<String, String> _cache = {};

  /// Performs reverse geocoding using OSM Nominatim API.
  /// Uses a 3-decimal coord cache, appropriate User-Agent, and falls back gracefully.
  Future<String> reverseGeocode(double lat, double lng, {bool uiTestMode = false}) async {
    final String cacheKey = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    if (uiTestMode) {
      final mockVal = 'Location: ${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}';
      _cache[cacheKey] = mockVal;
      return mockVal;
    }

    final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'ytdash-flutter/1.0.0 (com.example.ytdash_flutter; contact: admin@example.com)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Parse a readable name (town, city, county, country)
        final String? displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Shorten display name to first 3 segments to fit nicely in UI
          final segments = displayName.split(',');
          final shortName = segments.take(3).map((s) => s.trim()).join(', ');
          _cache[cacheKey] = shortName;
          return shortName;
        }

        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final String? city = address['city'] as String? ?? 
                               address['town'] as String? ?? 
                               address['village'] as String? ?? 
                               address['suburb'] as String?;
          final String? country = address['country'] as String?;
          if (city != null && country != null) {
            final name = '$city, $country';
            _cache[cacheKey] = name;
            return name;
          } else if (country != null) {
            _cache[cacheKey] = country;
            return country;
          }
        }
      }
    } catch (e) {
      print('Reverse geocoding error for ($lat, $lng): $e');
    }

    // Default fallback name
    final fallback = 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    _cache[cacheKey] = fallback;
    return fallback;
  }
}
