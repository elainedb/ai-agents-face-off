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
                    val e = intent?.extras
                    
                    // Safely get boolean or string-based boolean
                    fun getBoolExtra(key: String): Boolean {
                        if (e == null) return false
                        if (e.containsKey(key)) {
                            val v = e.get(key)
                            if (v is Boolean) return v
                            if (v is String) return v.lowercase() == "true" || v == "1"
                        }
                        return false
                    }

                    fun getStringExtra(key: String): String? {
                        if (e == null) return null
                        if (e.containsKey(key)) {
                            val v = e.get(key)
                            if (v != null) return v.toString()
                        }
                        return null
                    }

                    result.success(mapOf(
                        "uiTestMode" to getBoolExtra("uiTestMode"),
                        "mockAuthEmail" to getStringExtra("mockAuthEmail"),
                        "apiBaseUrl" to getStringExtra("apiBaseUrl"),
                        "apiKey" to getStringExtra("apiKey"),
                        "authorizedEmails" to getStringExtra("authorizedEmails"),
                        "captureExternalLinks" to getBoolExtra("captureExternalLinks")
                    ))
                } else {
                    result.notImplemented()
                }
            }
    }
}

