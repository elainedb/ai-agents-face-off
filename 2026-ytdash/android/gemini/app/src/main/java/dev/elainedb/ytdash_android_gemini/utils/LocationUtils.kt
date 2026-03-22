package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.Locale
import kotlin.coroutines.resume

object LocationUtils {

    suspend fun getCityAndCountry(
        context: Context,
        latitude: Double,
        longitude: Double
    ): Pair<String?, String?> {
        if (!Geocoder.isPresent()) return Pair(null, null)
        val geocoder = Geocoder(context, Locale.getDefault())

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                suspendCancellableCoroutine { continuation ->
                    geocoder.getFromLocation(latitude, longitude, 1, object : Geocoder.GeocodeListener {
                        override fun onGeocode(addresses: MutableList<Address>) {
                            continuation.resume(extractLocationInfo(addresses.firstOrNull()))
                        }

                        override fun onError(errorMessage: String?) {
                            continuation.resume(Pair(null, null))
                        }
                    })
                }
            } else {
                @Suppress("DEPRECATION")
                val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                extractLocationInfo(addresses?.firstOrNull())
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Pair(null, null)
        }
    }

    private fun extractLocationInfo(address: Address?): Pair<String?, String?> {
        if (address == null) return Pair(null, null)
        val city = address.locality ?: address.subAdminArea ?: address.adminArea ?: address.subLocality ?: address.thoroughfare
        val country = address.countryName
        return Pair(city, country)
    }
}
