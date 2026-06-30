import '../data/models/video.dart';

/// The distinct category labels present in the data, in first-appearance order
/// (these are the source-channel labels, spec/youtube-api.md mapping).
List<String> availableCategories(List<Video> videos) {
  final seen = <String>[];
  for (final v in videos) {
    if (v.category.isNotEmpty && !seen.contains(v.category)) {
      seen.add(v.category);
    }
  }
  return seen;
}

/// Filter by category label. A null/empty label means "all". Case-insensitive.
List<Video> filterByLabel(List<Video> videos, String? label) {
  if (label == null || label.isEmpty) return videos;
  final l = label.toLowerCase();
  return videos.where((v) => v.category.toLowerCase() == l).toList();
}
