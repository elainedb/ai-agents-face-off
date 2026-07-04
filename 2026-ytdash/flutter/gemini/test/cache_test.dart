import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/cache_repository.dart';
import 'package:ytdash_flutter/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and retrieves videos', () async {
      final cache = CacheRepository();
      
      var cached = await cache.getVideos();
      expect(cached, isNull);

      final videos = [
        Video(
          id: 'test',
          title: 'Test',
          description: 'Desc',
          publishedAt: DateTime(2022),
          category: 'tech',
          thumbnailUrl: 'url',
        )
      ];

      await cache.saveVideos(videos);

      cached = await cache.getVideos();
      expect(cached, isNotNull);
      expect(cached!.length, 1);
      expect(cached.first.id, 'test');
    });
  });
}
