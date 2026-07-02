package com.example.ytdash.ui.auth

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ytdash.TestConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    onLoginSuccess: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var emailInput by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Pre-populate input in test mode if mockAuthEmail is specified, otherwise default to first whitelist email
    LaunchedEffect(Unit) {
        if (TestConfig.uiTestMode && !TestConfig.mockAuthEmail.isNullOrEmpty()) {
            emailInput = TestConfig.mockAuthEmail!!
            Log.d("LoginScreen", "Pre-populated mockAuthEmail: $emailInput")
        } else if (!TestConfig.authorizedEmails.isEmpty()) {
            emailInput = TestConfig.authorizedEmails.first()
        }
    }

    val handleLogin = {
        val email = emailInput.trim()
        Log.d("LoginScreen", "Tapped login with email: '$email'")

        if (email.isEmpty()) {
            errorMessage = "Email cannot be empty"
        } else {
            // Check whitelist
            val whitelist = TestConfig.authorizedEmails
            val isWhitelisted = whitelist.any { it.equals(email, ignoreCase = true) }

            if (isWhitelisted) {
                Log.d("LoginScreen", "Email is whitelisted! Navigating to Home.")
                errorMessage = null
                onLoginSuccess(email)
            } else {
                Log.w("LoginScreen", "Access DENIED for email: '$email'. Whitelist: $whitelist")
                errorMessage = "Email '$email' is not on the whitelist of authorized users."
            }
        }
    }

    // Modern, Premium visual palette (sleek deep space / dark mode gradient)
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF0F172A), // Slate 900
                        Color(0xFF1E293B)  // Slate 800
                    )
                )
            )
            .testTag("screen_login")
            .semantics { testTagsAsResourceId = true },
        contentAlignment = Alignment.Center
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.85f)
                .padding(16.dp),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B).copy(alpha = 0.95f)),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = java.util.Objects.requireNonNull(Arrangement.spacedBy(24.dp))
            ) {
                // Header / App Logo
                Text(
                    text = "ytDASH",
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    letterSpacing = 2.sp
                )

                Text(
                    text = "Sign in to aggregate your video analytics dashboards",
                    fontSize = 14.sp,
                    color = Color.LightGray,
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Email input field for simulation/real-mode ease of use
                OutlinedTextField(
                    value = emailInput,
                    onValueChange = {
                        emailInput = it
                        errorMessage = null // Clear error on change
                    },
                    label = { Text("Google Account Email", color = Color.LightGray) },
                    placeholder = { Text("email@example.com") },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedBorderColor = MaterialTheme.colorScheme.primary,
                        unfocusedBorderColor = Color.Gray,
                        cursorColor = MaterialTheme.colorScheme.primary
                    ),
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Email,
                            contentDescription = "Email Icon",
                            tint = Color.LightGray
                        )
                    },
                    modifier = Modifier.fillMaxWidth()
                )

                // Error Message block - MANDATORY "login_error_message" ID
                if (errorMessage != null) {
                    Text(
                        text = errorMessage!!,
                        color = MaterialTheme.colorScheme.error,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("login_error_message")
                    )
                }

                // Sign-In Button - MANDATORY "login_google_button" ID
                Button(
                    onClick = handleLogin,
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFEA4335), // Google Red
                        contentColor = Color.White
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .testTag("login_google_button"),
                    elevation = ButtonDefaults.buttonElevation(defaultElevation = 2.dp)
                ) {
                    Text(
                        text = "Sign in with Google",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}
