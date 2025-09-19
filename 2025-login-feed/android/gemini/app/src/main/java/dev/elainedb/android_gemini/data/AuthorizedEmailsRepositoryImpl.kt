package dev.elainedb.android_gemini.data

import android.content.Context
import dev.elainedb.android_gemini.R
import dev.elainedb.android_gemini.domain.AuthorizedEmailsRepository
import java.util.Properties

class AuthorizedEmailsRepositoryImpl(
    private val context: Context
) : AuthorizedEmailsRepository {

    private val authorizedEmails by lazy {
        val properties = Properties()
        val rawResource = context.resources.openRawResource(R.raw.config)
        properties.load(rawResource)
        properties.getProperty("authorized_emails").split(",")
    }

    override suspend fun isEmailAuthorized(email: String): Boolean {
        return authorizedEmails.contains(email)
    }
}
