import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/src/data/models/video.dart';
import 'package:ytdash_flutter/src/domain/auth.dart';
import 'package:ytdash_flutter/src/domain/filtering.dart';
import 'package:ytdash_flutter/src/domain/sorting.dart';

Video _v(String id, String title, String date, String category,
        {double? lat, double? lng}) =>
    Video(
      id: id,
      title: title,
      description: '',
      publishedAt: date,
      category: category,
      thumbnailUrl: '',
      lat: lat,
      lng: lng,
    );

void main() {
  group('auth whitelist', () {
    const list = ['user2@example.com', 'User1@example.com'];

    test('authorized email passes (case-insensitive, trimmed)', () {
      expect(isAuthorized('user2@example.com', list), isTrue);
      expect(isAuthorized('  USER2@example.com ', list), isTrue);
      expect(isAuthorized('user1@example.com', list), isTrue);
    });

    test('non-authorized email is rejected', () {
      expect(isAuthorized('intruder@evil.com', list), isFalse);
      expect(isAuthorized('', list), isFalse);
      expect(isAuthorized(null, list), isFalse);
    });
  });

  group('sorting', () {
    final videos = [
      _v('1', 'Mango', '2026-02-01T10:00:00Z', 'tech'),
      _v('2', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z', 'music'),
      _v('3', 'AAA Oldest Clip', '2025-12-01T10:00:00Z', 'news'),
    ];

    test('date descending puts newest first', () {
      final sorted = sortVideos(videos, SortOption.dateDesc);
      expect(sorted.first.title, 'ZZZ Newest Clip');
    });

    test('date ascending puts oldest first', () {
      final sorted = sortVideos(videos, SortOption.dateAsc);
      expect(sorted.first.title, 'AAA Oldest Clip');
    });

    test('title ascending is alphabetical', () {
      final sorted = sortVideos(videos, SortOption.titleAsc);
      expect(sorted.first.title, 'AAA Oldest Clip');
      expect(sorted.last.title, 'ZZZ Newest Clip');
    });

    test('sort does not mutate the input', () {
      final original = [...videos];
      sortVideos(videos, SortOption.dateDesc);
      expect(videos, equals(original));
    });
  });

  group('filtering', () {
    final videos = [
      _v('1', 'Tech Talk One', '2026-03-01T10:00:00Z', 'cronicas'),
      _v('2', 'Tech Talk Two', '2026-02-01T10:00:00Z', 'cronicas'),
      _v('3', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z', 'bike'),
      _v('4', 'News Roundup', '2026-05-01T10:00:00Z', 'mnt'),
    ];

    test('filter keeps only the chosen label', () {
      final filtered = filterByLabel(videos, 'cronicas');
      expect(filtered.map((v) => v.title),
          containsAll(['Tech Talk One', 'Tech Talk Two']));
      expect(filtered.any((v) => v.title == 'ZZZ Newest Clip'), isFalse);
    });

    test('null/empty label returns all', () {
      expect(filterByLabel(videos, null).length, videos.length);
      expect(filterByLabel(videos, '').length, videos.length);
    });

    test('available categories in first-appearance order', () {
      expect(availableCategories(videos), ['cronicas', 'bike', 'mnt']);
    });
  });
}
