package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper

class LoginActivity : ComponentActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var tvError: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ConfigHelper.init(this)
        setContentView(R.layout.activity_login)

        tvError = findViewById(R.id.tvError)
        val btnSignIn: Button = findViewById(R.id.btnSignIn)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        val signInLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
            try {
                val account = task.getResult(ApiException::class.java)
                handleSignInResult(account)
            } catch (e: ApiException) {
                Log.w("LoginActivity", "signInResult:failed code=" + e.statusCode)
                tvError.text = "Sign in failed."
            }
        }

        btnSignIn.setOnClickListener {
            tvError.text = ""
            signInLauncher.launch(googleSignInClient.signInIntent)
        }
        
        // Auto-login if already signed in and authorized
        val account = GoogleSignIn.getLastSignedInAccount(this)
        if (account != null) {
            handleSignInResult(account)
        }
    }

    private fun handleSignInResult(account: GoogleSignInAccount) {
        val email = account.email ?: ""
        if (ConfigHelper.authorizedEmails.contains(email)) {
            Log.d("LoginActivity", "Access granted to $email")
            val intent = Intent(this, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
        } else {
            tvError.text = "Access denied. Your email is not authorized."
            googleSignInClient.signOut()
        }
    }
}
