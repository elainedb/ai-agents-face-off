import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton()
class GeocodingService {
  final http.Client _httpClient;
  final Map<String, (String?, String?)> _cache = {};
  static const int _maxConcurrency = 5;
  static const int _maxRetries = 3;

  GeocodingService(this._httpClient);

  String _cacheKey(double lat, double lng) {
    return '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  }

  Future<(String?, String?)> reverseGeocode(
    double latitude,
    double longitude, {
    String? locationDescription,
  }) async {
    final key = _cacheKey(latitude, longitude);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Try platform geocoder first
    var result = await _tryPlatformGeocoder(latitude, longitude);
    if (result != null) {
      _cache[key] = result;
      return result;
    }

    // Fall back to Nominatim
    result = await _tryNominatim(latitude, longitude);
    if (result != null) {
      _cache[key] = result;
      return result;
    }

    // Fall back to parsing location description
    if (locationDescription != null) {
      result = _parseLocationDescription(locationDescription);
      if (result != null) {
        _cache[key] = result;
        return result;
      }
    }

    final fallback = (null as String?, null as String?);
    _cache[key] = fallback;
    return fallback;
  }

  Future<(String?, String?)?> _tryPlatformGeocoder(
    double latitude,
    double longitude,
  ) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final placemarks = await geo.placemarkFromCoordinates(
          latitude,
          longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality ??
              place.subLocality ??
              place.administrativeArea ??
              place.name;
          final country = place.country;
          return (city, country);
        }
        return null;
      } catch (_) {
        if (attempt < _maxRetries - 1) {
          await Future.delayed(
            Duration(milliseconds: 500 * (1 << attempt)),
          );
        }
      }
    }
    return null;
  }

  Future<(String?, String?)?> _tryNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
      );
      final response = await _httpClient.get(
        uri,
        headers: {
          'User-Agent': 'dev.elainedb.ytdash_flutter_claude/1.0',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'];
          final country = address['country'];
          return (city as String?, country as String?);
        }
      }
    } catch (_) {
      // Fall through to next fallback
    }
    return null;
  }

  (String?, String?)? _parseLocationDescription(String description) {
    final match = RegExp(r'^(.+),\s*(.+)$').firstMatch(description);
    if (match != null) {
      return (match.group(1)?.trim(), match.group(2)?.trim());
    }
    return null;
  }

  Future<List<(String?, String?)>> batchGeocode(
    List<(double, double, String?)> coordinates,
  ) async {
    final results = <int, (String?, String?)>{};

    // Resolve cached entries immediately
    final uncached = <(int, double, double, String?)>[];
    for (var i = 0; i < coordinates.length; i++) {
      final (lat, lng, desc) = coordinates[i];
      final key = _cacheKey(lat, lng);
      if (_cache.containsKey(key)) {
        results[i] = _cache[key]!;
      } else {
        uncached.add((i, lat, lng, desc));
      }
    }

    // Process uncached in batches with concurrency control
    for (var i = 0; i < uncached.length; i += _maxConcurrency) {
      final batch = uncached.skip(i).take(_maxConcurrency);
      final futures = batch.map((entry) async {
        final (index, lat, lng, desc) = entry;
        final result = await reverseGeocode(lat, lng,
            locationDescription: desc);
        return (index, result);
      });
      final batchResults = await Future.wait(futures);
      for (final (index, result) in batchResults) {
        results[index] = result;
      }
    }

    return List.generate(
      coordinates.length,
      (i) => results[i] ?? (null, null),
    );
  }
}
