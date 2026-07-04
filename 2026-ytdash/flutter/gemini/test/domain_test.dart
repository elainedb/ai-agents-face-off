import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/models.dart';
import 'package:ytdash_flutter/presentation/providers.dart';

void main() {
  group('VideoListState domain logic', () {
    final v1 = Video(
      id: '1',
      title: 'AAA Oldest Clip',
      description: '',
      publishedAt: DateTime(2020, 1, 1),
      category: 'tech',
      thumbnailUrl: '',
    );
    final v2 = Video(
      id: '2',
      title: 'ZZZ Newest Clip',
      description: '',
      publishedAt: DateTime(2023, 1, 1),
      category: 'music',
      thumbnailUrl: '',
    );
    final v3 = Video(
      id: '3',
      title: 'Mid Clip',
      description: '',
      publishedAt: DateTime(2021, 1, 1),
      category: 'tech',
      thumbnailUrl: '',
    );

    final videos = [v3, v1, v2];

    test('sortDateDesc = true sorts newest first', () {
      final state = VideoListState(videos: videos, sortDateDesc: true);
      final sorted = state.visibleVideos;
      expect(sorted.first.id, '2'); // 2023
      expect(sorted.last.id, '1'); // 2020
    });

    test('sortDateDesc = false sorts oldest first', () {
      final state = VideoListState(videos: videos, sortDateDesc: false);
      final sorted = state.visibleVideos;
      expect(sorted.first.id, '1'); // 2020
      expect(sorted.last.id, '2'); // 2023
    });

    test('filtering by category works', () {
      final state = VideoListState(videos: videos, currentFilter: 'tech');
      final filtered = state.visibleVideos;
      expect(filtered.length, 2);
      expect(filtered.every((v) => v.category == 'tech'), isTrue);
    });
  });
}
