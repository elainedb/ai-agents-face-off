/// A configured source channel to aggregate (config/channels.json). There is no catch-all
/// "all channels" endpoint on the real YouTube Data API, so every channel must be iterated and
/// merged — see spec/youtube-api.md.
class SourceChannel {
  const SourceChannel({required this.id, required this.label});

  final String id;
  final String label;

  factory SourceChannel.fromJson(Map<String, dynamic> json) =>
      SourceChannel(id: json['id'] as String, label: json['label'] as String);
}
