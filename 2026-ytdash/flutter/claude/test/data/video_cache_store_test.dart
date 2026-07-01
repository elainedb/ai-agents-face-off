import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/local/video_cache_store.dart';
import 'package:ytdash_flutter/data/models/video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns null when nothing has been cached yet', () async {
    final store = VideoCacheStore();
    expect(await store.load(), isNull);
  });

  test('save then load round-trips the video list (constitution §1.5 persistence)', () async {
    final store = VideoCacheStore();
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
    ];

    await store.save(videos);
    final loaded = await store.load();

    expect(loaded, isNotNull);
    expect(loaded!.length, 1);
    expect(loaded.first.id, 'VIDEO_ID_1');
    expect(loaded.first.title, 'Tech Talk One');
    expect(loaded.first.lat, 48.8566);
    expect(loaded.first.publishedAt, DateTime.parse('2026-03-01T10:00:00Z'));
  });

  test('save replaces the previous cache entirely', () async {
    final store = VideoCacheStore();
    await store.save([Video(id: '1', title: 'a', description: '', publishedAt: DateTime(2026), category: 'c', thumbnailUrl: '')]);
    await store.save([Video(id: '2', title: 'b', description: '', publishedAt: DateTime(2026), category: 'c', thumbnailUrl: '')]);

    final loaded = await store.load();
    expect(loaded!.length, 1);
    expect(loaded.first.id, '2');
  });
}
