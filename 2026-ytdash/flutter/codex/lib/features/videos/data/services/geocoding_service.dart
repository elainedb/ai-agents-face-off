import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class GeocodingService {
  GeocodingService(this._client);

  final http.Client _client;
  final Map<String, (String?, String?)> _cache = <String, (String?, String?)>{};
  final Queue<_GeocodingTask> _queue = Queue<_GeocodingTask>();
  int _activeCount = 0;
  DateTime? _lastNominatimRequestAt;

  Future<(String?, String?)> resolveLocation({
    double? latitude,
    double? longitude,
    String? locationDescription,
  }) async {
    if (latitude == null || longitude == null) {
      return _parseLocationDescription(locationDescription);
    }

    final key = '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final completer = Completer<(String?, String?)>();
    _queue.add(
      _GeocodingTask(
        latitude: latitude,
        longitude: longitude,
        locationDescription: locationDescription,
        cacheKey: key,
        completer: completer,
      ),
    );
    _drainQueue();
    return completer.future;
  }

  void _drainQueue() {
    while (_activeCount < 5 && _queue.isNotEmpty) {
      final task = _queue.removeFirst();
      _activeCount++;
      _performLookup(task).whenComplete(() {
        _activeCount--;
        _drainQueue();
      });
    }
  }

  Future<void> _performLookup(_GeocodingTask task) async {
    final result = await _lookupLocation(
      latitude: task.latitude,
      longitude: task.longitude,
      locationDescription: task.locationDescription,
    );
    _cache[task.cacheKey] = result;
    task.completer.complete(result);
  }

  Future<(String?, String?)> _lookupLocation({
    required double latitude,
    required double longitude,
    String? locationDescription,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final city = placemark.locality ??
              placemark.subLocality ??
              placemark.administrativeArea ??
              placemark.name;
          final country = placemark.country;
          if ((city?.isNotEmpty ?? false) || (country?.isNotEmpty ?? false)) {
            return (city, country);
          }
        }
      } catch (_) {
        await Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt)));
      }
    }

    final nominatim = await _lookupViaNominatim(latitude, longitude);
    if (nominatim.$1 != null || nominatim.$2 != null) {
      return nominatim;
    }

    return _parseLocationDescription(locationDescription);
  }

  Future<(String?, String?)> _lookupViaNominatim(double latitude, double longitude) async {
    if (_lastNominatimRequestAt != null) {
      final elapsed = DateTime.now().difference(_lastNominatimRequestAt!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }

    _lastNominatimRequestAt = DateTime.now();
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        <String, String>{
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'jsonv2',
        },
      );
      final response = await _client.get(
        uri,
        headers: <String, String>{
          'User-Agent': 'dev.elainedb.ytdash_flutter_codex/1.0',
        },
      );
      if (response.statusCode != 200) {
        return (null, null);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>?;
      if (address == null) {
        return (null, null);
      }
      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          address['county'] as String?;
      final country = address['country'] as String?;
      return (city, country);
    } catch (_) {
      return (null, null);
    }
  }

  (String?, String?) _parseLocationDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return (null, null);
    }
    final match = RegExp(r"([A-Za-zÀ-ÿ .'-]+),\s*([A-Za-zÀ-ÿ .'-]+)").firstMatch(description);
    if (match == null) {
      return (null, null);
    }
    return (match.group(1)?.trim(), match.group(2)?.trim());
  }
}

class _GeocodingTask {
  const _GeocodingTask({
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.cacheKey,
    required this.completer,
  });

  final double latitude;
  final double longitude;
  final String? locationDescription;
  final String cacheKey;
  final Completer<(String?, String?)> completer;
}
