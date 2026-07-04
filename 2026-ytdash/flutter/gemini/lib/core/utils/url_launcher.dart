import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/test_config.dart';

Future<void> launchExternalUrl(BuildContext context, String url) async {
  if (TestConfig.instance.captureExternalLinks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link Captured'),
        content: Semantics(
          identifier: 'external_open_url',
          child: Text(url),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final uri = Uri.parse(url);
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError(context);
    }
  } catch (e) {
    _showError(context);
  }
}

void _showError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Semantics(
        identifier: 'external_open_error',
        child: const Text('Could not open external link'),
      ),
    ),
  );
}
