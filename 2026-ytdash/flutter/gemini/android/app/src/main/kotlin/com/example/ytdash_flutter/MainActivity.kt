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
          result.success(mapOf(
            "uiTestMode" to (e?.getBoolean("uiTestMode") ?: false),
            "mockAuthEmail" to e?.getString("mockAuthEmail"),
            "apiBaseUrl" to e?.getString("apiBaseUrl"),
            "apiKey" to e?.getString("apiKey"),
            "authorizedEmails" to e?.getString("authorizedEmails"),
            "captureExternalLinks" to (e?.getBoolean("captureExternalLinks") ?: false)
          ))
        } else {
          result.notImplemented()
        }
      }
  }
}
