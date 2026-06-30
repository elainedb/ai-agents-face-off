// Domain smoke test for the Video model serialization round-trip.
import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/src/domain/video.dart';

void main() {
  test('Video JSON round-trips through the cache encoding', () {
    final videos = [
      Video(
        id: 'A',
        title: 'Alpha',
        description: 'desc',
        publishedAt: DateTime.utc(2026, 1, 1),
        category: 'tech',
        thumbnailUrl: 'http://x/t.jpg',
        lat: 1.5,
        lng: -2.5,
      ),
      Video(
        id: 'B',
        title: 'Beta',
        description: 'desc2',
        publishedAt: DateTime.utc(2026, 2, 2),
        category: 'music',
        thumbnailUrl: '',
      ),
    ];

    final decoded = Video.decodeList(Video.encodeList(videos));
    expect(decoded.length, 2);
    expect(decoded[0].id, 'A');
    expect(decoded[0].hasLocation, isTrue);
    expect(decoded[0].youtubeUrl, 'https://www.youtube.com/watch?v=A');
    expect(decoded[1].hasLocation, isFalse);
  });
}
