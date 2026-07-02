package expo.modules.testconfig

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

// Reads the UI-test-mode launch-intent extras (constitution.md §4) off the host Activity's
// Intent. Maestro's `launchApp.arguments` are delivered as Android intent extras regardless of
// framework; React Native does not expose them to JS on its own, hence this small native module.
class TestConfigModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TestConfig")

    Function("get") {
      val extras = appContext.currentActivity?.intent?.extras
      mapOf(
        "uiTestMode" to (extras?.getBoolean("uiTestMode", false) ?: false),
        "mockAuthEmail" to extras?.getString("mockAuthEmail"),
        "apiBaseUrl" to extras?.getString("apiBaseUrl"),
        "apiKey" to extras?.getString("apiKey"),
        "authorizedEmails" to extras?.getString("authorizedEmails"),
        "captureExternalLinks" to (extras?.getBoolean("captureExternalLinks", false) ?: false)
      )
    }
  }
}
