import 'package:flutter/foundation.dart';
import '../../../../data/services/geocoding_service.dart';
import '../../../../domain/models/video.dart';

class MapViewModel extends ChangeNotifier {
  Video? _selectedVideo;
  Video? get selectedVideo => _selectedVideo;

  String? _selectedVideoAddress;
  String? get selectedVideoAddress => _selectedVideoAddress;

  bool _isLoadingGeocoding = false;
  bool get isLoadingGeocoding => _isLoadingGeocoding;

  void selectVideo(Video? video, GeocodingService geocodingService) async {
    _selectedVideo = video;
    _selectedVideoAddress = null;
    notifyListeners();

    if (video != null && video.latitude != null && video.longitude != null) {
      _isLoadingGeocoding = true;
      notifyListeners();

      try {
        final address = await geocodingService.reverseGeocode(video.latitude!, video.longitude!);
        _selectedVideoAddress = address;
      } catch (_) {
        _selectedVideoAddress = 'Location: (${video.latitude}, ${video.longitude})';
      } finally {
        _isLoadingGeocoding = false;
        notifyListeners();
      }
    }
  }

  void clearSelection() {
    _selectedVideo = null;
    _selectedVideoAddress = null;
    notifyListeners();
  }
}
