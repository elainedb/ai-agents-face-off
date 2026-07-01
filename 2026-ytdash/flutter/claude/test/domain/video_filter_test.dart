import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/domain/filtering/video_filter.dart';

Video _video(String id, String category) => Video(
  id: id,
  title: 'title $id',
  description: '',
  publishedAt: DateTime(2026),
  category: category,
  thumbnailUrl: '',
);

void main() {
  final videos = [_video('1', 'tech'), _video('2', 'music'), _video('3', 'tech'), _video('4', 'news')];

  test('null category returns every video unchanged', () {
    expect(filterByCategory(videos, null), videos);
  });

  test('filters to only the matching category', () {
    final result = filterByCategory(videos, 'tech');
    expect(result.map((v) => v.id).toList(), ['1', '3']);
  });

  test('a category with no matches returns an empty list', () {
    expect(filterByCategory(videos, 'sports'), isEmpty);
  });
}
