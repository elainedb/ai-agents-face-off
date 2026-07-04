package com.example.ytdash_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun getSharedPreferences(name: String?, mode: Int): android.content.SharedPreferences {
        return createDeviceProtectedStorageContext().getSharedPreferences(name, mode)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "ytdash/testconfig")
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent.extras
                    val uiTestMode = e?.getBoolean("uiTestMode") ?: (e?.getString("uiTestMode") == "true")
                    val captureLinks = e?.getBoolean("captureExternalLinks") ?: (e?.getString("captureExternalLinks") == "true")
                    result.success(mapOf(
                        "uiTestMode" to uiTestMode,
                        "mockAuthEmail" to e?.getString("mockAuthEmail"),
                        "apiBaseUrl" to e?.getString("apiBaseUrl"),
                        "apiKey" to e?.getString("apiKey"),
                        "authorizedEmails" to e?.getString("authorizedEmails"),
                        "captureExternalLinks" to captureLinks
                    ))
                } else result.notImplemented()
            }
    }
}
