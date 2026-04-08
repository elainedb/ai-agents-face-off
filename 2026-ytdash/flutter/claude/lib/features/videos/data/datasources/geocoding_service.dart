import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class GeocodingService {
  final http.Client _client;
  final Map<String, (String?, String?)> _cache = {};
  int _activeRequests = 0;
  static const int _maxConcurrency = 5;
  DateTime? _lastNominatimRequest;

  GeocodingService(this._client);

  String _cacheKey(double lat, double lng) {
    return '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  }

  Future<(String?, String?)> reverseGeocode(double latitude, double longitude,
      {String? locationDescription}) async {
    final key = _cacheKey(latitude, longitude);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Wait for concurrency slot
    while (_activeRequests >= _maxConcurrency) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _activeRequests++;

    try {
      final result = await _tryPlatformGeocoder(latitude, longitude);
      if (result != null) {
        _cache[key] = result;
        return result;
      }
    } catch (_) {
      // Fall through to Nominatim
    } finally {
      _activeRequests--;
    }

    // Fallback: Nominatim
    _activeRequests++;
    try {
      final result = await _tryNominatim(latitude, longitude);
      if (result != null) {
        _cache[key] = result;
        return result;
      }
    } catch (_) {
      // Fall through to description parsing
    } finally {
      _activeRequests--;
    }

    // Fallback: parse locationDescription
    if (locationDescription != null) {
      final result = _parseLocationDescription(locationDescription);
      _cache[key] = result;
      return result;
    }

    final fallback = (null, null) as (String?, String?);
    _cache[key] = fallback;
    return fallback;
  }

  Future<(String?, String?)?> _tryPlatformGeocoder(
      double latitude, double longitude) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final placemarks =
            await geo.placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ??
              place.subLocality ??
              place.administrativeArea ??
              place.name;
          return (city, place.country);
        }
        return null;
      } catch (_) {
        if (attempt < 2) {
          await Future.delayed(
              Duration(milliseconds: 500 * (1 << attempt)));
        }
      }
    }
    return null;
  }

  Future<(String?, String?)?> _tryNominatim(
      double latitude, double longitude) async {
    // Respect Nominatim rate limit
    if (_lastNominatimRequest != null) {
      final elapsed = DateTime.now().difference(_lastNominatimRequest!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future.delayed(const Duration(seconds: 1) - elapsed);
      }
    }

    _lastNominatimRequest = DateTime.now();
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude');
    final response = await _client.get(uri, headers: {
      'User-Agent': 'dev.elainedb.ytdash_flutter_claude/1.0',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address != null) {
        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['state'];
        final country = address['country'];
        return (city?.toString(), country?.toString());
      }
    }
    return null;
  }

  (String?, String?) _parseLocationDescription(String description) {
    final match = RegExp(r'^(.+),\s*(.+)$').firstMatch(description);
    if (match != null) {
      return (match.group(1)?.trim(), match.group(2)?.trim());
    }
    return (null, null);
  }
}
