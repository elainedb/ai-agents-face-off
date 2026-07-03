import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ytdash_flutter/data/models/channel.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/services/cache_service.dart';
import 'package:ytdash_flutter/data/services/geocoding_service.dart';
import 'package:ytdash_flutter/data/services/youtube_service.dart';
import 'package:ytdash_flutter/data/repositories/video_repository.dart';
import 'package:ytdash_flutter/ui/features/auth/view_models/auth_view_model.dart';
import 'package:ytdash_flutter/ui/features/auth/views/login_screen.dart';
import 'package:ytdash_flutter/ui/features/home/view_models/video_view_model.dart';
import 'package:ytdash_flutter/ui/features/home/views/home_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Force semantics tree creation for Maestro automation
  SemanticsBinding.instance.ensureSemantics();

  // Default values
  String defaultApiKey = 'YOUR_YOUTUBE_API_KEY'; // Fallback
  List<ChannelConfig> channels = [];
  final List<String> defaultEmails = [
    'user1@example.com',
    'user2@example.com',
  ];

  // 3. Load aggregated channels from assets
  try {
    final channelsStr = await rootBundle.loadString('config/channels.json');
    final List<dynamic> channelsJson = jsonDecode(channelsStr) as List<dynamic>;
    channels = channelsJson
        .map((item) => ChannelConfig.fromJson(item as Map<String, dynamic>))
        .toList();
    print('Loaded ${channels.length} source channels from assets.');
  } catch (e) {
    print('Error loading config/channels.json asset: $e');
    // Fallback static list just in case
    channels = [
      ChannelConfig(id: 'UCynoa1DjwnvHAowA_jiMEAQ', label: 'cronicas'),
      ChannelConfig(id: 'UCK0KOjX3beyB9nzonls0cuw', label: 'bike'),
      ChannelConfig(id: 'UCACkIrvrGAQ7kuc0hMVwvmA', label: 'mnt'),
      ChannelConfig(id: 'UCtWRAKKvOEA0CXOue9BG8ZA', label: 'mct'),
    ];
  }

  // 4. Load secrets from secrets.env asset
  try {
    final secretsStr = await rootBundle.loadString('config/secrets.env');
    final lines = secretsStr.split('\n');
    for (final line in lines) {
      if (line.startsWith('YOUTUBE_API_KEY=')) {
        final key = line.substring('YOUTUBE_API_KEY='.length).trim();
        if (key.isNotEmpty) {
          defaultApiKey = key;
          print('Loaded YOUTUBE_API_KEY successfully from secrets.env asset.');
        }
      }
    }
  } catch (e) {
    print('Error loading config/secrets.env asset (using default fallback): $e');
  }

  // 5. Load runtime configuration from launch intent extras (MethodChannel)
  final config = await TestConfig.load(
    defaultBaseUrl: 'https://www.googleapis.com',
    defaultApiKey: defaultApiKey,
    defaultEmails: defaultEmails,
  );

  print('Initialized App with TestConfig: $config');

  // 6. Initialize services & repositories (dependency injection)
  final youtubeService = YoutubeService();
  final cacheService = CacheService();
  final geocodingService = GeocodingService();
  final videoRepository = VideoRepository(
    youtubeService: youtubeService,
    cacheService: cacheService,
    geocodingService: geocodingService,
  );

  // 7. Instantiate ViewModels
  final authViewModel = AuthViewModel();
  final videoViewModel = VideoViewModel(videoRepository: videoRepository);

  runApp(MyApp(
    config: config,
    channels: channels,
    authViewModel: authViewModel,
    videoViewModel: videoViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final TestConfig config;
  final List<ChannelConfig> channels;
  final AuthViewModel authViewModel;
  final VideoViewModel videoViewModel;

  const MyApp({
    super.key,
    required this.config,
    required this.channels,
    required this.authViewModel,
    required this.videoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF0055),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF0055),
          secondary: Color(0xFF7A00FF),
          background: Color(0xFF0F0F1A),
        ),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: authViewModel,
        builder: (context, _) {
          if (authViewModel.isAuthenticated) {
            return HomeScreen(
              authViewModel: authViewModel,
              videoViewModel: videoViewModel,
              config: config,
              channels: channels,
            );
          } else {
            return LoginScreen(
              viewModel: authViewModel,
              config: config,
            );
          }
        },
      ),
      // Centralized builder to overlay external link capture banners globally across any screen (§3 & §4)
      builder: (context, child) {
        return ListenableBuilder(
          listenable: authViewModel,
          builder: (context, _) {
            return Stack(
              children: [
                if (child != null) child,

                // 1. External open URL capture banner
                if (authViewModel.capturedUrl != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: Semantics(
                      identifier: 'external_open_url',
                      child: Material(
                        color: const Color(0xFF16162A),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Color(0xFF00FF88)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Captured External Link (UI Test Mode):',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      authViewModel.capturedUrl!,
                                      style: const TextStyle(
                                        color: Color(0xFF00FF88),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                                onPressed: () => authViewModel.clearCapturedUrl(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 2. External open error banner
                if (authViewModel.externalOpenError != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: Semantics(
                      identifier: 'external_open_error',
                      child: Material(
                        color: const Color(0xFF2A1616),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'External Open Error:',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      authViewModel.externalOpenError!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                                onPressed: () => authViewModel.clearExternalOpenError(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
