import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/test_config.dart';
import '../../features/dashboard/view_models/dashboard_view_model.dart';

class LinkLauncher {
  static Future<void> launch(
    String url, {
    required TestConfig testConfig,
    required DashboardViewModel dashboardViewModel,
  }) async {
    dashboardViewModel.clearCapturedUrl();
    dashboardViewModel.clearExternalOpenError();

    if (testConfig.captureExternalLinks) {
      // Capture/test mode
      dashboardViewModel.setCapturedUrl(url);
    } else {
      // Real launch mode
      try {
        final uri = Uri.parse(url);
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!success) {
            dashboardViewModel.setExternalOpenError('Failed to launch external app for link: $url');
          }
        } else {
          dashboardViewModel.setExternalOpenError('No application handler found for link: $url');
        }
      } catch (e) {
        dashboardViewModel.setExternalOpenError('Error launching external link: $e');
      }
    }
  }
}
