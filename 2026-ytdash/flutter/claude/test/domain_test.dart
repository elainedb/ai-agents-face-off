// Domain + persistence unit tests (constitution §2: meaningful coverage of logic).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/data/video_cache.dart';
import 'package:ytdash_flutter/domain/auth.dart';
import 'package:ytdash_flutter/domain/video_query.dart';

Video _v(String id, String title, String category, String date, {double? lat, double? lng}) =>
    Video(
      id: id,
      title: title,
      description: 'desc $id',
      publishedAt: DateTime.parse(date),
      category: category,
      thumbnailUrl: '',
      lat: lat,
      lng: lng,
    );

void main() {
  final sample = <Video>[
    _v('V1', 'Tech Talk One', 'cronicas', '2026-03-01T10:00:00Z', lat: 48.8, lng: 2.3),
    _v('V2', 'Tech Talk Two', 'cronicas', '2026-02-01T10:00:00Z'),
    _v('V8', 'ZZZ Newest Clip', 'bike', '2026-06-20T10:00:00Z'),
    _v('V7', 'AAA Oldest Clip', 'mnt', '2025-12-01T10:00:00Z'),
  ];

  group('AuthPolicy', () {
    const policy = AuthPolicy(['user2@example.com', 'user1@example.com']);

    test('authorized email is admitted (case-insensitive, trimmed)', () {
      expect(policy.isAuthorized('user2@example.com'), isTrue);
      expect(policy.isAuthorized('  USER2@example.com '), isTrue);
    });

    test('unauthorized or empty email is rejected', () {
      expect(policy.isAuthorized('stranger@gmail.com'), isFalse);
      expect(policy.isAuthorized(''), isFalse);
      expect(policy.isAuthorized(null), isFalse);
    });
  });

  group('VideoQuery.filter', () {
    test('filters to a single category label', () {
      final result = VideoQuery.filter(sample, 'cronicas');
      expect(result.map((v) => v.id), ['V1', 'V2']);
    });

    test('null/empty category returns everything', () {
      expect(VideoQuery.filter(sample, null).length, sample.length);
      expect(VideoQuery.filter(sample, '').length, sample.length);
    });

    test('categoriesOf returns distinct labels in first-appearance order', () {
      expect(VideoQuery.categoriesOf(sample), ['cronicas', 'bike', 'mnt']);
    });
  });

  group('VideoQuery.sort', () {
    test('date descending puts newest first', () {
      final sorted = VideoQuery.sort(sample, SortOption.dateDesc);
      expect(sorted.first.title, 'ZZZ Newest Clip');
    });

    test('date ascending puts oldest first', () {
      final sorted = VideoQuery.sort(sample, SortOption.dateAsc);
      expect(sorted.first.title, 'AAA Oldest Clip');
    });

    test('title ascending is alphabetical', () {
      final sorted = VideoQuery.sort(sample, SortOption.titleAsc);
      expect(sorted.first.title, 'AAA Oldest Clip');
    });

    test('none preserves input order', () {
      final sorted = VideoQuery.sort(sample, SortOption.none);
      expect(sorted.map((v) => v.id), sample.map((v) => v.id));
    });
  });

  group('VideoCache (persistence)', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('round-trips videos through disk, preserving location', () async {
      final cache = VideoCache();
      await cache.save(sample);
      final loaded = await cache.load();
      expect(loaded.length, sample.length);
      expect(loaded.first.id, 'V1');
      expect(loaded.first.hasLocation, isTrue);
      expect(loaded.first.lat, closeTo(48.8, 0.0001));
      expect(loaded[1].hasLocation, isFalse);
    });

    test('empty store returns an empty list', () async {
      final cache = VideoCache();
      expect(await cache.load(), isEmpty);
    });
  });
}
