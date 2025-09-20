import 'package:flutter_gemini/core/services/geocoding_result.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ReverseGeocodingService {
  Future<GeocodingResult?> getAddress(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      return null;
    }
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.locality}, ${placemark.country}';
        return GeocodingResult(address: address, country: placemark.country);
      }
    } catch (e) {
      // Handle exceptions, e.g., network errors
    }
    return null;
  }
}
