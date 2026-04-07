import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:geocoding/geocoding.dart';

@lazySingleton
class GeocodingService {
  final http.Client client;
  final Map<String, (String?, String?)> _cache = {};

  GeocodingService(this.client);

  String _getCacheKey(double lat, double lon) {
    return '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';
  }

  Future<(String?, String?)> getCityAndCountry(double lat, double lon) async {
    final cacheKey = _getCacheKey(lat, lon);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    (String?, String?) result = (null, null);

    try {
      // 1. Try platform geocoder (with basic retry logic)
      result = await _tryPlatformGeocoder(lat, lon);
    } catch (e) {
      // 2. Fallback to OpenStreetMap Nominatim
      try {
        result = await _tryNominatim(lat, lon);
      } catch (e) {
        // Log fallback error or ignore
      }
    }

    _cache[cacheKey] = result;
    return result;
  }

  Future<(String?, String?)> _tryPlatformGeocoder(double lat, double lon) async {
    int retries = 3;
    int delay = 500;
    while (retries > 0) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ?? place.subLocality ?? place.administrativeArea ?? place.name;
          final country = place.country;
          return (city, country);
        }
        break;
      } catch (e) {
        retries--;
        if (retries == 0) rethrow;
        await Future.delayed(Duration(milliseconds: delay));
        delay *= 2;
      }
    }
    return (null, null);
  }

  Future<(String?, String?)> _tryNominatim(double lat, double lon) async {
    await Future.delayed(const Duration(seconds: 1)); // Nominatim policy
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
    final response = await client.get(url, headers: {
      'User-Agent': 'dev.elainedb.ytdash_flutter_gemini/1.0',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['address'] != null) {
        final address = data['address'];
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'];
        final country = address['country'];
        return (city as String?, country as String?);
        }
        }
        return (null as String?, null as String?);  }

  (String?, String?) parseLocationFromDescription(String description) {
    // Basic regex for City, Country
    final regex = RegExp(r'([A-Z][a-zA-Z\s]+),\s*([A-Z][a-zA-Z\s]+)');
    final match = regex.firstMatch(description);
    if (match != null) {
      return (match.group(1)?.trim(), match.group(2)?.trim());
    }
    return (null as String?, null as String?);
  }
}
