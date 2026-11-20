package com.brainbubblz.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Receives brainbubblz://signin/... when Google sign-in finishes in the
 * Custom Tab (the server's /signin/google page opens it). It hands the link
 * to Dart and brings the app back in front of the tab, then closes.
 */
class SignInReturnActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val link = intent?.data
        if (link != null && link.scheme == "brainbubblz" && link.host == "signin") {
            MainActivity.signInChannel?.invokeMethod("returned", link.toString())
        }
        // Back to the app's own task and its existing MainActivity (CLEAR_TOP also
        // closes the Custom Tab above it); never a second MainActivity.
        startActivity(
            Intent(this, MainActivity::class.java).addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            ),
        )
        finish()
    }
}
