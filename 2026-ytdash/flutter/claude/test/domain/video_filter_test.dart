import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/entities/video.dart';
import 'package:ytdash_flutter/domain/filtering/video_filter.dart';

Video _v(String id, String title, String category) => Video(
      id: id,
      title: title,
      description: '',
      publishedAt: DateTime.now(),
      category: category,
      thumbnailUrl: '',
    );

void main() {
  final videos = [
    _v('1', 'Tech Talk One', 'cronicas'),
    _v('4', 'Music Session', 'bike'),
    _v('8', 'ZZZ Newest Clip', 'bike'),
    _v('5', 'News Roundup', 'mnt'),
  ];

  test('filters to only the matching category, case-insensitively', () {
    final result = filterByCategory(videos, 'CRONICAS');
    expect(result.map((v) => v.title), ['Tech Talk One']);
  });

  test('excludes videos from other categories', () {
    final result = filterByCategory(videos, 'cronicas');
    expect(result.any((v) => v.title == 'ZZZ Newest Clip'), isFalse);
  });

  test('null or empty label returns all videos unfiltered', () {
    expect(filterByCategory(videos, null), videos);
    expect(filterByCategory(videos, ''), videos);
  });

  test('distinctCategories preserves first-appearance order', () {
    expect(distinctCategories(videos), ['cronicas', 'bike', 'mnt']);
  });
}
