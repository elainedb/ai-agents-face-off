import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/src/data/video_cache.dart';
import 'package:ytdash_flutter/src/domain/video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists and reloads the video list (AC-CACHE-01 behavior)', () async {
    final cache = VideoCache();
    expect(await cache.hasData(), isFalse);
    expect(await cache.load(), isEmpty);

    final videos = [
      Video(
        id: 'X',
        title: 'Cached',
        description: 'd',
        publishedAt: DateTime.utc(2026, 1, 1),
        category: 'tech',
        thumbnailUrl: '',
        lat: 10,
        lng: 20,
      ),
    ];
    await cache.save(videos);

    expect(await cache.hasData(), isTrue);
    final loaded = await cache.load();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'X');
    expect(loaded.first.hasLocation, isTrue);
  });

  test('save replaces the previous list', () async {
    final cache = VideoCache();
    await cache.save([
      Video(
        id: 'old',
        title: 'old',
        description: '',
        publishedAt: DateTime.utc(2026),
        category: 'tech',
        thumbnailUrl: '',
      ),
    ]);
    await cache.save([
      Video(
        id: 'new',
        title: 'new',
        description: '',
        publishedAt: DateTime.utc(2026),
        category: 'tech',
        thumbnailUrl: '',
      ),
    ]);
    final loaded = await cache.load();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'new');
  });
}
