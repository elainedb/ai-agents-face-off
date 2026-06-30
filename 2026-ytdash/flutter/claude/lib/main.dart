import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/config/app_config.dart';
import 'src/config/test_config.dart';
import 'src/state/providers.dart';
import 'src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Build the semantics tree so Maestro (and assistive tech) can see our
  // stable identifiers even without a screen reader active (constitution §3).
  SemanticsBinding.instance.ensureSemantics();

  final testConfig = await TestConfig.fromHost();
  final appConfig = await AppConfig.load();

  runApp(
    ProviderScope(
      overrides: [
        testConfigProvider.overrideWithValue(testConfig),
        appConfigProvider.overrideWithValue(appConfig),
      ],
      child: const YtDashApp(),
    ),
  );
}
