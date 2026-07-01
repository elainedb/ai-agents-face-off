/// Lifted to the app root so both the video list and the map detail sheet share one banner
/// (cross-framework-setup.md §C note: "lift captured/external_open_url to the app root").
sealed class ExternalLinkState {
  const ExternalLinkState();
}

class ExternalLinkIdle extends ExternalLinkState {
  const ExternalLinkIdle();
}

/// UI-test-mode (`captureExternalLinks=true`): the target URL is shown instead of launched,
/// so the flow can assert it deterministically (AC-LIST-03, AC-MAP-03).
class ExternalLinkCaptured extends ExternalLinkState {
  const ExternalLinkCaptured(this.url);
  final String url;
}

/// A real external launch was attempted (`captureExternalLinks=false`) and failed — surfaced
/// rather than crashing or silently doing nothing (AC-LINK-01).
class ExternalLinkFailed extends ExternalLinkState {
  const ExternalLinkFailed();
}
