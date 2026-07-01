import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/models/video.dart';
import 'package:ytdash_flutter/domain/sorting_filtering.dart';

Video _video(String id, String category) => Video(
      id: id,
      title: 'Video $id',
      description: '',
      publishedAt: DateTime(2026, 1, 1),
      category: category,
      thumbnailUrl: '',
    );

void main() {
  final videos = [
    _video('1', 'tech'),
    _video('2', 'tech'),
    _video('3', 'music'),
    _video('4', 'news'),
  ];

  group('filterVideos', () {
    test('null category returns every video unchanged', () {
      expect(filterVideos(videos, null), videos);
    });

    test('keeps only the matching category', () {
      final result = filterVideos(videos, 'tech');
      expect(result.map((v) => v.id), ['1', '2']);
    });

    test('returns an empty list for a category with no matches', () {
      expect(filterVideos(videos, 'sports'), isEmpty);
    });
  });
}
