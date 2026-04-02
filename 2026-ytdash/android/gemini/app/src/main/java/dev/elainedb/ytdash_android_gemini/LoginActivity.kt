package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.ComponentActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.SignInButton
import com.google.android.gms.common.api.ApiException
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper

class LoginActivity : ComponentActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var tvError: TextView

    private val signInLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            val email = account.email
            Log.d("LoginActivity", "Email: $email")

            if (email != null && isAuthorized(email)) {
                Log.d("LoginActivity", "Access granted to $email")
                navigateToMain()
            } else {
                Log.d("LoginActivity", "Access denied for $email")
                tvError.text = "Access denied. Your email is not authorized."
                googleSignInClient.signOut()
            }
        } catch (e: ApiException) {
            Log.w("LoginActivity", "signInResult:failed code=" + e.statusCode)
            tvError.text = "Sign in failed. Error code: ${e.statusCode}"
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        ConfigHelper.init(this)
        tvError = findViewById(R.id.tvError)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestIdToken(getString(R.string.default_web_client_id_placeholder))
            .build()

        googleSignInClient = GoogleSignIn.getClient(this, gso)

        findViewById<SignInButton>(R.id.btnSignIn).setOnClickListener {
            val signInIntent = googleSignInClient.signInIntent
            signInLauncher.launch(signInIntent)
        }

        // Check if already signed in
        val lastAccount = GoogleSignIn.getLastSignedInAccount(this)
        if (lastAccount != null && lastAccount.email?.let { isAuthorized(it) } == true) {
            navigateToMain()
        }
    }

    private fun isAuthorized(email: String): Boolean {
        val authorizedEmails = ConfigHelper.getAuthorizedEmails()
        return authorizedEmails.contains(email)
    }

    private fun navigateToMain() {
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }
}
