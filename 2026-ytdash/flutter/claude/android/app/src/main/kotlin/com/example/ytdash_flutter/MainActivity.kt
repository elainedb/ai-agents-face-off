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
                val extras = intent.extras
                result.success(
                    mapOf(
                        "uiTestMode" to (extras?.getBoolean("uiTestMode") ?: false),
                        "mockAuthEmail" to extras?.getString("mockAuthEmail"),
                        "apiBaseUrl" to extras?.getString("apiBaseUrl"),
                        "apiKey" to extras?.getString("apiKey"),
                        "authorizedEmails" to extras?.getString("authorizedEmails"),
                        "captureExternalLinks" to (extras?.getBoolean("captureExternalLinks") ?: false),
                    )
                )
            } else {
                result.notImplemented()
            }
        }
    }
}
