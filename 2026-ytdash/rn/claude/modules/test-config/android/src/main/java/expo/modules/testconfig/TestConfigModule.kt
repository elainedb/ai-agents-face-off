package expo.modules.testconfig

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

/**
 * Surfaces the launch Activity's intent extras to JS so the app can honor the UI-test-mode
 * contract (constitution §4). RN's Linking only exposes VIEW-intent data, not arbitrary extras
 * delivered by Maestro's `launchApp.arguments`, so this native seam is required.
 *
 * Every value is normalized to its String form. Maestro may deliver a boolean extra (`--ez`) or a
 * string extra (`--es`); `.toString()` yields "true"/"false" or the raw string either way, and the
 * JS loader coerces from there. This keeps the module agnostic to Maestro's extra encoding.
 */
class TestConfigModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TestConfig")

    Function("getConfig") {
      val out = HashMap<String, String?>()
      val extras = appContext.currentActivity?.intent?.extras ?: return@Function out
      for (key in extras.keySet()) {
        out[key] = extras.get(key)?.toString()
      }
      out
    }
  }
}
