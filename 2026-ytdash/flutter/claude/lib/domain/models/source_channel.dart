/// A configured YouTube channel to aggregate, with its user-facing category label.
class SourceChannel {
  const SourceChannel({required this.id, required this.label});

  final String id;
  final String label;

  factory SourceChannel.fromJson(Map<String, dynamic> json) {
    return SourceChannel(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}
