package dev.elainedb.ytdash_android_gemini.usecases

import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import javax.inject.Inject

class SignInWithGoogle @Inject constructor() : UseCase<String, String>() {
    override suspend fun invoke(params: String): Result<String> {
        // Validation logic is handled in LoginActivity via the Google SignIn intent and config helper.
        // This is a placeholder since the actual SignIn API relies heavily on Activity result callbacks.
        return Result.Success(params)
    }
}

class SignOut @Inject constructor() : UseCase<Unit, Unit>() {
    override suspend fun invoke(params: Unit): Result<Unit> {
        // This relies on GoogleSignInClient, which is tied to Context/Activity.
        // We will do sign out logic mostly in the View/Activity layer as requested for V1.
        return Result.Success(Unit)
    }
}