package dev.elainedb.android_gemini.data

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import dev.elainedb.android_gemini.R
import dev.elainedb.android_gemini.domain.AuthorizedEmailsRepository
import java.util.Properties
import javax.inject.Inject

class AuthorizedEmailsRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context
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
