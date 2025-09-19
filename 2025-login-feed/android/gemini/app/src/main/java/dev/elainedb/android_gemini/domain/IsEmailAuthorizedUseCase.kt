package dev.elainedb.android_gemini.domain


class IsEmailAuthorizedUseCase(
    private val repository: AuthorizedEmailsRepository
) {
    suspend operator fun invoke(email: String): Boolean {
        return repository.isEmailAuthorized(email)
    }
}
