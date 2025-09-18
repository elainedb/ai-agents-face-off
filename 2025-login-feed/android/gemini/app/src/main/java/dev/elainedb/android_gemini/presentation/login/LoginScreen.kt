package dev.elainedb.android_gemini.presentation.login

import android.app.Activity.RESULT_OK
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.android.gms.auth.api.identity.Identity
import dev.elainedb.android_gemini.R

@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    val googleSignInClient = Identity.getSignInClient(context)

    val launcher = rememberLauncherForActivityResult(contract = ActivityResultContracts.StartIntentSenderForResult()) { result ->
        if (result.resultCode == RESULT_OK) {
            try {
                val credential = googleSignInClient.getSignInCredentialFromIntent(result.data)
                val email = credential.id
                viewModel.onSignInSuccess(email)
            } catch (e: Exception) {
                viewModel.onSignInError()
            }
        } else {
            viewModel.onSignInError()
        }
    }

    LaunchedEffect(uiState) {
        Log.d("LoginScreen", "uiState changed: $uiState")
        if (uiState is LoginUiState.Success) {
            onLoginSuccess()
        }
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Login with Google")
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = {
            val request = com.google.android.gms.auth.api.identity.BeginSignInRequest.builder()
                .setGoogleIdTokenRequestOptions(
                    com.google.android.gms.auth.api.identity.BeginSignInRequest.GoogleIdTokenRequestOptions.builder()
                        .setSupported(true)
                        .setServerClientId(context.getString(R.string.default_web_client_id))
                        .setFilterByAuthorizedAccounts(false)
                        .build()
                )
                .build()

            googleSignInClient.beginSignIn(request)
                .addOnSuccessListener { result ->
                    launcher.launch(IntentSenderRequest.Builder(result.pendingIntent.intentSender).build())
                }
                .addOnFailureListener { e ->
                    viewModel.onSignInError()
                }
        }) {
            Text("Sign in with Google")
        }
        (uiState as? LoginUiState.Error)?.let {
            Text(it.message)
        }
    }
}