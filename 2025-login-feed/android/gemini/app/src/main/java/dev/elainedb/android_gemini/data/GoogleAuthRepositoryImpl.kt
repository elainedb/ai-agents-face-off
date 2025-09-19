package dev.elainedb.android_gemini.data

import android.content.Context
import com.google.android.gms.auth.api.identity.Identity
import dev.elainedb.android_gemini.domain.GoogleAuthRepository
import kotlinx.coroutines.tasks.await

class GoogleAuthRepositoryImpl constructor(
    private val context: Context
) : GoogleAuthRepository {

    private val googleSignInClient by lazy {
        Identity.getSignInClient(context)
    }

    override suspend fun signOut() {
        googleSignInClient.signOut().await()
    }
}
