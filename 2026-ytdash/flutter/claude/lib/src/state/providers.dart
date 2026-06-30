import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../config/test_config.dart';
import '../data/auth_service.dart';
import '../data/video_cache.dart';
import '../data/video_repository.dart';
import '../data/youtube_api.dart';
import '../domain/auth_policy.dart';
import 'auth_controller.dart';
import 'external_link_controller.dart';
import 'videos_controller.dart';

/// Authorized emails for production / real mode (not a secret). Used only when
/// the run does not supply an `authorizedEmails` override.
const List<String> kProductionAuthorizedEmails = [
  'user1@example.com',
  'user2@example.com',
];

/// Overridden in `main()` with the values read from the host Activity.
final testConfigProvider = Provider<TestConfig>(
  (ref) => throw UnimplementedError('testConfigProvider must be overridden'),
);

/// Overridden in `main()` with the loaded asset config.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);

final authPolicyProvider = Provider<AuthPolicy>((ref) {
  final cfg = ref.watch(testConfigProvider);
  final emails =
      cfg.authorizedEmailList.isNotEmpty ? cfg.authorizedEmailList : kProductionAuthorizedEmails;
  return AuthPolicy(emails);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final cfg = ref.watch(testConfigProvider);
  if (cfg.uiTestMode) {
    return MockAuthService(cfg.mockAuthEmail);
  }
  return GoogleAuthService();
});

final youtubeApiProvider = Provider<YoutubeApi>((ref) {
  final cfg = ref.watch(testConfigProvider);
  final appCfg = ref.watch(appConfigProvider);
  final api = YoutubeApi(
    baseUrl: cfg.apiBaseUrl ?? appCfg.fallbackBaseUrl,
    apiKey: cfg.apiKey ?? appCfg.fallbackApiKey,
  );
  ref.onDispose(api.dispose);
  return api;
});

final videoCacheProvider = Provider<VideoCache>((ref) => VideoCache());

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(
    api: ref.watch(youtubeApiProvider),
    cache: ref.watch(videoCacheProvider),
    channels: ref.watch(appConfigProvider).channels,
  );
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

final videosControllerProvider =
    NotifierProvider<VideosController, VideosState>(VideosController.new);

final externalLinkControllerProvider =
    NotifierProvider<ExternalLinkController, ExternalLinkState>(
        ExternalLinkController.new);
