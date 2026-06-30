import '../data/models/video.dart';

/// Sort options the user can pick (AC-SORT-01).
///
/// Labels are anchored so Maestro's full-string `text:` match (`matches()`) selects the right one:
/// the sort flow uses `(?i)date.*(desc|newest)` with NO leading `.*`, so a date label must START
/// with "Date" and END with the keyword (cross-framework-setup §D.3).
enum SortOption {
  none('Default order'),
  dateDesc('Date — newest'),
  dateAsc('Date — oldest'),
  titleAsc('Title — A to Z'),
  titleDesc('Title — Z to A');

  const SortOption(this.label);
  final String label;

  /// The user-selectable options shown in the sort panel ("none" is the implicit initial state =
  /// API/aggregation order, which keeps AC-LIST-03's first row deterministic).
  static const List<SortOption> selectable = [dateDesc, dateAsc, titleAsc, titleDesc];
}

/// Pure domain functions for filtering and sorting. No UI, no IO — directly unit-tested
/// (constitution §2).
class VideoQuery {
  /// Distinct category labels present in the data, in first-appearance order. These become the
  /// filter options; `null` selection means "all".
  static List<String> categoriesOf(List<Video> videos) {
    final seen = <String>{};
    final out = <String>[];
    for (final v in videos) {
      if (v.category.isNotEmpty && seen.add(v.category)) out.add(v.category);
    }
    return out;
  }

  static List<Video> filter(List<Video> videos, String? category) {
    if (category == null || category.isEmpty) return List.of(videos);
    final target = category.toLowerCase();
    return videos.where((v) => v.category.toLowerCase() == target).toList();
  }

  static List<Video> sort(List<Video> videos, SortOption option) {
    final out = List.of(videos);
    switch (option) {
      case SortOption.none:
        break; // preserve API/aggregation order
      case SortOption.dateDesc:
        out.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      case SortOption.dateAsc:
        out.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
      case SortOption.titleAsc:
        out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortOption.titleDesc:
        out.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }
    return out;
  }

  /// Apply filter then sort (the order the list is displayed in).
  static List<Video> apply(List<Video> videos, String? category, SortOption option) =>
      sort(filter(videos, category), option);
}
