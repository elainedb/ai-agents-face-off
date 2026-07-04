import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../test_config.dart';

class ExternalLinkManager extends StatefulWidget {
  final Widget child;

  const ExternalLinkManager({super.key, required this.child});

  static ExternalLinkManagerState of(BuildContext context) {
    return context.findAncestorStateOfType<ExternalLinkManagerState>()!;
  }

  @override
  State<ExternalLinkManager> createState() => ExternalLinkManagerState();
}

class ExternalLinkManagerState extends State<ExternalLinkManager> {
  String? _capturedUrl;
  String? _error;

  Future<void> openYoutubeVideo(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';

    if (TestConfig.instance.captureExternalLinks) {
      setState(() {
        _capturedUrl = url;
        _error = null;
      });
      return;
    }

    try {
      final uri = Uri.parse(url);
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        setState(() {
          _error = 'Could not launch $url';
          _capturedUrl = null;
        });
      } else {
        setState(() {
          _error = null;
          _capturedUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not launch $url';
        _capturedUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (_capturedUrl != null)
          Material(
            color: Colors.green,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Semantics(
                  identifier: 'external_open_url',
                  child: Text(
                    _capturedUrl!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if (_error != null)
          Material(
            color: Colors.red,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Semantics(
                  identifier: 'external_open_error',
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
