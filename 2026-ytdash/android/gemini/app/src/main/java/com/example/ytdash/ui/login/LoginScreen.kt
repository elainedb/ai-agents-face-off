package com.example.ytdash.ui.login

import android.app.Activity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ytdash.LocalTestConfig
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException

@Composable
fun LoginScreen(
    onNavigateToHome: () -> Unit,
    viewModel: LoginViewModel = viewModel(factory = LoginViewModelFactory(LocalTestConfig.current))
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    val testConfig = LocalTestConfig.current

    LaunchedEffect(uiState) {
        if (uiState is LoginUiState.Success) {
            onNavigateToHome()
        }
    }

    val signInLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
            try {
                val account = task.getResult(ApiException::class.java)
                account.email?.let { email ->
                    viewModel.onSignIn(email)
                } ?: run {
                    viewModel.onSignIn("") // no email
                }
            } catch (e: ApiException) {
                // handle error
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .testTag("screen_login")
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (uiState is LoginUiState.Loading) {
            CircularProgressIndicator(modifier = Modifier.testTag("loading_indicator"))
        } else {
            Button(
                onClick = {
                    if (testConfig.uiTestMode && testConfig.mockAuthEmail != null) {
                        viewModel.onSignIn(testConfig.mockAuthEmail!!)
                    } else {
                        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                            .requestEmail()
                            .build()
                        val mGoogleSignInClient = GoogleSignIn.getClient(context, gso)
                        signInLauncher.launch(mGoogleSignInClient.signInIntent)
                    }
                },
                modifier = Modifier.testTag("login_google_button")
            ) {
                Text("Sign in with Google")
            }

            if (uiState is LoginUiState.Error) {
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = (uiState as LoginUiState.Error).message,
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.testTag("login_error_message")
                )
            }
        }
    }
}
