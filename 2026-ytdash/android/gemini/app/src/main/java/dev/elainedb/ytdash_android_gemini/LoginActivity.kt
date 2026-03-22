package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException

class LoginActivity : ComponentActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var errorMessage: TextView
    private lateinit var signInButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        ConfigHelper.init(this)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        errorMessage = findViewById(R.id.errorMessage)
        signInButton = findViewById(R.id.signInButton)

        signInButton.setOnClickListener {
            errorMessage.text = ""
            val signInIntent = googleSignInClient.signInIntent
            startActivityForResult(signInIntent, RC_SIGN_IN)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            try {
                val account = task.getResult(ApiException::class.java)
                val email = account?.email
                if (email != null) {
                    val authorizedEmails = ConfigHelper.getAuthorizedEmails()
                    if (authorizedEmails.contains(email)) {
                        Log.d("LoginActivity", "Access granted to \$email")
                        val intent = Intent(this, MainActivity::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                        startActivity(intent)
                    } else {
                        errorMessage.text = "Access denied. Your email is not authorized."
                        googleSignInClient.signOut()
                    }
                } else {
                    errorMessage.text = "Failed to retrieve email."
                    googleSignInClient.signOut()
                }
            } catch (e: ApiException) {
                Log.w("LoginActivity", "signInResult:failed code=" + e.statusCode)
                errorMessage.text = "Google Sign-In failed."
            }
        }
    }

    override fun onStart() {
        super.onStart()
        val account = GoogleSignIn.getLastSignedInAccount(this)
        if (account != null) {
            val email = account.email
            val authorizedEmails = ConfigHelper.getAuthorizedEmails()
            if (email != null && authorizedEmails.contains(email)) {
                Log.d("LoginActivity", "Access granted to \$email (auto-login)")
                val intent = Intent(this, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                startActivity(intent)
            } else {
                googleSignInClient.signOut()
            }
        }
    }

    companion object {
        private const val RC_SIGN_IN = 9001
    }
}