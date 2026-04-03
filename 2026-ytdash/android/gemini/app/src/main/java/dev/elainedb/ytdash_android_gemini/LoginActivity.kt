package dev.elainedb.ytdash_android_gemini

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.ComponentActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper

class LoginActivity : ComponentActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var errorText: TextView

    private val signInLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
            handleSignInResult(task)
        } else {
            errorText.text = "Sign in cancelled or failed."
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        errorText = findViewById(R.id.errorText)
        val signInButton = findViewById<Button>(R.id.signInButton)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        signInButton.setOnClickListener {
            val signInIntent = googleSignInClient.signInIntent
            signInLauncher.launch(signInIntent)
        }

        // Check for existing signed-in user
        val account = GoogleSignIn.getLastSignedInAccount(this)
        if (account != null) {
            checkAuthorization(account.email)
        }
    }

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val account = completedTask.getResult(ApiException::class.java)
            checkAuthorization(account?.email)
        } catch (e: ApiException) {
            Log.w("LoginActivity", "signInResult:failed code=" + e.statusCode)
            errorText.text = "Sign in failed: ${e.statusCode}"
        }
    }

    private fun checkAuthorization(email: String?) {
        if (email == null) {
            errorText.text = "Could not get email from Google account."
            googleSignInClient.signOut()
            return
        }

        val authorizedEmails = ConfigHelper.getAuthorizedEmails(this)
        if (authorizedEmails.contains(email)) {
            Log.i("LoginActivity", "Access granted to $email")
            val intent = Intent(this, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
        } else {
            errorText.text = "Access denied. Your email is not authorized."
            googleSignInClient.signOut()
        }
    }
}
