import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:ytdash_flutter/data/local/video_cache.dart';
import 'package:ytdash_flutter/domain/models/video.dart';

Video _video(String id) => Video(
      id: id,
      title: 'Title $id',
      description: 'Description $id',
      publishedAt: DateTime(2026, 1, 1),
      category: 'tech',
      thumbnailUrl: 'https://example.com/$id.jpg',
      lat: 48.8566,
      lng: 2.3522,
    );

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  test('read() returns an empty list when nothing has been cached', () async {
    final cache = VideoCache();
    expect(await cache.read(), isEmpty);
  });

  test('write() then read() round-trips the video list, including location', () async {
    final cache = VideoCache();
    final videos = [_video('1'), _video('2')];

    await cache.write(videos);
    final result = await cache.read();

    expect(result.map((v) => v.id), ['1', '2']);
    expect(result.first.title, 'Title 1');
    expect(result.first.lat, 48.8566);
    expect(result.first.lng, 2.3522);
  });

  test('write() replaces the previous cache contents (not appends)', () async {
    final cache = VideoCache();
    await cache.write([_video('1')]);
    await cache.write([_video('2')]);

    final result = await cache.read();
    expect(result.map((v) => v.id), ['2']);
  });

  test('clear() empties the cache', () async {
    final cache = VideoCache();
    await cache.write([_video('1')]);
    await cache.clear();

    expect(await cache.read(), isEmpty);
  });
}
