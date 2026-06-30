import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/src/config/app_config.dart';
import 'package:ytdash_flutter/src/data/api/youtube_api.dart';
import 'package:ytdash_flutter/src/data/cache/video_cache.dart';
import 'package:ytdash_flutter/src/data/models/video.dart';
import 'package:ytdash_flutter/src/data/repository/video_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Fresh in-memory SharedPreferences for each test.
    SharedPreferences.setMockInitialValues({});
  });

  group('Video JSON mapping', () {
    test('parses a search.list item', () {
      final item = {
        'id': {'kind': 'youtube#video', 'videoId': 'ABC'},
        'snippet': {
          'title': 'Hello',
          'description': 'World',
          'publishedAt': '2026-01-01T00:00:00Z',
          'thumbnails': {
            'medium': {'url': 'http://x/m.jpg'},
          },
        },
      };
      final v = Video.fromSearchItem(item, category: 'tech');
      expect(v, isNotNull);
      expect(v!.id, 'ABC');
      expect(v.title, 'Hello');
      expect(v.category, 'tech');
      expect(v.thumbnailUrl, 'http://x/m.jpg');
      expect(v.youtubeUrl, 'https://www.youtube.com/watch?v=ABC');
    });

    test('parses a playlistItems resourceId id', () {
      final item = {
        'snippet': {
          'title': 'P',
          'resourceId': {'videoId': 'XYZ'},
        },
      };
      expect(Video.fromSearchItem(item, category: 'm')!.id, 'XYZ');
    });

    test('round-trips through JSON', () {
      const v = Video(
        id: 'A',
        title: 'T',
        description: 'D',
        publishedAt: '2026-01-01T00:00:00Z',
        category: 'c',
        thumbnailUrl: 'u',
        lat: 1.5,
        lng: -2.5,
      );
      final back = Video.fromJson(jsonDecode(jsonEncode(v.toJson())));
      expect(back.id, 'A');
      expect(back.lat, 1.5);
      expect(back.lng, -2.5);
      expect(back.hasLocation, isTrue);
    });
  });

  group('VideoCache (persistence)', () {
    setUp(() {
      // Reset shared_preferences in-memory store.
      // (SharedPreferences uses an in-memory map under test.)
    });

    test('write then read returns the same videos', () async {
      final cache = VideoCache();
      const videos = [
        Video(
          id: 'A',
          title: 'T',
          description: 'D',
          publishedAt: '2026-01-01T00:00:00Z',
          category: 'c',
          thumbnailUrl: 'u',
        ),
      ];
      await cache.save(videos);
      final read = await cache.load();
      expect(read.length, 1);
      expect(read.first.id, 'A');
      expect(await cache.hasData(), isTrue);
    });
  });

  group('YoutubeApi pagination + aggregation', () {
    // Two channels, paginated 1-per-page, plus videos.list locations.
    final channels = [
      const SourceChannel(id: 'CH1', label: 'alpha'),
      const SourceChannel(id: 'CH2', label: 'beta'),
    ];
    final data = {
      'CH1': ['v1', 'v2'],
      'CH2': ['v3'],
    };

    http.Response handle(http.Request req) {
      final q = req.url.queryParameters;
      if (req.url.path == '/youtube/v3/search') {
        final ch = q['channelId']!;
        final ids = data[ch] ?? [];
        final offset = int.tryParse(q['pageToken'] ?? '0') ?? 0;
        final body = <String, dynamic>{
          'items': offset < ids.length
              ? [
                  {
                    'id': {'videoId': ids[offset]},
                    'snippet': {
                      'title': ids[offset],
                      'publishedAt': '2026-01-0${offset + 1}T00:00:00Z',
                      'thumbnails': {},
                    },
                  }
                ]
              : [],
        };
        if (offset + 1 < ids.length) body['nextPageToken'] = '${offset + 1}';
        return http.Response(jsonEncode(body), 200);
      }
      if (req.url.path == '/youtube/v3/videos') {
        final ids = (q['id'] ?? '').split(',');
        return http.Response(
          jsonEncode({
            'items': [
              for (final id in ids)
                {
                  'id': id,
                  'snippet': {'title': id},
                  // give v1 a location only
                  if (id == 'v1')
                    'recordingDetails': {
                      'location': {'latitude': 10.0, 'longitude': 20.0}
                    },
                }
            ],
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    }

    test('follows pagination and aggregates all channels', () async {
      final api = YoutubeApi(
        baseUrl: 'http://mock',
        client: MockClient((r) async => handle(r)),
      );
      final videos = await api.fetchAllVideos(channels);
      expect(videos.map((v) => v.id), ['v1', 'v2', 'v3']);
      // label attached from the source channel
      expect(videos.firstWhere((v) => v.id == 'v1').category, 'alpha');
      expect(videos.firstWhere((v) => v.id == 'v3').category, 'beta');
      // location enriched via videos.list
      final v1 = videos.firstWhere((v) => v.id == 'v1');
      expect(v1.hasLocation, isTrue);
      expect(v1.lat, 10.0);
    });

    test('repository persists fresh and falls back to cache on error',
        () async {
      final cache = VideoCache();
      // 1) success path persists
      final okRepo = VideoRepositoryImpl(
        api: YoutubeApi(
            baseUrl: 'http://mock',
            client: MockClient((r) async => handle(r))),
        cache: cache,
        channels: channels,
      );
      final ok = await okRepo.getVideos(forceRefresh: true);
      expect(ok.fromCache, isFalse);
      expect(ok.videos.length, 3);

      // 2) failure path falls back to the cached 3 with no fatal error
      final failRepo = VideoRepositoryImpl(
        api: YoutubeApi(
            baseUrl: 'http://mock',
            client: MockClient((r) async => http.Response('boom', 500))),
        cache: cache,
        channels: channels,
      );
      final stale = await failRepo.getVideos(forceRefresh: true);
      expect(stale.fromCache, isTrue);
      expect(stale.videos.length, 3);
    });
  });
}
