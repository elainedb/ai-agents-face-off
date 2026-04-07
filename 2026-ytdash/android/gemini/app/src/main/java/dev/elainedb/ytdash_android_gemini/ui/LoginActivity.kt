package dev.elainedb.ytdash_android_gemini.ui

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.MainActivity
import dev.elainedb.ytdash_android_gemini.R
import dev.elainedb.ytdash_android_gemini.domain.usecase.SignInWithGoogle
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject

@AndroidEntryPoint
class LoginActivity : AppCompatActivity() {

    @Inject
    lateinit var configHelper: ConfigHelper

    @Inject
    lateinit var signInWithGoogle: SignInWithGoogle

    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var tvError: TextView

    private val signInLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        handleSignInResult(task)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        tvError = findViewById(R.id.tvError)
        val btnSignIn = findViewById<Button>(R.id.btnSignIn)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        btnSignIn.setOnClickListener {
            tvError.text = ""
            signInLauncher.launch(googleSignInClient.signInIntent)
        }
        
        // Auto-login check
        val account = GoogleSignIn.getLastSignedInAccount(this)
        if (account != null) {
            handleSignInResult(com.google.android.gms.tasks.Tasks.forResult(account))
        }
    }

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val account = completedTask.getResult(ApiException::class.java)
            val email = account?.email ?: return
            
            CoroutineScope(Dispatchers.Main).launch {
                val result = withContext(Dispatchers.IO) {
                    signInWithGoogle(SignInWithGoogle.Params(email, account.displayName))
                }
                if (result is Result.Success) {
                    Log.d("LoginActivity", "Access granted to $email")
                    navigateToMain()
                } else if (result is Result.Error) {
                    tvError.text = result.failure.message
                    googleSignInClient.signOut()
                }
            }
        } catch (e: ApiException) {
            tvError.text = "Google sign in failed."
        }
    }

    private fun navigateToMain() {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        startActivity(intent)
        finish()
    }
}
