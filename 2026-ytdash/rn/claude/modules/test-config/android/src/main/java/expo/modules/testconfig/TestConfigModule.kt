package expo.modules.testconfig

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

// Reads the UI-test-mode launch-intent extras (constitution §4) off the host Activity and
// surfaces them to JS. Maestro delivers `launchApp.arguments` as Android intent extras; RN does
// not expose these to JS by default, so this small native module bridges them.
class TestConfigModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TestConfig")

    Function("getTestConfig") {
      val extras = appContext.currentActivity?.intent?.extras

      fun boolOf(key: String): Boolean {
        val v = extras?.get(key) ?: return false
        return when (v) {
          is Boolean -> v
          is String -> v.equals("true", ignoreCase = true) || v == "1"
          is Number -> v.toInt() != 0
          else -> false
        }
      }

      fun strOf(key: String): String? {
        val v = extras?.get(key) ?: return null
        val s = v.toString()
        return if (s.isEmpty()) null else s
      }

      mapOf(
        "uiTestMode" to boolOf("uiTestMode"),
        "mockAuthEmail" to strOf("mockAuthEmail"),
        "apiBaseUrl" to strOf("apiBaseUrl"),
        "apiKey" to strOf("apiKey"),
        "authorizedEmails" to strOf("authorizedEmails"),
        "captureExternalLinks" to boolOf("captureExternalLinks")
      )
    }
  }
}
