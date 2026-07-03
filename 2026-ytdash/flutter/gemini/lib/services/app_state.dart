import 'package:flutter/foundation.dart';
import '../models/video.dart';
import 'api_service.dart';
import 'cache_service.dart';
import 'test_config.dart';

class AppStateNotifier extends ChangeNotifier {
  final ApiService apiService;
  final CacheService cacheService;
  final TestConfig config;

  List<Video> _allVideos = [];
  List<Video> _filteredVideos = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedCategory;
  String? _selectedSort; // null means API response order (essential for AC-LIST-03 index 0)

  bool _isFilterPanelOpen = false;
  bool _isSortPanelOpen = false;

  String? _capturedUrl;
  String? _externalOpenError;

  AppStateNotifier({
    required this.apiService,
    required this.cacheService,
    required this.config,
  });

  List<Video> get videos => _filteredVideos;
  List<Video> get allVideos => _allVideos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedCategory => _selectedCategory;
  String? get selectedSort => _selectedSort;

  bool get isFilterPanelOpen => _isFilterPanelOpen;
  bool get isSortPanelOpen => _isSortPanelOpen;

  String? get capturedUrl => _capturedUrl;
  String? get externalOpenError => _externalOpenError;

  void setFilterPanelOpen(bool open) {
    _isFilterPanelOpen = open;
    notifyListeners();
  }

  void setSortPanelOpen(bool open) {
    _isSortPanelOpen = open;
    notifyListeners();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectSort(String? sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void clearCapturedUrl() {
    _capturedUrl = null;
    notifyListeners();
  }

  void clearExternalOpenError() {
    _externalOpenError = null;
    notifyListeners();
  }

  void captureUrl(String url) {
    _capturedUrl = url;
    notifyListeners();
  }

  void setExternalOpenError(String error) {
    _externalOpenError = error;
    notifyListeners();
  }

  // Fetch / Refresh pipeline
  Future<void> fetchVideos({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (forceRefresh) {
        // Force refresh: load from API, then save to Cache
        final fetched = await apiService.fetchAllVideos();
        _allVideos = fetched;
        await cacheService.saveVideos(fetched);
      } else {
        // Normal load: try cached first
        final cached = await cacheService.getVideos();
        if (cached.isNotEmpty) {
          _allVideos = cached;
        } else {
          // No cache: load from API
          final fetched = await apiService.fetchAllVideos();
          _allVideos = fetched;
          await cacheService.saveVideos(fetched);
        }
      }
    } catch (e) {
      print('Fetch videos error: $e');
      // If error, try loading from cache as fallback!
      try {
        final cached = await cacheService.getVideos();
        if (cached.isNotEmpty) {
          _allVideos = cached;
          _errorMessage = null; // No blocking error view!
        } else {
          _errorMessage = 'Failed to load videos: $e';
        }
      } catch (cacheError) {
        _errorMessage = 'Failed to load videos: $e';
      }
    }

    _applyFilterAndSort();
    _isLoading = false;
    notifyListeners();
  }

  void applyFilterAndSort() {
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    List<Video> list = List.from(_allVideos);

    // Apply Filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      list = list.where((v) => v.category.toLowerCase() == _selectedCategory!.toLowerCase()).toList();
    }

    // Apply Sort
    if (_selectedSort != null) {
      if (_selectedSort == 'date_desc') {
        list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      } else if (_selectedSort == 'date_asc') {
        list.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
      } else if (_selectedSort == 'title_asc') {
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (_selectedSort == 'title_desc') {
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      }
    }

    _filteredVideos = list;
  }
}
