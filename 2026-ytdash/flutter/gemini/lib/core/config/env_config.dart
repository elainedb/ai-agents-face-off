import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static late String youtubeApiKey;
  static late List<Map<String, String>> channels;

  static Future<void> load() async {
    // Load secrets
    final secrets = await rootBundle.loadString('config/secrets.env');
    final lines = secrets.split('\n');
    for (final line in lines) {
      if (line.startsWith('YOUTUBE_API_KEY=')) {
        youtubeApiKey = line.substring('YOUTUBE_API_KEY='.length).trim();
      }
    }

    // Load channels
    final channelsStr = await rootBundle.loadString('config/channels.json');
    final List<dynamic> channelsJson = json.decode(channelsStr);
    channels = channelsJson
        .map((e) => {'id': e['id'].toString(), 'label': e['label'].toString()})
        .toList();
  }
}
