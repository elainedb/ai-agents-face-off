package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale

object LocationUtils {

    suspend fun getCityAndCountry(context: Context, latitude: Double, longitude: Double): Pair<String?, String?> {
        return withContext(Dispatchers.IO) {
            try {
                val geocoder = Geocoder(context, Locale.getDefault())
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    // Modern async API wrapper
                    suspendCoroutineWithTimeout<Pair<String?, String?>>(5000L) { continuation ->
                        geocoder.getFromLocation(latitude, longitude, 1) { addresses ->
                            continuation.resumeWith(Result.success(extractLocation(addresses)))
                        }
                    }
                } else {
                    // Legacy sync API
                    @Suppress("DEPRECATION")
                    val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                    extractLocation(addresses)
                }
            } catch (e: Exception) {
                Pair(null, null)
            }
        }
    }

    private fun extractLocation(addresses: List<Address>?): Pair<String?, String?> {
        if (addresses.isNullOrEmpty()) return Pair(null, null)
        val address = addresses[0]
        
        val city = address.locality 
            ?: address.subAdminArea 
            ?: address.adminArea 
            ?: address.subLocality 
            ?: address.thoroughfare
            
        val country = address.countryName
        
        return Pair(city, country)
    }
}

suspend inline fun <T> suspendCoroutineWithTimeout(
    timeoutMillis: Long,
    crossinline block: (kotlin.coroutines.Continuation<T>) -> Unit
): T = kotlinx.coroutines.withTimeout(timeoutMillis) {
    kotlin.coroutines.suspendCoroutine(block)
}
