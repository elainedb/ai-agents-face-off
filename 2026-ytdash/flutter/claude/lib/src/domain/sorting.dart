import '../data/models/video.dart';

enum SortOption {
  dateDesc, // newest first
  dateAsc, // oldest first
  titleAsc,
  titleDesc,
}

extension SortOptionLabel on SortOption {
  /// Labels END with the regex keyword the flows match (cross-framework §D.3:
  /// Maestro `text:` is a full-string match).
  String get label {
    switch (this) {
      case SortOption.dateDesc:
        return 'Date — newest';
      case SortOption.dateAsc:
        return 'Date — oldest';
      case SortOption.titleAsc:
        return 'Title A–Z';
      case SortOption.titleDesc:
        return 'Title Z–A';
    }
  }
}

/// Pure sort over a copy of the list. Date sorts compare the ISO-8601
/// `publishedAt` strings (lexicographic == chronological for Zulu ISO-8601).
List<Video> sortVideos(List<Video> videos, SortOption option) {
  final out = [...videos];
  switch (option) {
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
