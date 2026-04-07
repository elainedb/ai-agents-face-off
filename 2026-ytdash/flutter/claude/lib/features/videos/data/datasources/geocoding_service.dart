import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton()
class GeocodingService {
  final http.Client _httpClient;
  final Map<String, (String?, String?)> _cache = {};
  static const int _maxConcurrency = 5;
  int _activeTasks = 0;
  final _queue = <Completer<void>>[];
  DateTime? _lastNominatimRequest;

  GeocodingService(this._httpClient);

  String _cacheKey(double lat, double lng) {
    return '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
  }

  Future<(String?, String?)> reverseGeocode(double latitude, double longitude) async {
    final key = _cacheKey(latitude, longitude);
    if (_cache.containsKey(key)) return _cache[key]!;

    await _acquireSlot();
    try {
      final result = await _tryPlatformGeocoder(latitude, longitude) ??
          await _tryNominatim(latitude, longitude);
      _cache[key] = result ?? (null, null);
      return _cache[key]!;
    } finally {
      _releaseSlot();
    }
  }

  Future<void> _acquireSlot() async {
    if (_activeTasks < _maxConcurrency) {
      _activeTasks++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _activeTasks++;
  }

  void _releaseSlot() {
    _activeTasks--;
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    }
  }

  Future<(String?, String?)?> _tryPlatformGeocoder(
      double latitude, double longitude) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          latitude,
          longitude,
        );
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
          await Future.delayed(Duration(milliseconds: 500 * (1 << attempt)));
        }
      }
    }
    return null;
  }

  Future<(String?, String?)?> _tryNominatim(
      double latitude, double longitude) async {
    try {
      if (_lastNominatimRequest != null) {
        final elapsed = DateTime.now().difference(_lastNominatimRequest!);
        if (elapsed < const Duration(seconds: 1)) {
          await Future.delayed(const Duration(seconds: 1) - elapsed);
        }
      }
      _lastNominatimRequest = DateTime.now();

      final response = await _httpClient.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'),
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
              address['hamlet'];
          final country = address['country'];
          return (city as String?, country as String?);
        }
      }
    } catch (_) {}
    return null;
  }

  (String?, String?)? parseLocationDescription(String? description) {
    if (description == null || description.isEmpty) return null;
    final match = RegExp(r'^(.+),\s*(.+)$').firstMatch(description);
    if (match != null) {
      return (match.group(1)?.trim(), match.group(2)?.trim());
    }
    return null;
  }
}
