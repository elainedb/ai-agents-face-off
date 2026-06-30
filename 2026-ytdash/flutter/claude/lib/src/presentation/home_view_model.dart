import 'package:flutter/foundation.dart';

import '../data/models/video.dart';
import '../data/repository/video_repository.dart';
import '../domain/filtering.dart';
import '../domain/sorting.dart';

enum ViewStatus { loading, content, empty, error }

/// Observable view-state for the home screen (constitution §1.3). All business
/// logic (load, sort, filter) lives here, not in widget callbacks.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final VideoRepository _repository;

  ViewStatus _status = ViewStatus.loading;
  List<Video> _all = [];
  String? _error;
  String? _activeFilter; // category label, null = all
  SortOption? _activeSort;

  ViewStatus get status => _status;
  String? get error => _error;
  String? get activeFilter => _activeFilter;
  SortOption? get activeSort => _activeSort;

  /// Total number of loaded videos (constitution selector `video_count`) — the
  /// full aggregated count, independent of any active filter.
  int get totalCount => _all.length;

  List<String> get categories => availableCategories(_all);

  /// All loaded videos (unfiltered) — the map plots every located video.
  List<Video> get allVideos => List.unmodifiable(_all);

  /// The visible list after filter + sort.
  List<Video> get visibleVideos {
    var list = filterByLabel(_all, _activeFilter);
    if (_activeSort != null) {
      list = sortVideos(list, _activeSort!);
    }
    return list;
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_all.isEmpty) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    final result = await _repository.getVideos(forceRefresh: forceRefresh);
    _all = result.videos;
    if (_all.isNotEmpty) {
      // We have data to show (fresh or stale cache) → never a blocking error.
      _status = ViewStatus.content;
      _error = null;
    } else if (result.error != null) {
      _status = ViewStatus.error;
      _error = result.error;
    } else {
      _status = ViewStatus.empty;
      _error = null;
    }
    notifyListeners();
  }

  Future<void> refresh() => load(forceRefresh: true);

  void applyFilter(String? label) {
    _activeFilter = label;
    notifyListeners();
  }

  void applySort(SortOption option) {
    _activeSort = option;
    notifyListeners();
  }
}
