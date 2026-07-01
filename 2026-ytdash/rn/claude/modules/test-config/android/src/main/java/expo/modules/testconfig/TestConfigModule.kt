package expo.modules.testconfig

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

// Surfaces the Android launch-intent extras (the UI-test-mode contract, constitution §4) to JS.
// Maestro delivers `launchApp.arguments` as intent extras on the launched Activity, so we read
// them from the current activity's intent. Values are coerced defensively because Maestro may
// deliver booleans as real booleans (--ez) or as strings depending on the delivery path.
class TestConfigModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TestConfig")

    Function("getConfig") {
      val extras = appContext.currentActivity?.intent?.extras

      fun str(key: String): String? = extras?.get(key)?.toString()
      fun bool(key: String): Boolean {
        return when (val v = extras?.get(key)) {
          null -> false
          is Boolean -> v
          else -> v.toString().equals("true", ignoreCase = true)
        }
      }

      mapOf(
        "uiTestMode" to bool("uiTestMode"),
        "mockAuthEmail" to str("mockAuthEmail"),
        "apiBaseUrl" to str("apiBaseUrl"),
        "apiKey" to str("apiKey"),
        "authorizedEmails" to str("authorizedEmails"),
        "captureExternalLinks" to bool("captureExternalLinks")
      )
    }
  }
}
