import '../../data/models/video.dart';

/// Pure filter — no Flutter dependency, unit-testable. `null` category means "no filter applied".
List<Video> filterByCategory(List<Video> videos, String? category) {
  if (category == null) return videos;
  return videos.where((v) => v.category == category).toList();
}
