import '../entities/video.dart';

enum SortKey { dateDesc, dateAsc, titleAsc, titleDesc }

/// Human-facing label for a sort option. Sort labels must END with the regex keyword the Maestro
/// flows match (`(?i)date.*(desc|newest)` / `(?i)date.*(asc|oldest)`), so the label itself is the
/// selector text.
String sortKeyLabel(SortKey key) => switch (key) {
  SortKey.dateDesc => 'Date — newest',
  SortKey.dateAsc => 'Date — oldest',
  SortKey.titleAsc => 'Title — A to Z',
  SortKey.titleDesc => 'Title — Z to A',
};

List<Video> sortVideos(List<Video> videos, SortKey key) {
  final sorted = List<Video>.of(videos);
  switch (key) {
    case SortKey.dateDesc:
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    case SortKey.dateAsc:
      sorted.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    case SortKey.titleAsc:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case SortKey.titleDesc:
      sorted.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
  }
  return sorted;
}
