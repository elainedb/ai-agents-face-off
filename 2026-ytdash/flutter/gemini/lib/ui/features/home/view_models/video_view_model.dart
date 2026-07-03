import 'package:flutter/material.dart';
import 'package:ytdash_flutter/data/models/channel.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/repositories/video_repository.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  titleAsc,
  titleDesc,
}

class VideoViewModel extends ChangeNotifier {
  final VideoRepository _videoRepository;

  VideoViewModel({required VideoRepository videoRepository})
      : _videoRepository = videoRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Video> _allVideos = [];
  List<Video> get allVideos => _allVideos;

  List<Video> _displayedVideos = [];
  List<Video> get displayedVideos => _displayedVideos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filtering & Sorting State
  String? _selectedCategory; // Null means All
  String? get selectedCategory => _selectedCategory;

  SortOption _selectedSort = SortOption.dateNewest;
  SortOption get selectedSort => _selectedSort;

  // Temp states for Apply button behavior
  String? _tempSelectedCategory;
  SortOption _tempSelectedSort = SortOption.dateNewest;

  bool _isFilterPanelOpen = false;
  bool get isFilterPanelOpen => _isFilterPanelOpen;

  bool _isSortPanelOpen = false;
  bool get isSortPanelOpen => _isSortPanelOpen;

  /// Loads videos from repository.
  /// If [forceRefresh] is true, triggers a network fetch.
  Future<void> loadVideos({
    required bool forceRefresh,
    required TestConfig config,
    required List<ChannelConfig> channels,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final videos = await _videoRepository.getVideos(
        forceRefresh: forceRefresh,
        baseUrl: config.apiBaseUrl,
        apiKey: config.apiKey,
        channels: channels,
        uiTestMode: config.uiTestMode,
      );

      _allVideos = videos;
      _applyFilterAndSort();
    } catch (e) {
      _errorMessage = 'Failed to load videos: $e';
      _displayedVideos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Panel Management
  void openFilterPanel() {
    _isFilterPanelOpen = true;
    _isSortPanelOpen = false;
    _tempSelectedCategory = _selectedCategory;
    notifyListeners();
  }

  void selectTempCategory(String? category) {
    _tempSelectedCategory = category;
    notifyListeners();
  }

  String? get tempSelectedCategory => _tempSelectedCategory;

  void applyFilter() {
    _selectedCategory = _tempSelectedCategory;
    _isFilterPanelOpen = false;
    _applyFilterAndSort();
  }

  void cancelFilter() {
    _isFilterPanelOpen = false;
    notifyListeners();
  }

  void openSortPanel() {
    _isSortPanelOpen = true;
    _isFilterPanelOpen = false;
    _tempSelectedSort = _selectedSort;
    notifyListeners();
  }

  void selectTempSort(SortOption option) {
    _tempSelectedSort = option;
    notifyListeners();
  }

  SortOption get tempSelectedSort => _tempSelectedSort;

  void applySort() {
    _selectedSort = _tempSelectedSort;
    _isSortPanelOpen = false;
    _applyFilterAndSort();
  }

  void cancelSort() {
    _isSortPanelOpen = false;
    notifyListeners();
  }

  /// Internal helper to filter and sort [_allVideos] into [_displayedVideos]
  void _applyFilterAndSort() {
    List<Video> result = List.from(_allVideos);

    // 1. Filter by category (case-insensitive)
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      final categoryLower = _selectedCategory!.toLowerCase();
      result = result
          .where((v) => v.category.toLowerCase() == categoryLower)
          .toList();
    }

    // 2. Sort
    switch (_selectedSort) {
      case SortOption.dateNewest:
        result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
        break;
      case SortOption.titleAsc:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    _displayedVideos = result;
    notifyListeners();
  }
}
