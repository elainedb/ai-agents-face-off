import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_codex/features/videos/domain/entities/video.dart';

void main() {
  test('video location text combines city and country', () {
    final video = Video(
      id: '1',
      title: 'Title',
      channelName: 'Channel',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      publishedAt: DateTime(2025, 1, 1),
      tags: ['a'],
      city: 'Paris',
      country: 'France',
    );

    expect(video.locationText, 'Paris, France');
    expect(video.hasLocation, isTrue);
    expect(video.hasCoordinates, isFalse);
  });
}
