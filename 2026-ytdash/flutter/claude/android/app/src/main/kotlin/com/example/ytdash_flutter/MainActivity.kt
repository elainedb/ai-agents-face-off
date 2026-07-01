package com.example.ytdash_flutter

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "ytdash/testconfig"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, channelName)
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
