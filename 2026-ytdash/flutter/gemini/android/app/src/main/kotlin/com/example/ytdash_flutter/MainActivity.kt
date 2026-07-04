package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "ytdash/testconfig")
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent.extras
                    val uiTestModeStr = e?.get("uiTestMode")?.toString()
                    val uiTestMode = uiTestModeStr?.toBoolean() ?: false
                    
                    val captureStr = e?.get("captureExternalLinks")?.toString()
                    val captureExternal = captureStr?.toBoolean() ?: false

                    result.success(mapOf(
                        "uiTestMode" to uiTestMode,
                        "mockAuthEmail" to e?.get("mockAuthEmail")?.toString(),
                        "apiBaseUrl" to e?.get("apiBaseUrl")?.toString(),
                        "authorizedEmails" to e?.get("authorizedEmails")?.toString(),
                        "captureExternalLinks" to captureExternal,
                        "apiKey" to e?.get("apiKey")?.toString()
                    ))
                } else {
                    result.notImplemented()
                }
            }
    }
}
