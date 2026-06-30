package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Surfaces the launch-intent extras (constitution §4 UI-test-mode contract) to
 * the Flutter layer over a MethodChannel. Maestro delivers `launchApp.arguments`
 * as Android intent extras on this Activity; the Dart side reads them once at
 * startup via `TestConfig.load()`.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "ytdash/testconfig"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent?.extras
                    result.success(
                        mapOf(
                            "uiTestMode" to boolExtra(e?.get("uiTestMode")),
                            "mockAuthEmail" to stringExtra(e?.get("mockAuthEmail")),
                            "apiBaseUrl" to stringExtra(e?.get("apiBaseUrl")),
                            "apiKey" to stringExtra(e?.get("apiKey")),
                            "authorizedEmails" to stringExtra(e?.get("authorizedEmails")),
                            "captureExternalLinks" to boolExtra(e?.get("captureExternalLinks")),
                        )
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    // Maestro may deliver extras as booleans or as strings; accept both.
    private fun boolExtra(v: Any?): Boolean = when (v) {
        is Boolean -> v
        is Number -> v.toInt() != 0
        is String -> v == "true" || v == "1"
        else -> false
    }

    private fun stringExtra(v: Any?): String? = when (v) {
        null -> null
        is String -> v
        else -> v.toString()
    }
}
