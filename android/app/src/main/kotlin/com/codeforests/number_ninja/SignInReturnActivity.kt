package com.codeforests.number_ninja

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Receives numberninja://signin/... when Google sign-in finishes in the
 * Custom Tab (the server's /signin/google page opens it). It hands the link
 * to Dart and brings the app back in front of the tab, then closes.
 */
class SignInReturnActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val link = intent?.data
        if (link != null && link.scheme == "numberninja" && link.host == "signin") {
            MainActivity.signInChannel?.invokeMethod("returned", link.toString())
        }
        startActivity(
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP),
        )
        finish()
    }
}
