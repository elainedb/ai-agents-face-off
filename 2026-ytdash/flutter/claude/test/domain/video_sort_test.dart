import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/entities/video.dart';
import 'package:ytdash_flutter/domain/sorting/video_sort.dart';

Video _v(String id, String title, String date) => Video(
      id: id,
      title: title,
      description: '',
      publishedAt: DateTime.parse(date),
      category: 'tech',
      thumbnailUrl: '',
    );

void main() {
  final videos = [
    _v('1', 'Tech Talk One', '2026-03-01T10:00:00Z'),
    _v('7', 'AAA Oldest Clip', '2025-12-01T10:00:00Z'),
    _v('8', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z'),
  ];

  test('dateDesc puts the newest first', () {
    final sorted = sortVideos(videos, SortKey.dateDesc);
    expect(sorted.first.title, 'ZZZ Newest Clip');
    expect(sorted.last.title, 'AAA Oldest Clip');
  });

  test('dateAsc puts the oldest first', () {
    final sorted = sortVideos(videos, SortKey.dateAsc);
    expect(sorted.first.title, 'AAA Oldest Clip');
    expect(sorted.last.title, 'ZZZ Newest Clip');
  });

  test('titleAsc sorts alphabetically', () {
    final sorted = sortVideos(videos, SortKey.titleAsc);
    expect(sorted.map((v) => v.title), ['AAA Oldest Clip', 'Tech Talk One', 'ZZZ Newest Clip']);
  });

  test('titleDesc sorts reverse-alphabetically', () {
    final sorted = sortVideos(videos, SortKey.titleDesc);
    expect(sorted.map((v) => v.title), ['ZZZ Newest Clip', 'Tech Talk One', 'AAA Oldest Clip']);
  });

  test('sortVideos does not mutate the input list', () {
    final original = List<Video>.of(videos);
    sortVideos(videos, SortKey.dateDesc);
    expect(videos, original);
  });

  test('sort labels end with the keyword the harness matches on', () {
    expect(sortKeyLabel(SortKey.dateDesc).toLowerCase(), endsWith('newest'));
    expect(sortKeyLabel(SortKey.dateAsc).toLowerCase(), endsWith('oldest'));
  });
}
