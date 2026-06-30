import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/src/domain/video.dart';
import 'package:ytdash_flutter/src/domain/video_query.dart';

Video _v(String id, String title, String category, DateTime date) => Video(
      id: id,
      title: title,
      description: '',
      publishedAt: date,
      category: category,
      thumbnailUrl: '',
    );

void main() {
  final videos = [
    _v('1', 'Tech Talk One', 'tech', DateTime.utc(2026, 3, 1)),
    _v('8', 'ZZZ Newest Clip', 'music', DateTime.utc(2026, 6, 20)),
    _v('7', 'AAA Oldest Clip', 'news', DateTime.utc(2025, 12, 1)),
    _v('2', 'Tech Talk Two', 'tech', DateTime.utc(2026, 2, 1)),
  ];

  test('no sort field preserves insertion/API order', () {
    final out = const VideoQuery().apply(videos);
    expect(out.map((v) => v.id).toList(), ['1', '8', '7', '2']);
  });

  test('sort by date descending puts newest first', () {
    final out = const VideoQuery(
      sortField: SortField.date,
      sortDirection: SortDirection.descending,
    ).apply(videos);
    expect(out.first.title, 'ZZZ Newest Clip');
  });

  test('sort by date ascending puts oldest first', () {
    final out = const VideoQuery(
      sortField: SortField.date,
      sortDirection: SortDirection.ascending,
    ).apply(videos);
    expect(out.first.title, 'AAA Oldest Clip');
  });

  test('sort by title ascending is alphabetical', () {
    final out = const VideoQuery(
      sortField: SortField.title,
      sortDirection: SortDirection.ascending,
    ).apply(videos);
    expect(out.first.title, 'AAA Oldest Clip');
    expect(out.last.title, 'ZZZ Newest Clip');
  });

  test('filter by category keeps only that bucket', () {
    final out = const VideoQuery(categoryFilter: 'tech').apply(videos);
    expect(out.length, 2);
    expect(out.every((v) => v.category == 'tech'), isTrue);
    expect(out.any((v) => v.title == 'ZZZ Newest Clip'), isFalse);
  });

  test('availableCategories lists distinct labels in first-appearance order', () {
    expect(availableCategories(videos), ['tech', 'music', 'news']);
  });
}
