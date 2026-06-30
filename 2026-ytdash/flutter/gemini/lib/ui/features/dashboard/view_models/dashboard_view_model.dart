import 'package:flutter/foundation.dart';
import '../../../../data/models/test_config.dart';
import '../../../../data/repositories/preference_repository.dart';
import '../../../../data/services/youtube_api_client.dart';
import '../../../../domain/models/video.dart';

class DashboardViewModel extends ChangeNotifier {
  final YoutubeApiClient _apiClient;
  final PreferenceRepository _prefRepository;

  List<Video> _allVideos = [];
  List<Video> get allVideos => _allVideos;

  List<Video> _filteredVideos = [];
  List<Video> get filteredVideos => _filteredVideos;

  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedCategory; // Null or 'All' means no category filter
  String? get selectedCategory => _selectedCategory;

  String _selectedSort = 'none'; // 'none', 'date_desc', 'date_asc', 'title_asc'
  String get selectedSort => _selectedSort;

  // Intercepted external open url for Maestro captured link validation
  String? _capturedUrl;
  String? get capturedUrl => _capturedUrl;

  String? _externalOpenError;
  String? get externalOpenError => _externalOpenError;

  bool _isFilterPanelOpen = false;
  bool get isFilterPanelOpen => _isFilterPanelOpen;

  bool _isSortPanelOpen = false;
  bool get isSortPanelOpen => _isSortPanelOpen;

  static const _defaultApiKey = 'YOUR_YOUTUBE_API_KEY';

  DashboardViewModel({
    required YoutubeApiClient apiClient,
    required PreferenceRepository prefRepository,
  })  : _apiClient = apiClient,
        _prefRepository = prefRepository;

  void toggleFilterPanel() {
    _isFilterPanelOpen = !_isFilterPanelOpen;
    _isSortPanelOpen = false; // Mutually exclusive
    notifyListeners();
  }

  void toggleSortPanel() {
    _isSortPanelOpen = !_isSortPanelOpen;
    _isFilterPanelOpen = false; // Mutually exclusive
    notifyListeners();
  }

  void setFilterPanelOpen(bool open) {
    _isFilterPanelOpen = open;
    notifyListeners();
  }

  void setSortPanelOpen(bool open) {
    _isSortPanelOpen = open;
    notifyListeners();
  }

  Future<void> loadVideos(TestConfig testConfig, {bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try to load configured channels to extract possible categories
      final channels = await _apiClient.loadChannels();
      _categories = ['All', ...channels.map((c) => c['label'] ?? '').where((l) => l.isNotEmpty).toSet().toList()];

      List<Video> fetchedVideos = [];
      bool fetchSuccess = false;

      if (forceRefresh || _allVideos.isEmpty) {
        try {
          fetchedVideos = await _apiClient.fetchAllVideos(testConfig, _defaultApiKey);
          fetchSuccess = true;
        } catch (e, stack) {
          debugPrint('DashboardViewModel: Error fetching videos: $e');
          debugPrint('DashboardViewModel: StackTrace: $stack');
          fetchSuccess = false;
        }
      }

      if (fetchSuccess) {
        debugPrint('DashboardViewModel: Successfully fetched ${fetchedVideos.length} videos');
        // Cache newly fetched videos
        await _prefRepository.saveCachedVideos(fetchedVideos);
        _allVideos = fetchedVideos;
      } else {
        final cached = await _prefRepository.getCachedVideos();
        debugPrint('DashboardViewModel: Fetch failed, falling back to cached videos (${cached.length} found)');
        if (cached.isNotEmpty) {
          _allVideos = cached;
        } else if (forceRefresh || _allVideos.isEmpty) {
          _errorMessage = 'Unable to load videos. Check your internet connection.';
          debugPrint('DashboardViewModel: Error loading videos set: $_errorMessage');
        }
      }

      _applyFiltersAndSort();
    } catch (e, stack) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('DashboardViewModel: Unexpected error: $e');
      debugPrint('DashboardViewModel: Unexpected stack: $stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    _selectedCategory = (category == 'All') ? null : category;
  }

  void applyFilter() {
    _isFilterPanelOpen = false;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void selectSort(String sortKey) {
    _selectedSort = sortKey;
  }

  void applySort() {
    _isSortPanelOpen = false;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var list = List<Video>.from(_allVideos);

    // 1. Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      list = list.where((v) => v.category.toLowerCase() == _selectedCategory!.toLowerCase()).toList();
    }

    // 2. Sort
    if (_selectedSort == 'date_desc') {
      list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    } else if (_selectedSort == 'date_asc') {
      list.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    } else if (_selectedSort == 'title_asc') {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    _filteredVideos = list;
  }

  // Intercept launch URL for capturing links
  void setCapturedUrl(String? url) {
    _capturedUrl = url;
    notifyListeners();
  }

  void clearCapturedUrl() {
    _capturedUrl = null;
    notifyListeners();
  }

  void setExternalOpenError(String? error) {
    _externalOpenError = error;
    notifyListeners();
  }

  void clearExternalOpenError() {
    _externalOpenError = null;
    notifyListeners();
  }
}
