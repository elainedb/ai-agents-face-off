package dev.elainedb.ytdash_android_gemini.domain.usecase

import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import javax.inject.Inject

class SignInWithGoogle @Inject constructor() : UseCase<String, String>() {
    override suspend fun invoke(params: String): Result<String> {
        val email = params
        return if (ConfigHelper.authorizedEmails.contains(email)) {
            Result.Success(email)
        } else {
            Result.Error(Failure.Auth("Access denied. Your email is not authorized."))
        }
    }
}

class GetVideos @Inject constructor(
    private val repository: dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
) : UseCase<Unit, GetVideosParams>() {
    override suspend fun invoke(params: GetVideosParams): Result<Unit> {
        return repository.fetchAndCacheVideos(params.channelIds, params.forceRefresh)
    }
}

data class GetVideosParams(val channelIds: List<String>, val forceRefresh: Boolean)
