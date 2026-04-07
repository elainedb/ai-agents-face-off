package dev.elainedb.ytdash_android_gemini.domain.usecase

import android.content.Context
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import dagger.hilt.android.qualifiers.ApplicationContext
import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class SignOut @Inject constructor(
    @ApplicationContext private val context: Context
) : UseCase<Unit, Unit>() {
    override suspend fun invoke(params: Unit): Result<Unit> {
        return try {
            val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                .build()
            val client = GoogleSignIn.getClient(context, gso)
            client.signOut().await()
            Result.Success(Unit)
        } catch (e: Exception) {
            Result.Error(Failure.Unexpected(e.message ?: "Sign out failed"))
        }
    }
}
