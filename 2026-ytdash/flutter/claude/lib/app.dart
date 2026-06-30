import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/test_config.dart';
import 'data/video_repository.dart';
import 'presentation/auth_controller.dart';
import 'presentation/external_open_controller.dart';
import 'presentation/home_screen.dart';
import 'presentation/login_screen.dart';
import 'presentation/video_controller.dart';
import 'presentation/widgets/external_open_banner.dart';

class YtdashApp extends StatelessWidget {
  const YtdashApp({super.key, required this.config, required this.repository});

  final TestConfig config;
  final VideoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(config: config)),
        ChangeNotifierProvider(create: (_) => VideoController(repository: repository)),
        ChangeNotifierProvider(create: (_) => ExternalOpenController(config: config)),
      ],
      child: MaterialApp(
        title: 'ytdash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        // The external-open banner is lifted above the Navigator so it serves both the list and
        // the map sheet (cross-framework-setup §C).
        builder: (context, child) => Stack(
          children: [
            if (child != null) child,
            const ExternalOpenBanner(),
          ],
        ),
        home: Consumer<AuthController>(
          builder: (_, auth, _) =>
              auth.signedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
