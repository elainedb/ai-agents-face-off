package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.Locale
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

object LocationUtils {
    private const val TAG = "LocationUtils"

    suspend fun getCityAndCountry(context: Context, latitude: Double, longitude: Double): Pair<String?, String?> {
        return withContext(Dispatchers.IO) {
            if (!Geocoder.isPresent()) {
                return@withContext Pair(null, null)
            }

            val geocoder = Geocoder(context, Locale.getDefault())
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    suspendCoroutine { continuation ->
                        geocoder.getFromLocation(latitude, longitude, 1, object : Geocoder.GeocodeListener {
                            override fun onGeocode(addresses: MutableList<Address>) {
                                continuation.resume(extractLocationData(addresses))
                            }

                            override fun onError(errorMessage: String?) {
                                Log.e(TAG, "Geocoder error: $errorMessage")
                                continuation.resume(Pair(null, null))
                            }
                        })
                    }
                } else {
                    @Suppress("DEPRECATION")
                    val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                    extractLocationData(addresses)
                }
            } catch (e: IOException) {
                Log.e(TAG, "Geocoder exception", e)
                Pair(null, null)
            }
        }
    }

    private fun extractLocationData(addresses: List<Address>?): Pair<String?, String?> {
        if (addresses.isNullOrEmpty()) return Pair(null, null)
        val address = addresses[0]
        val country = address.countryName
        val city = address.locality ?: address.subAdminArea ?: address.adminArea ?: address.subLocality ?: address.thoroughfare
        return Pair(city, country)
    }
}
