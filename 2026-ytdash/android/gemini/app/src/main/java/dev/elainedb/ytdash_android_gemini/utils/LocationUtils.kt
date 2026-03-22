package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

object LocationUtils {

    suspend fun getCityAndCountry(
        context: Context,
        latitude: Double?,
        longitude: Double?
    ): Pair<String?, String?> = withContext(Dispatchers.IO) {
        if (latitude == null || longitude == null) {
            return@withContext Pair(null, null)
        }

        if (!Geocoder.isPresent()) {
            return@withContext Pair(null, null)
        }

        val geocoder = Geocoder(context, Locale.getDefault())

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                suspendCoroutine { continuation ->
                    geocoder.getFromLocation(latitude, longitude, 1, object : Geocoder.GeocodeListener {
                        override fun onGeocode(addresses: List<Address>) {
                            continuation.resume(extractCityAndCountry(addresses.firstOrNull()))
                        }

                        override fun onError(errorMessage: String?) {
                            continuation.resume(Pair(null, null))
                        }
                    })
                }
            } else {
                @Suppress("DEPRECATION")
                val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                extractCityAndCountry(addresses?.firstOrNull())
            }
        } catch (e: Exception) {
            Pair(null, null)
        }
    }

    private fun extractCityAndCountry(address: Address?): Pair<String?, String?> {
        if (address == null) return Pair(null, null)

        val city = address.locality
            ?: address.subAdminArea
            ?: address.adminArea
            ?: address.subLocality
            ?: address.thoroughfare
        
        val country = address.countryName

        return Pair(city, country)
    }
}
