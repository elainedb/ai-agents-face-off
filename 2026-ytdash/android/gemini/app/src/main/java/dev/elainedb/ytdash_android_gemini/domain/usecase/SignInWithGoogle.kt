package dev.elainedb.ytdash_android_gemini.domain.usecase

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import dev.elainedb.ytdash_android_gemini.domain.model.User
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import javax.inject.Inject

class SignInWithGoogle @Inject constructor(
    @ApplicationContext private val context: Context,
    private val configHelper: ConfigHelper
) : UseCase<User, SignInWithGoogle.Params>() {

    data class Params(val email: String, val displayName: String?)

    override suspend fun invoke(params: Params): Result<User> {
        val authorizedEmails = configHelper.getAuthorizedEmails(context)
        return if (authorizedEmails.contains(params.email)) {
            Result.Success(User(email = params.email, displayName = params.displayName))
        } else {
            Result.Error(Failure.Auth("Access denied. Your email is not authorized."))
        }
    }
}
