import '../entities/video.dart';

/// Filters to videos whose `category` (the source-channel label) matches [label]
/// case-insensitively. A null/empty [label] means "no filter" (all videos).
List<Video> filterByCategory(List<Video> videos, String? label) {
  if (label == null || label.trim().isEmpty) return videos;
  final normalized = label.trim().toLowerCase();
  return videos
      .where((v) => v.category.trim().toLowerCase() == normalized)
      .toList(growable: false);
}

/// The distinct category labels present in [videos], in first-appearance order.
List<String> distinctCategories(List<Video> videos) {
  final seen = <String>{};
  final out = <String>[];
  for (final v in videos) {
    if (seen.add(v.category)) out.add(v.category);
  }
  return out;
}
