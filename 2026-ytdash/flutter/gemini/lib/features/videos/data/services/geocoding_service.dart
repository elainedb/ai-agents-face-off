import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class GeocodingService {
  final http.Client client;
  final Map<String, (String?, String?)> _cache = {};
  
  int _activeRequests = 0;
  final int _maxConcurrency = 5;
  final List<Completer<void>> _queue = [];

  GeocodingService(this.client);

  Future<(String?, String?)> getCityAndCountry(double latitude, double longitude, {String? locationDescription}) async {
    final latRounded = (latitude * 1000).roundToDouble() / 1000;
    final lonRounded = (longitude * 1000).roundToDouble() / 1000;
    final cacheKey = '$latRounded,$lonRounded';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    if (_activeRequests >= _maxConcurrency) {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;
    }
    
    _activeRequests++;

    try {
      final result = await _resolveWithRetries(latitude, longitude, locationDescription);
      _cache[cacheKey] = result;
      return result;
    } finally {
      _activeRequests--;
      if (_queue.isNotEmpty) {
        final next = _queue.removeAt(0);
        next.complete();
      }
    }
  }

  Future<(String?, String?)> _resolveWithRetries(double lat, double lon, String? locationDescription) async {
    final backoffs = [const Duration(milliseconds: 500), const Duration(seconds: 1), const Duration(seconds: 2)];
    
    for (int i = 0; i <= backoffs.length; i++) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ?? place.subLocality ?? place.administrativeArea ?? place.name;
          final country = place.country;
          if (city != null || country != null) {
            return (city, country);
          }
        }
        break; // If no exception but empty, break to try fallback
      } catch (e) {
        if (i < backoffs.length) {
          await Future.delayed(backoffs[i]);
        }
      }
    }

    // Fallback to nominatim
    try {
      await Future.delayed(const Duration(seconds: 1)); // Nominatim policy minimum delay
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
      final response = await client.get(url, headers: {'User-Agent': 'dev.elainedb.ytdash_flutter_gemini/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'];
          final country = address['country'];
          return (city as String?, country as String?);
        }
      }
    } catch (_) {
    }

    // Fallback to locationDescription regex
    if (locationDescription != null) {
      final match = RegExp(r'^([^,]+),\s*([^,]+)$').firstMatch(locationDescription);
      if (match != null) {
        return (match.group(1)?.trim(), match.group(2)?.trim());
      }
    }

    return (null, null);
  }
}
