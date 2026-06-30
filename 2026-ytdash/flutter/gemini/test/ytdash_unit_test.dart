import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/repositories/preference_repository.dart';
import 'package:ytdash_flutter/data/services/youtube_api_client.dart';
import 'package:ytdash_flutter/domain/models/video.dart';
import 'package:ytdash_flutter/ui/features/auth/view_models/auth_view_model.dart';
import 'package:ytdash_flutter/ui/features/dashboard/view_models/dashboard_view_model.dart';

// Manual Mock for YoutubeApiClient
class MockYoutubeApiClient extends YoutubeApiClient {
  final List<Map<String, String>> mockChannels;
  final List<Video> mockVideos;

  MockYoutubeApiClient({this.mockChannels = const [], this.mockVideos = const []});

  @override
  Future<List<Map<String, String>>> loadChannels() async {
    return mockChannels;
  }

  @override
  Future<List<Video>> fetchAllVideos(TestConfig testConfig, String defaultApiKey) async {
    return mockVideos;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication & Whitelist Tests', () {
    late PreferenceRepository prefRepo;
    late AuthViewModel authViewModel;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefRepo = PreferenceRepository();
      authViewModel = AuthViewModel(prefRepository: prefRepo);
      await authViewModel.init();
    });

    test('Initial state is unauthenticated', () {
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUserEmail, null);
      expect(authViewModel.errorMessage, null);
    });

    test('Login with whitelisted email succeeds in UI test mode', () async {
      final config = TestConfig(
        uiTestMode: true,
        mockAuthEmail: 'user1@example.com',
        authorizedEmails: 'user1@example.com,user2@example.com',
        captureExternalLinks: true,
      );

      final result = await authViewModel.login(config);
      expect(result, isTrue);
      expect(authViewModel.isAuthenticated, isTrue);
      expect(authViewModel.currentUserEmail, 'user1@example.com');
      expect(authViewModel.errorMessage, isNull);
    });

    test('Login with non-whitelisted email fails', () async {
      final config = TestConfig(
        uiTestMode: true,
        mockAuthEmail: 'unauthorized@example.com',
        authorizedEmails: 'user1@example.com,user2@example.com',
        captureExternalLinks: true,
      );

      final result = await authViewModel.login(config);
      expect(result, isFalse);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.errorMessage, contains('Access denied'));
    });

    test('Logout clears user email and session', () async {
      final config = TestConfig(
        uiTestMode: true,
        mockAuthEmail: 'user1@example.com',
        authorizedEmails: 'user1@example.com',
        captureExternalLinks: true,
      );

      await authViewModel.login(config);
      expect(authViewModel.isAuthenticated, isTrue);

      await authViewModel.logout(config);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUserEmail, isNull);

      final cachedEmail = await prefRepo.getUserEmail();
      expect(cachedEmail, isNull);
    });
  });

  group('Video List, Sorting & Filtering Tests', () {
    late PreferenceRepository prefRepo;
    final testVideos = [
      Video(
        id: 'v1',
        title: 'Apple Video',
        description: 'First video',
        publishedAt: '2026-01-01T12:00:00Z',
        category: 'Tech',
        thumbnailUrl: 'https://example.com/v1.jpg',
      ),
      Video(
        id: 'v2',
        title: 'Cherry Video',
        description: 'Second video',
        publishedAt: '2026-03-01T12:00:00Z',
        category: 'Cooking',
        thumbnailUrl: 'https://example.com/v2.jpg',
      ),
      Video(
        id: 'v3',
        title: 'Banana Video',
        description: 'Third video',
        publishedAt: '2026-02-01T12:00:00Z',
        category: 'Tech',
        thumbnailUrl: 'https://example.com/v3.jpg',
      ),
    ];

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      prefRepo = PreferenceRepository();
    });

    test('Load videos fetches and caches successfully', () async {
      final mockClient = MockYoutubeApiClient(
        mockChannels: [
          {'id': 'c1', 'label': 'Tech'},
          {'id': 'c2', 'label': 'Cooking'}
        ],
        mockVideos: testVideos,
      );

      final vm = DashboardViewModel(apiClient: mockClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      await vm.loadVideos(config);

      expect(vm.isLoading, isFalse);
      expect(vm.allVideos.length, 3);
      expect(vm.categories, containsAll(['All', 'Tech', 'Cooking']));

      final cached = await prefRepo.getCachedVideos();
      expect(cached.length, 3);
      expect(cached[0].id, 'v1');
    });

    test('Filtering by category', () async {
      final mockClient = MockYoutubeApiClient(mockVideos: testVideos);
      final vm = DashboardViewModel(apiClient: mockClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      await vm.loadVideos(config);

      // Filter Tech
      vm.selectCategory('Tech');
      vm.applyFilter();
      expect(vm.filteredVideos.length, 2);
      expect(vm.filteredVideos.every((v) => v.category == 'Tech'), isTrue);

      // Filter Cooking
      vm.selectCategory('Cooking');
      vm.applyFilter();
      expect(vm.filteredVideos.length, 1);
      expect(vm.filteredVideos.first.id, 'v2');
    });

    test('Sorting videos by title (asc)', () async {
      final mockClient = MockYoutubeApiClient(mockVideos: testVideos);
      final vm = DashboardViewModel(apiClient: mockClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      await vm.loadVideos(config);

      vm.selectSort('title_asc');
      vm.applySort();

      expect(vm.filteredVideos[0].title, 'Apple Video');
      expect(vm.filteredVideos[1].title, 'Banana Video');
      expect(vm.filteredVideos[2].title, 'Cherry Video');
    });

    test('Sorting videos by date (desc)', () async {
      final mockClient = MockYoutubeApiClient(mockVideos: testVideos);
      final vm = DashboardViewModel(apiClient: mockClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      await vm.loadVideos(config);

      vm.selectSort('date_desc');
      vm.applySort();

      expect(vm.filteredVideos[0].id, 'v2'); // 2026-03-01
      expect(vm.filteredVideos[1].id, 'v3'); // 2026-02-01
      expect(vm.filteredVideos[2].id, 'v1'); // 2026-01-01
    });

    test('Sorting videos by date (asc)', () async {
      final mockClient = MockYoutubeApiClient(mockVideos: testVideos);
      final vm = DashboardViewModel(apiClient: mockClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      await vm.loadVideos(config);

      vm.selectSort('date_asc');
      vm.applySort();

      expect(vm.filteredVideos[0].id, 'v1'); // 2026-01-01
      expect(vm.filteredVideos[1].id, 'v3'); // 2026-02-01
      expect(vm.filteredVideos[2].id, 'v2'); // 2026-03-01
    });

    test('Offline fallback returns cached videos when API fails', () async {
      // 1. Populate cache first
      await prefRepo.saveCachedVideos(testVideos);

      // 2. Set up client that throws exception
      final brokenClient = YoutubeApiClient(); // will fail to load channels or fetch as no assets are mocked
      final vm = DashboardViewModel(apiClient: brokenClient, prefRepository: prefRepo);
      final config = TestConfig(uiTestMode: true, captureExternalLinks: true);

      // 3. Load videos (will fallback to cache)
      await vm.loadVideos(config);

      expect(vm.allVideos.length, 3);
      expect(vm.errorMessage, isNull);
    });
  });
}
