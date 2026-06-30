package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Surfaces the UI-test-mode launch-intent extras (constitution §4) to the
 * Flutter layer over a MethodChannel. Maestro delivers `launchApp.arguments`
 * as Android intent extras; we read them off the host Activity intent.
 */
class MainActivity : FlutterActivity() {
    private val channel = "ytdash/testconfig"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent.extras
                    result.success(
                        mapOf(
                            "uiTestMode" to extraBool(e?.get("uiTestMode")),
                            "mockAuthEmail" to e?.get("mockAuthEmail")?.toString(),
                            "apiBaseUrl" to e?.get("apiBaseUrl")?.toString(),
                            "apiKey" to e?.get("apiKey")?.toString(),
                            "authorizedEmails" to e?.get("authorizedEmails")?.toString(),
                            "captureExternalLinks" to extraBool(e?.get("captureExternalLinks")),
                        )
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    // Maestro may pass booleans as actual booleans or as the strings "true"/"1".
    private fun extraBool(v: Any?): Boolean = when (v) {
        is Boolean -> v
        is String -> v.equals("true", ignoreCase = true) || v == "1"
        is Number -> v.toInt() != 0
        else -> false
    }
}
