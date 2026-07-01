import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';
import 'core/test_config.dart';
import 'presentation/app_root.dart';
import 'presentation/external_launch_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required so Maestro (and any accessibility-based automation) sees the semantics tree.
  SemanticsBinding.instance.ensureSemantics();

  final testConfig = await TestConfig.load();
  final appConfig = AppConfig.from(testConfig);

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(appConfig)],
      child: const YtdashApp(),
    ),
  );
}

class YtdashApp extends StatelessWidget {
  const YtdashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ytdash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppRoot(),
      builder: (context, child) => Stack(
        children: [
          ?child,
          const Positioned.fill(child: ExternalLaunchBanner()),
        ],
      ),
    );
  }
}
