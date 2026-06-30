package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Surfaces the UI-test-mode launch-intent extras (constitution §4) to the Dart layer over a
 * MethodChannel. Maestro delivers `launchApp.arguments` as Android intent extras on this Activity;
 * Dart reads them once in main() before runApp().
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ytdash/testconfig")
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent.extras
                    result.success(
                        mapOf(
                            "uiTestMode" to (e?.getBoolean("uiTestMode") ?: false),
                            "mockAuthEmail" to e?.getString("mockAuthEmail"),
                            "apiBaseUrl" to e?.getString("apiBaseUrl"),
                            "apiKey" to e?.getString("apiKey"),
                            "authorizedEmails" to e?.getString("authorizedEmails"),
                            "captureExternalLinks" to (e?.getBoolean("captureExternalLinks") ?: false),
                        )
                    )
                } else {
                    result.notImplemented()
                }
            }
    }
}
