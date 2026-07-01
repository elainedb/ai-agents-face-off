import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'external_link_state.dart';

class ExternalLinkNotifier extends Notifier<ExternalLinkState> {
  @override
  ExternalLinkState build() => const ExternalLinkIdle();

  Future<void> open(String url, {required bool captureExternalLinks}) async {
    if (captureExternalLinks) {
      state = ExternalLinkCaptured(url);
      return;
    }
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      state = launched ? const ExternalLinkIdle() : const ExternalLinkFailed();
    } catch (_) {
      state = const ExternalLinkFailed();
    }
  }

  void dismiss() => state = const ExternalLinkIdle();
}

final externalLinkNotifierProvider =
    NotifierProvider<ExternalLinkNotifier, ExternalLinkState>(
      ExternalLinkNotifier.new,
    );
