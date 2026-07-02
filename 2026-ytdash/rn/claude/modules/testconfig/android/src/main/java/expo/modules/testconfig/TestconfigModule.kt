package expo.modules.testconfig

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class TestconfigModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Testconfig")

    Function("getTestConfig") {
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
