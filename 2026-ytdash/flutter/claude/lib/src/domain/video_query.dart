import 'video.dart';

enum SortField { date, title }

enum SortDirection { ascending, descending }

/// An immutable description of how the video list should be sorted/filtered.
/// Applying it is a pure transformation over the full list (the single source
/// of truth), so the UI never mutates data in place.
///
/// [sortField] is null by default: the list then preserves API/insertion order
/// (so the "first video" is the first fetched one — AC-LIST-03). A sort is
/// applied only once the user explicitly chooses one.
class VideoQuery {
  const VideoQuery({
    this.categoryFilter,
    this.sortField,
    this.sortDirection = SortDirection.descending,
  });

  /// When non-null, only videos whose [Video.category] equals this remain.
  final String? categoryFilter;
  final SortField? sortField;
  final SortDirection sortDirection;

  VideoQuery copyWith({
    Object? categoryFilter = _unset,
    Object? sortField = _unset,
    SortDirection? sortDirection,
  }) =>
      VideoQuery(
        categoryFilter: categoryFilter == _unset
            ? this.categoryFilter
            : categoryFilter as String?,
        sortField:
            sortField == _unset ? this.sortField : sortField as SortField?,
        sortDirection: sortDirection ?? this.sortDirection,
      );

  static const Object _unset = Object();

  List<Video> apply(List<Video> videos) {
    final filtered = categoryFilter == null
        ? List<Video>.from(videos)
        : videos.where((v) => v.category == categoryFilter).toList();

    final field = sortField;
    if (field == null) return filtered; // preserve insertion/API order

    int cmp(Video a, Video b) {
      final result = switch (field) {
        SortField.date => a.publishedAt.compareTo(b.publishedAt),
        SortField.title =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return sortDirection == SortDirection.ascending ? result : -result;
    }

    filtered.sort(cmp);
    return filtered;
  }
}

/// The distinct category labels present, in first-appearance order.
List<String> availableCategories(List<Video> videos) {
  final seen = <String>{};
  final out = <String>[];
  for (final v in videos) {
    if (v.category.isNotEmpty && seen.add(v.category)) out.add(v.category);
  }
  return out;
}
