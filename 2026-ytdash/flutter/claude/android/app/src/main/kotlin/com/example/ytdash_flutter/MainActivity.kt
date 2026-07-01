package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "ytdash/testconfig"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "get") {
                val e = intent.extras
                result.success(
                    mapOf(
                        "uiTestMode" to boolExtra(e, "uiTestMode"),
                        "mockAuthEmail" to e?.get("mockAuthEmail")?.toString(),
                        "apiBaseUrl" to e?.get("apiBaseUrl")?.toString(),
                        "apiKey" to e?.get("apiKey")?.toString(),
                        "authorizedEmails" to e?.get("authorizedEmails")?.toString(),
                        "captureExternalLinks" to boolExtra(e, "captureExternalLinks"),
                    )
                )
            } else {
                result.notImplemented()
            }
        }
    }

    // Extras arrive typed as Boolean when Maestro passes a YAML literal, but defensively also
    // accept a String "true"/"false" in case of a different launch path (e.g. adb shell am start).
    private fun boolExtra(e: android.os.Bundle?, key: String): Boolean {
        val v = e?.get(key) ?: return false
        return when (v) {
            is Boolean -> v
            is String -> v.equals("true", ignoreCase = true)
            else -> false
        }
    }
}
