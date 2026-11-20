package com.brainbubblz.kids

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        signInChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "brainbubblz/sign_in")
        // Crash reports (FEAT-24 AD-5): app version and coarse device facts.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "brainbubblz/device")
            .setMethodCallHandler { call, result ->
                if (call.method != "info") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val pkg = packageManager.getPackageInfo(packageName, 0)
                val code =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        pkg.longVersionCode
                    } else {
                        @Suppress("DEPRECATION")
                        pkg.versionCode.toLong()
                    }
                result.success(
                    mapOf(
                        "versionName" to (pkg.versionName ?: "unknown"),
                        "versionCode" to code,
                        "model" to Build.MODEL,
                        "manufacturer" to Build.MANUFACTURER,
                        "release" to Build.VERSION.RELEASE,
                        "sdk" to Build.VERSION.SDK_INT,
                    ),
                )
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        signInChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        /// Google sign-in's return link goes to Dart here (SignInBrowser.open).
        var signInChannel: MethodChannel? = null
    }
}
