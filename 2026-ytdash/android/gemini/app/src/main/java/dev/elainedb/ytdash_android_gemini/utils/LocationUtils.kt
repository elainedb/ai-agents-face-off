package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import android.util.Log
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

object LocationUtils {

    suspend fun reverseGeocode(context: Context, latitude: Double, longitude: Double): Pair<String?, String?> {
        val geocoder = Geocoder(context, Locale.getDefault())
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            suspendCoroutine { continuation ->
                geocoder.getFromLocation(latitude, longitude, 1, object : Geocoder.GeocodeListener {
                    override fun onGeocode(addresses: MutableList<Address>) {
                        val address = addresses.firstOrNull()
                        continuation.resume(resolveAddress(address))
                    }
                    override fun onError(errorMessage: String?) {
                        Log.e("LocationUtils", "Geocoder error: $errorMessage")
                        continuation.resume(Pair(null, null))
                    }
                })
            }
        } else {
            try {
                @Suppress("DEPRECATION")
                val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                resolveAddress(addresses?.firstOrNull())
            } catch (e: Exception) {
                Log.e("LocationUtils", "Geocoder error", e)
                Pair(null, null)
            }
        }
    }

    private fun resolveAddress(address: Address?): Pair<String?, String?> {
        if (address == null) return Pair(null, null)
        val city = address.locality ?: address.subAdminArea ?: address.adminArea ?: address.subLocality ?: address.thoroughfare
        val country = address.countryName
        return Pair(city, country)
    }
}
