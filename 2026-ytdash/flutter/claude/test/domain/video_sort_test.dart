import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/domain/sorting/video_sort.dart';

Video _video(String id, String title, String date) => Video(
  id: id,
  title: title,
  description: '',
  publishedAt: DateTime.parse(date),
  category: 'cat',
  thumbnailUrl: '',
);

void main() {
  final videos = [
    _video('1', 'Middle Clip', '2026-03-01T00:00:00Z'),
    _video('2', 'ZZZ Newest Clip', '2026-06-20T00:00:00Z'),
    _video('3', 'AAA Oldest Clip', '2025-12-01T00:00:00Z'),
  ];

  test('dateNewest puts the latest publishedAt first', () {
    final sorted = sortVideos(videos, SortOption.dateNewest);
    expect(sorted.first.title, 'ZZZ Newest Clip');
    expect(sorted.last.title, 'AAA Oldest Clip');
  });

  test('dateOldest puts the earliest publishedAt first', () {
    final sorted = sortVideos(videos, SortOption.dateOldest);
    expect(sorted.first.title, 'AAA Oldest Clip');
    expect(sorted.last.title, 'ZZZ Newest Clip');
  });

  test('titleAToZ sorts alphabetically ascending, case-insensitively', () {
    final sorted = sortVideos(videos, SortOption.titleAToZ);
    expect(sorted.map((v) => v.title).toList(), ['AAA Oldest Clip', 'Middle Clip', 'ZZZ Newest Clip']);
  });

  test('titleZToA sorts alphabetically descending', () {
    final sorted = sortVideos(videos, SortOption.titleZToA);
    expect(sorted.map((v) => v.title).toList(), ['ZZZ Newest Clip', 'Middle Clip', 'AAA Oldest Clip']);
  });

  test('does not mutate the input list', () {
    final original = List<Video>.from(videos);
    sortVideos(videos, SortOption.dateNewest);
    expect(videos.map((v) => v.id).toList(), original.map((v) => v.id).toList());
  });
}
