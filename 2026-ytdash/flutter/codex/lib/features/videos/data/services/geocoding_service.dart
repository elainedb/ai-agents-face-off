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
  GeocodingService({required this.client});

  final http.Client client;
  final Map<String, GeocodingResult> _cache = <String, GeocodingResult>{};
  DateTime? _lastNominatimCallAt;

  Future<GeocodingResult> resolve({
    required double latitude,
    required double longitude,
    String? locationDescription,
  }) async {
    final String key = _cacheKey(latitude, longitude);
    final GeocodingResult? cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final GeocodingResult result = await _resolveWithRetries(
      latitude,
      longitude,
      locationDescription,
    );
    _cache[key] = result;
    return result;
  }

  String _cacheKey(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
  }

  Future<GeocodingResult> _resolveWithRetries(
    double latitude,
    double longitude,
    String? locationDescription,
  ) async {
    Duration delay = const Duration(milliseconds: 500);
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          return GeocodingResult(
            city:
                place.locality ??
                place.subLocality ??
                place.administrativeArea ??
                place.name,
            country: place.country,
          );
        }
      } catch (_) {
        if (attempt < 2) {
          await Future<void>.delayed(delay);
          delay *= 2;
        }
      }
    }

    final GeocodingResult? nominatim = await _resolveViaNominatim(
      latitude,
      longitude,
    );
    if (nominatim != null) {
      return nominatim;
    }

    return _parseLocationDescription(locationDescription);
  }

  Future<GeocodingResult?> _resolveViaNominatim(
    double latitude,
    double longitude,
  ) async {
    final DateTime now = DateTime.now();
    if (_lastNominatimCallAt != null) {
      final Duration elapsed = now.difference(_lastNominatimCallAt!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }
    _lastNominatimCallAt = DateTime.now();

    final Uri uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      <String, String>{
        'format': 'jsonv2',
        'lat': '$latitude',
        'lon': '$longitude',
      },
    );

    try {
      final http.Response response = await client.get(
        uri,
        headers: const <String, String>{
          'User-Agent': 'dev.elainedb.ytdash_flutter_codex/1.0',
        },
      );
      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> address =
          (json['address'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      return GeocodingResult(
        city:
            address['city'] as String? ??
            address['town'] as String? ??
            address['village'] as String? ??
            address['county'] as String? ??
            address['state'] as String?,
        country: address['country'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  GeocodingResult _parseLocationDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return const GeocodingResult();
    }

    final RegExp regex = RegExp(r'([A-Za-z\s\-]+),\s*([A-Za-z\s\-]+)');
    final RegExpMatch? match = regex.firstMatch(description);
    if (match == null) {
      return const GeocodingResult();
    }

    return GeocodingResult(
      city: match.group(1)?.trim(),
      country: match.group(2)?.trim(),
    );
  }
}
