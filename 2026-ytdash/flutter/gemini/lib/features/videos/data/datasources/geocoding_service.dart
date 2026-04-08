import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class GeocodingService {
  final http.Client httpClient;
  
  // Cache format: rounded_lat_lng -> (City, Country)
  final Map<String, (String?, String?)> _cache = {};
  
  GeocodingService(this.httpClient);

  String _getCacheKey(double lat, double lng) {
    return '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  }

  Future<(String?, String?)> reverseGeocode(double lat, double lng, {String? locationDescriptionFallback}) async {
    final cacheKey = _getCacheKey(lat, lng);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    (String?, String?) result = (null, null);

    // 1. Platform Geocoder
    try {
      result = await _tryPlatformGeocoding(lat, lng);
    } catch (_) {}

    // 2. Nominatim Fallback
    if (result.$1 == null && result.$2 == null) {
      try {
        result = await _tryNominatimGeocoding(lat, lng);
      } catch (_) {}
    }

    // 3. Regex Fallback from locationDescription
    if (result.$1 == null && result.$2 == null && locationDescriptionFallback != null) {
      result = _parseLocationDescription(locationDescriptionFallback);
    }

    _cache[cacheKey] = result;
    return result;
  }

  Future<(String?, String?)> _tryPlatformGeocoding(double lat, double lng) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ?? place.subLocality ?? place.administrativeArea ?? place.name;
          final country = place.country;
          return (city, country);
        }
        break;
      } catch (e) {
        attempts++;
        if (attempts >= 3) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * (1 << (attempts - 1))));
      }
    }
    return (null, null);
  }

  Future<(String?, String?)> _tryNominatimGeocoding(double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 1)); // Rate limit
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng');
    
    final response = await httpClient.get(url, headers: {
      'User-Agent': 'dev.elainedb.ytdash_flutter_gemini/1.0',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['address'] as Map<String, dynamic>?;
      if (address != null) {
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'];
        final country = address['country'];
        return (city?.toString(), country?.toString());
      }
    }
    return (null, null);
  }

  (String?, String?) _parseLocationDescription(String description) {
    // Basic regex fallback for "City, Country"
    final parts = description.split(',');
    if (parts.length >= 2) {
      return (parts[0].trim(), parts[1].trim());
    }
    return (description.trim(), null);
  }
}
