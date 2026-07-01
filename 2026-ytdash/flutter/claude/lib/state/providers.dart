import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/test_config.dart';
import '../data/remote/youtube_api_client.dart';
import '../data/repository/video_repository.dart';
import '../data/repository/video_repository_impl.dart';
import 'auth_controller.dart';
import 'external_link_controller.dart';
import 'home_controller.dart';

/// Overridden in `main()` once [TestConfig.load] resolves, before `runApp`.
final testConfigProvider = Provider<TestConfig>(
  (ref) => throw UnimplementedError('testConfigProvider not overridden'),
);

final apiClientProvider = Provider<YoutubeApiClient>((ref) {
  final config = ref.watch(testConfigProvider);
  return YoutubeApiClient(baseUrl: config.apiBaseUrl, apiKey: config.apiKey);
});

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final externalLinkControllerProvider =
    NotifierProvider<ExternalLinkController, ExternalLinkState>(
      ExternalLinkController.new,
    );

/// Re-created each time the home screen is (re)entered after a fresh login, via `.autoDispose`.
final homeControllerProvider =
    NotifierProvider.autoDispose<HomeController, HomeState>(HomeController.new);
