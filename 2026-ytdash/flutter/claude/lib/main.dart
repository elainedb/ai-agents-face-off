import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app.dart';
import 'core/test_config.dart';
import 'data/channel_config.dart';
import 'data/video_cache.dart';
import 'data/video_repository.dart';
import 'data/youtube_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure the semantics tree is built so Maestro can see the stable identifiers even before any
  // assistive tech is attached (cross-framework-setup §A).
  SemanticsBinding.instance.ensureSemantics();

  final config = await TestConfig.load();
  final channels = await loadChannels();

  final api = YoutubeApi(baseUrl: config.effectiveApiBase, apiKey: config.apiKey);
  final repository = VideoRepositoryImpl(
    api: api,
    cache: VideoCache(),
    channels: channels,
  );

  runApp(YtdashApp(config: config, repository: repository));
}
