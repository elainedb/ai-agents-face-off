import '../../data/models/video.dart';

enum SortOption { dateNewest, dateOldest, titleAToZ, titleZToA }

/// Pure sort — no Flutter dependency, unit-testable.
List<Video> sortVideos(List<Video> videos, SortOption option) {
  final copy = List<Video>.from(videos);
  switch (option) {
    case SortOption.dateNewest:
      copy.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    case SortOption.dateOldest:
      copy.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    case SortOption.titleAToZ:
      copy.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case SortOption.titleZToA:
      copy.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
  }
  return copy;
}
