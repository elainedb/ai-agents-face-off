import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/data/services/cache_service.dart';
import 'package:ytdash_flutter/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Whitelist Tests', () {
    late AuthViewModel authVm;
    late TestConfig config;

    setUp(() {
      authVm = AuthViewModel();
      config = TestConfig(
        uiTestMode: true,
        mockAuthEmail: 'user1@example.com',
        apiBaseUrl: 'http://127.0.0.1:8092',
        apiKey: 'DUMMY_KEY',
        authorizedEmails: ['user1@example.com', 'user2@example.com'],
        captureExternalLinks: true,
      );
    });

    test('Authorized email is accepted (case-insensitive and trimmed)', () async {
      final configMixedCase = TestConfig(
        uiTestMode: true,
        mockAuthEmail: '  User1@example.com  ',
        apiBaseUrl: config.apiBaseUrl,
        apiKey: config.apiKey,
        authorizedEmails: config.authorizedEmails,
        captureExternalLinks: config.captureExternalLinks,
      );

      await authVm.signInWithGoogle(configMixedCase);
      expect(authVm.isAuthenticated, isTrue);
      expect(authVm.currentEmail, equals('user1@example.com'));
      expect(authVm.errorMessage, isNull);
    });

    test('Unauthorized email is rejected', () async {
      final configUnauthorized = TestConfig(
        uiTestMode: true,
        mockAuthEmail: 'stranger@gmail.com',
        apiBaseUrl: config.apiBaseUrl,
        apiKey: config.apiKey,
        authorizedEmails: config.authorizedEmails,
        captureExternalLinks: config.captureExternalLinks,
      );

      await authVm.signInWithGoogle(configUnauthorized);
      expect(authVm.isAuthenticated, isFalse);
      expect(authVm.currentEmail, isNull);
      expect(authVm.errorMessage, contains('Email not authorized'));
    });

    test('Sign out resets authentication state', () async {
      await authVm.signInWithGoogle(config);
      expect(authVm.isAuthenticated, isTrue);

      await authVm.signOut();
      expect(authVm.isAuthenticated, isFalse);
      expect(authVm.currentEmail, isNull);
    });
  });

  group('Sorting & Filtering Tests', () {
    late List<Video> testVideos;

    setUp(() {
      testVideos = [
        Video(
          id: '1',
          title: 'Tech Talk One',
          description: 'A tech talk',
          publishedAt: '2026-03-01T10:00:00Z',
          category: 'tech',
          thumbnailUrl: 'thumb1',
        ),
        Video(
          id: '2',
          title: 'ZZZ Newest Clip',
          description: 'Latest video',
          publishedAt: '2026-03-05T12:00:00Z',
          category: 'music',
          thumbnailUrl: 'thumb2',
        ),
        Video(
          id: '3',
          title: 'AAA Oldest Clip',
          description: 'Oldest video',
          publishedAt: '2026-01-01T08:00:00Z',
          category: 'tech',
          thumbnailUrl: 'thumb3',
        ),
      ];
    });

    test('Filtering only keeps matching categories', () {
      final filtered = testVideos.where((v) => v.category == 'tech').toList();
      expect(filtered.length, equals(2));
      expect(filtered.any((v) => v.title == 'ZZZ Newest Clip'), isFalse);
    });

    test('Sorting by date descending puts newest first', () {
      final sorted = List<Video>.from(testVideos);
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      expect(sorted.first.title, equals('ZZZ Newest Clip'));
      expect(sorted.last.title, equals('AAA Oldest Clip'));
    });

    test('Sorting by date ascending puts oldest first', () {
      final sorted = List<Video>.from(testVideos);
      sorted.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
      expect(sorted.first.title, equals('AAA Oldest Clip'));
      expect(sorted.last.title, equals('ZZZ Newest Clip'));
    });
  });

  group('Cache Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('CacheService saves and loads video lists successfully', () async {
      final cacheService = CacheService();
      final videosToCache = [
        Video(
          id: 'video-123',
          title: 'Cached Video',
          description: 'Desc',
          publishedAt: '2026-02-02T02:00:00Z',
          category: 'tech',
          thumbnailUrl: 'url',
          lat: 1.23,
          lng: 4.56,
          locationName: 'Test Location',
        ),
      ];

      await cacheService.saveVideos(videosToCache);

      final loadedVideos = await cacheService.loadVideos();
      expect(loadedVideos.length, equals(1));
      expect(loadedVideos.first.id, equals('video-123'));
      expect(loadedVideos.first.title, equals('Cached Video'));
      expect(loadedVideos.first.lat, equals(1.23));
      expect(loadedVideos.first.lng, equals(4.56));
      expect(loadedVideos.first.locationName, equals('Test Location'));
    });
  });
}
