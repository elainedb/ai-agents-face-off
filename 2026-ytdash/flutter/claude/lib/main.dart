import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import 'src/config/app_config.dart';
import 'src/config/test_config.dart';
import 'src/data/api/youtube_api.dart';
import 'src/data/cache/video_cache.dart';
import 'src/data/repository/video_repository.dart';
import 'src/presentation/app_state.dart';
import 'src/presentation/external_link_overlay.dart';
import 'src/presentation/home_screen.dart';
import 'src/presentation/home_view_model.dart';
import 'src/presentation/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Build the semantics tree so Maestro can see element identifiers.
  SemanticsBinding.instance.ensureSemantics();

  final config = await TestConfig.load();
  final channels = await AppConfig.loadChannels();
  final baseUrl = config.apiBaseUrl ?? AppConfig.defaultApiBaseUrl;

  final api = YoutubeApi(baseUrl: baseUrl, apiKey: config.apiKey);
  final cache = VideoCache();
  final repository = VideoRepositoryImpl(
    api: api,
    cache: cache,
    channels: channels,
  );

  runApp(YtdashApp(config: config, repository: repository));
}

class YtdashApp extends StatelessWidget {
  const YtdashApp({
    super.key,
    required this.config,
    required this.repository,
  });

  final TestConfig config;
  final VideoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(config)),
        ChangeNotifierProvider(create: (_) => HomeViewModel(repository)),
      ],
      child: MaterialApp(
        title: 'ytdash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
        // Overlay the shared external-link surface above every route.
        builder: (context, child) =>
            ExternalLinkOverlay(child: child ?? const SizedBox.shrink()),
        home: const _Root(),
      ),
    );
  }
}

/// Routes between login and home based on observable auth state.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AppState, bool>((s) => s.signedIn);
    return signedIn ? const HomeScreen() : const LoginScreen();
  }
}
