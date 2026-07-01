import 'models/video.dart';

enum SortOrder {
  dateDescending,
  dateAscending,
  titleAscending,
  titleDescending,
}

List<Video> sortVideos(List<Video> videos, SortOrder order) {
  final sorted = List<Video>.of(videos);
  switch (order) {
    case SortOrder.dateDescending:
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    case SortOrder.dateAscending:
      sorted.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    case SortOrder.titleAscending:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case SortOrder.titleDescending:
      sorted.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
  }
  return sorted;
}

/// `null` category means "no filter" (show everything).
List<Video> filterVideos(List<Video> videos, String? category) {
  if (category == null) return videos;
  return videos.where((v) => v.category == category).toList();
}
