package com.brainbubblz.kids

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        signInChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "brainbubblz/sign_in")
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
