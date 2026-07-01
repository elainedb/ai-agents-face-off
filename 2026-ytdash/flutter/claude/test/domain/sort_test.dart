import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/models/video.dart';
import 'package:ytdash_flutter/domain/sorting_filtering.dart';

Video _video(String id, String title, DateTime publishedAt) => Video(
      id: id,
      title: title,
      description: '',
      publishedAt: publishedAt,
      category: 'tech',
      thumbnailUrl: '',
    );

void main() {
  final videos = [
    _video('1', 'Middle Clip', DateTime(2026, 3, 1)),
    _video('2', 'ZZZ Newest Clip', DateTime(2026, 6, 20)),
    _video('3', 'AAA Oldest Clip', DateTime(2025, 12, 1)),
  ];

  group('sortVideos', () {
    test('dateDescending puts the newest publishedAt first', () {
      final sorted = sortVideos(videos, SortOrder.dateDescending);
      expect(sorted.first.title, 'ZZZ Newest Clip');
      expect(sorted.last.title, 'AAA Oldest Clip');
    });

    test('dateAscending puts the oldest publishedAt first', () {
      final sorted = sortVideos(videos, SortOrder.dateAscending);
      expect(sorted.first.title, 'AAA Oldest Clip');
      expect(sorted.last.title, 'ZZZ Newest Clip');
    });

    test('titleAscending sorts alphabetically, case-insensitive', () {
      final sorted = sortVideos(videos, SortOrder.titleAscending);
      expect(sorted.map((v) => v.title).toList(), [
        'AAA Oldest Clip',
        'Middle Clip',
        'ZZZ Newest Clip',
      ]);
    });

    test('does not mutate the input list', () {
      final original = List<Video>.of(videos);
      sortVideos(videos, SortOrder.dateDescending);
      expect(videos, orderedEquals(original));
    });
  });
}
