import 'dart:convert';

import 'package:http/http.dart' as http;

import 'channel_config.dart';
import 'models/video.dart';

/// Remote data source talking to the YouTube Data API v3 *shape* (mock or real — same code).
///
/// Honors the two hard rules from youtube-api.md:
///  - **No catch-all**: iterate the configured channels and merge/dedupe by videoId.
///  - **Fetch ALL pages**: follow `nextPageToken` for every channel until exhausted.
class YoutubeApi {
  YoutubeApi({required this.baseUrl, this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final String? apiKey;
  final http.Client _client;

  // Safety cap so a misbehaving endpoint can't loop forever.
  static const int _maxPagesPerChannel = 50;

  Uri _uri(String endpoint, Map<String, String> params) {
    final qp = <String, String>{
      if (apiKey != null && apiKey!.isNotEmpty) 'key': apiKey!,
      ...params,
    };
    return Uri.parse('$baseUrl/youtube/v3/$endpoint').replace(queryParameters: qp);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw http.ClientException('HTTP ${resp.statusCode} for $uri');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Aggregates every configured channel, following pagination, then enriches with location.
  Future<List<Video>> fetchAllVideos(List<SourceChannel> channels) async {
    final byId = <String, Video>{};

    for (final channel in channels) {
      final channelVideos = await _fetchChannel(channel);
      for (final v in channelVideos) {
        // First channel wins on dedupe (stable across real data where a video repeats).
        byId.putIfAbsent(v.id, () => v);
      }
    }

    final videos = byId.values.toList();
    await _enrichWithLocations(videos, byId);
    return byId.values.toList();
  }

  /// search.list for one channel, following nextPageToken until exhausted.
  Future<List<Video>> _fetchChannel(SourceChannel channel) async {
    final out = <Video>[];
    String? pageToken;
    var pages = 0;

    do {
      final uri = _uri('search', {
        'channelId': channel.id,
        'part': 'snippet',
        'order': 'date',
        'type': 'video',
        'maxResults': '50',
        if (pageToken != null) 'pageToken': pageToken,
      });
      final json = await _getJson(uri);
      final items = (json['items'] as List<dynamic>? ?? const []);
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final video = _videoFromSearchItem(item, channel.label);
        if (video != null) out.add(video);
      }
      pageToken = json['nextPageToken'] as String?;
      pages++;
    } while (pageToken != null && pages < _maxPagesPerChannel);

    return out;
  }

  Video? _videoFromSearchItem(Map<String, dynamic> item, String label) {
    final idField = item['id'];
    String? videoId;
    if (idField is Map<String, dynamic>) {
      videoId = idField['videoId'] as String?;
    } else if (idField is String) {
      videoId = idField;
    }
    if (videoId == null || videoId.isEmpty) return null;

    final snippet = item['snippet'] as Map<String, dynamic>? ?? const {};
    return Video(
      id: videoId,
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      // category = the configured source-channel label (youtube-api.md), not categoryId.
      category: label,
      thumbnailUrl: _thumbUrl(snippet),
    );
  }

  String _thumbUrl(Map<String, dynamic> snippet) {
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
    for (final key in ['medium', 'high', 'default']) {
      final t = thumbs[key] as Map<String, dynamic>?;
      final url = t?['url'] as String?;
      if (url != null && url.isNotEmpty) return url;
    }
    return '';
  }

  /// videos.list (batched up to 50 ids) → recordingDetails.location for the located videos.
  Future<void> _enrichWithLocations(
      List<Video> videos, Map<String, Video> byId) async {
    const batchSize = 50;
    for (var i = 0; i < videos.length; i += batchSize) {
      final batch = videos.sublist(i, (i + batchSize).clamp(0, videos.length));
      final ids = batch.map((v) => v.id).join(',');
      final uri = _uri('videos', {
        'id': ids,
        'part': 'snippet,contentDetails,recordingDetails',
      });
      final json = await _getJson(uri);
      final items = (json['items'] as List<dynamic>? ?? const []);
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final loc = (item['recordingDetails']
            as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
        if (loc == null) continue;
        final lat = (loc['latitude'] as num?)?.toDouble();
        final lng = (loc['longitude'] as num?)?.toDouble();
        final existing = byId[id];
        if (existing != null && lat != null && lng != null) {
          byId[id] = existing.copyWith(lat: lat, lng: lng);
        }
      }
    }
  }

  void close() => _client.close();
}
