package dev.elainedb.ytdash_android_gemini.core.usecases

import dev.elainedb.ytdash_android_gemini.core.error.Result

abstract class UseCase<out T, in P> {
    abstract suspend operator fun invoke(params: P): Result<T>
}