package com.example.ytdash_flutter

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ytdash/testconfig")
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val e = intent.extras
                    val configMap = mapOf(
                        "uiTestMode" to getBoolExtraSafe(e, "uiTestMode"),
                        "mockAuthEmail" to getStringExtraSafe(e, "mockAuthEmail"),
                        "apiBaseUrl" to getStringExtraSafe(e, "apiBaseUrl"),
                        "apiKey" to getStringExtraSafe(e, "apiKey"),
                        "authorizedEmails" to getStringExtraSafe(e, "authorizedEmails"),
                        "captureExternalLinks" to getBoolExtraSafe(e, "captureExternalLinks")
                    )
                    result.success(configMap)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getBoolExtraSafe(extras: Bundle?, key: String): Boolean {
        if (extras == null) return false
        val v = extras.get(key)
        if (v is Boolean) return v
        if (v is String) return v.equals("true", ignoreCase = true)
        return false
    }

    private fun getStringExtraSafe(extras: Bundle?, key: String): String? {
        if (extras == null) return null
        val v = extras.get(key)
        return v?.toString()
    }
}
