import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/local/video_cache.dart';
import 'package:ytdash_flutter/domain/entities/video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('read returns empty list when nothing has been cached', () async {
    final cache = VideoCache();
    expect(await cache.read(), isEmpty);
  });

  test('write then read round-trips the video list', () async {
    final cache = VideoCache();
    final videos = [
      Video(
        id: 'VIDEO_ID_1',
        title: 'Tech Talk One',
        description: 'A talk about tech.',
        publishedAt: DateTime.parse('2026-03-01T10:00:00Z'),
        category: 'cronicas',
        thumbnailUrl: 'https://i.ytimg.com/vi/VIDEO_ID_1/mqdefault.jpg',
        lat: 48.8566,
        lng: 2.3522,
      ),
      Video(
        id: 'VIDEO_ID_8',
        title: 'ZZZ Newest Clip',
        description: 'The newest clip.',
        publishedAt: DateTime.parse('2026-06-20T10:00:00Z'),
        category: 'bike',
        thumbnailUrl: 'https://i.ytimg.com/vi/VIDEO_ID_8/mqdefault.jpg',
      ),
    ];

    await cache.write(videos);
    final readBack = await cache.read();

    expect(readBack.length, 2);
    expect(readBack.map((v) => v.id), containsAll(['VIDEO_ID_1', 'VIDEO_ID_8']));
    final first = readBack.firstWhere((v) => v.id == 'VIDEO_ID_1');
    expect(first.title, 'Tech Talk One');
    expect(first.lat, 48.8566);
    expect(first.lng, 2.3522);
    final second = readBack.firstWhere((v) => v.id == 'VIDEO_ID_8');
    expect(second.hasLocation, isFalse);
  });

  test('write replaces the previous cache rather than appending', () async {
    final cache = VideoCache();
    final v1 = Video(
      id: 'A',
      title: 'A',
      description: '',
      publishedAt: DateTime.now(),
      category: 'x',
      thumbnailUrl: '',
    );
    final v2 = Video(
      id: 'B',
      title: 'B',
      description: '',
      publishedAt: DateTime.now(),
      category: 'x',
      thumbnailUrl: '',
    );
    await cache.write([v1]);
    await cache.write([v2]);
    final readBack = await cache.read();
    expect(readBack.map((v) => v.id), ['B']);
  });

  test('clear removes the cached data', () async {
    final cache = VideoCache();
    await cache.write([
      Video(
        id: 'A',
        title: 'A',
        description: '',
        publishedAt: DateTime.now(),
        category: 'x',
        thumbnailUrl: '',
      ),
    ]);
    await cache.clear();
    expect(await cache.read(), isEmpty);
  });
}
