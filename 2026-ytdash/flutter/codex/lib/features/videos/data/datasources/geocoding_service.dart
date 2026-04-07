import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class GeocodingResult {
  const GeocodingResult({this.city, this.country});

  final String? city;
  final String? country;
}

class GeocodingService {
  GeocodingService({required http.Client client}) : _client = client;

  final http.Client _client;
  final Map<String, GeocodingResult> _memoryCache = {};
  DateTime? _lastNominatimRequest;

  Future<Map<String, GeocodingResult>> resolveBatch(
    Iterable<(double, double, String?)> inputs,
  ) async {
    final list = inputs.toList();
    final results = <String, GeocodingResult>{};

    for (var index = 0; index < list.length; index += 5) {
      final chunk = list.sublist(
        index,
        index + 5 > list.length ? list.length : index + 5,
      );
      final chunkResults = await Future.wait(
        chunk.map((item) async {
          final key = _cacheKey(item.$1, item.$2);
          final result = await reverseGeocode(
            latitude: item.$1,
            longitude: item.$2,
            fallbackText: item.$3,
          );
          return MapEntry(key, result);
        }),
      );
      results.addEntries(chunkResults);
    }

    return results;
  }

  Future<GeocodingResult> reverseGeocode({
    required double latitude,
    required double longitude,
    String? fallbackText,
  }) async {
    final key = _cacheKey(latitude, longitude);
    final cached = _memoryCache[key];
    if (cached != null) {
      return cached;
    }

    GeocodingResult? resolved;
    for (var attempt = 0; attempt < 3 && resolved == null; attempt++) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          resolved = GeocodingResult(
            city: place.locality ??
                place.subLocality ??
                place.administrativeArea ??
                place.name,
            country: place.country,
          );
        }
      } catch (_) {
        await Future<void>.delayed(
          Duration(milliseconds: 500 * (1 << attempt)),
        );
      }
    }

    resolved ??= await _reverseWithNominatim(latitude, longitude);
    resolved ??= _parseFallbackText(fallbackText);
    resolved ??= const GeocodingResult();
    _memoryCache[key] = resolved;
    return resolved;
  }

  Future<GeocodingResult?> _reverseWithNominatim(
    double latitude,
    double longitude,
  ) async {
    if (_lastNominatimRequest != null) {
      final elapsed = DateTime.now().difference(_lastNominatimRequest!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }

    _lastNominatimRequest = DateTime.now();
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'zoom': '12',
      'addressdetails': '1',
    });
    final response = await _client.get(
      uri,
      headers: const {
        'User-Agent': 'dev.elainedb.ytdash_flutter_codex/1.0',
      },
    );
    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) {
      return null;
    }
    return GeocodingResult(
      city: address['city']?.toString() ??
          address['town']?.toString() ??
          address['village']?.toString() ??
          address['county']?.toString(),
      country: address['country']?.toString(),
    );
  }

  GeocodingResult? _parseFallbackText(String? input) {
    if (input == null || input.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r'^\s*([^,]+),\s*([^,]+)\s*$').firstMatch(input.trim());
    if (match == null) {
      return null;
    }
    return GeocodingResult(
      city: match.group(1)?.trim(),
      country: match.group(2)?.trim(),
    );
  }

  String _cacheKey(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
  }
}
