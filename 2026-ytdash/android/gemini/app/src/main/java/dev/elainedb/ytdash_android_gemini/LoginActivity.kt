package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.ComponentActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper

class LoginActivity : ComponentActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var errorTextView: TextView

    private val signInLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            val email = account?.email
            if (email != null) {
                checkAuthorization(email)
            } else {
                showError("Could not retrieve email from Google Sign-In.")
            }
        } catch (e: ApiException) {
            Log.w("LoginActivity", "signInResult:failed code=" + e.statusCode)
            showError("Sign-in failed.")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        errorTextView = findViewById(R.id.errorTextView)
        val signInButton = findViewById<Button>(R.id.signInButton)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        signInButton.setOnClickListener {
            val signInIntent = googleSignInClient.signInIntent
            signInLauncher.launch(signInIntent)
        }
    }

    private fun checkAuthorization(email: String) {
        val authorizedEmails = ConfigHelper.getAuthorizedEmails(this)
        if (authorizedEmails.contains(email)) {
            Log.d("LoginActivity", "Access granted to $email")
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            startActivity(intent)
        } else {
            showError("Access denied. Your email is not authorized.")
            googleSignInClient.signOut()
        }
    }

    private fun showError(message: String) {
        errorTextView.text = message
    }
}