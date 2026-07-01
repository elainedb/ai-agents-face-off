import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/local/video_cache.dart';
import '../data/remote/youtube_api_client.dart';
import '../data/video_repository.dart';
import '../domain/models/source_channel.dart';
import 'test_config.dart';

/// Overridden in `main()` with the value loaded from the `ytdash/testconfig` MethodChannel.
final testConfigProvider = Provider<TestConfig>((ref) {
  throw UnimplementedError(
    'testConfigProvider must be overridden before runApp()',
  );
});

/// Production default; overridden by `apiBaseUrl` in UI-test-mode (constitution §4).
const _productionApiBaseUrl = 'https://www.googleapis.com';

/// Compiled-in for production builds via `--dart-define-from-file=config/secrets.env`.
/// UI-test-mode always overrides this at runtime with the `apiKey` launch extra.
const _compiledApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

final channelsProvider = FutureProvider<List<SourceChannel>>((ref) async {
  final raw = await rootBundle.loadString('config/channels.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list.cast<Map<String, dynamic>>().map(SourceChannel.fromJson).toList();
});

final videoCacheProvider = Provider<VideoCache>((ref) => VideoCache());

final apiClientProvider = Provider<YoutubeApiClient>((ref) {
  final config = ref.watch(testConfigProvider);
  final baseUrl = config.uiTestMode
      ? (config.apiBaseUrl ?? _productionApiBaseUrl)
      : _productionApiBaseUrl;
  final apiKey = config.uiTestMode
      ? (config.apiKey ?? _compiledApiKey)
      : _compiledApiKey;
  return YoutubeApiClient(baseUrl: baseUrl, apiKey: apiKey);
});

final videoRepositoryProvider = FutureProvider<VideoRepository>((ref) async {
  final channels = await ref.watch(channelsProvider.future);
  return VideoRepository(
    apiClient: ref.watch(apiClientProvider),
    cache: ref.watch(videoCacheProvider),
    channels: channels,
  );
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
