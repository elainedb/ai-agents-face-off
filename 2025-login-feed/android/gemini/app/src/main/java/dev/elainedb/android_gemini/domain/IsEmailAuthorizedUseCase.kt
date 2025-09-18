package dev.elainedb.android_gemini.domain

import javax.inject.Inject

class IsEmailAuthorizedUseCase @Inject constructor(
    private val repository: AuthorizedEmailsRepository
) {
    suspend operator fun invoke(email: String): Boolean {
        return repository.isEmailAuthorized(email)
    }
}
