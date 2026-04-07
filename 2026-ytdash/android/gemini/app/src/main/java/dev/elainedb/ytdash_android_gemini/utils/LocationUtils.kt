package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import android.util.Log
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ConcurrentHashMap
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LocationUtils @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val geocoder = Geocoder(context)
    private val cache = ConcurrentHashMap<Pair<Double, Double>, Pair<String?, String?>>()
    private val semaphore = Semaphore(5)

    suspend fun getCityAndCountry(latitude: Double, longitude: Double, snippetLocationDescription: String? = null): Pair<String?, String?> {
        val latRounded = Math.round(latitude * 1000.0) / 1000.0
        val lonRounded = Math.round(longitude * 1000.0) / 1000.0
        val cacheKey = Pair(latRounded, lonRounded)

        cache[cacheKey]?.let { return it }

        return semaphore.withPermit {
            var retries = 0
            var result: Pair<String?, String?> = Pair(null, null)
            val delays = listOf(500L, 1000L, 2000L)

            while (retries < 3) {
                try {
                    result = getFromGeocoder(latitude, longitude)
                    if (result.first != null || result.second != null) {
                        cache[cacheKey] = result
                        return@withPermit result
                    }
                    break
                } catch (e: Exception) {
                    if (retries < delays.size) {
                        delay(delays[retries])
                    }
                    retries++
                }
            }

            // Fallback to Nominatim
            try {
                result = getFromNominatim(latitude, longitude)
                if (result.first != null || result.second != null) {
                    cache[cacheKey] = result
                    return@withPermit result
                }
            } catch (e: Exception) {
                Log.e("LocationUtils", "Nominatim fallback failed", e)
            }

            // Fallback to regex on snippet
            if (snippetLocationDescription != null) {
                result = parseLocationFromSnippet(snippetLocationDescription)
                if (result.first != null || result.second != null) {
                    cache[cacheKey] = result
                    return@withPermit result
                }
            }

            cache[cacheKey] = result
            result
        }
    }

    private suspend fun getFromGeocoder(latitude: Double, longitude: Double): Pair<String?, String?> = withContext(Dispatchers.IO) {
        if (!Geocoder.isPresent()) return@withContext Pair(null, null)
        
        var address: Address? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val latch = java.util.concurrent.CountDownLatch(1)
            geocoder.getFromLocation(latitude, longitude, 1, object : Geocoder.GeocodeListener {
                override fun onGeocode(addresses: MutableList<Address>) {
                    address = addresses.firstOrNull()
                    latch.countDown()
                }
                override fun onError(errorMessage: String?) {
                    latch.countDown()
                }
            })
            latch.await(5, java.util.concurrent.TimeUnit.SECONDS)
        } else {
            @Suppress("DEPRECATION")
            address = geocoder.getFromLocation(latitude, longitude, 1)?.firstOrNull()
        }

        address?.let {
            val city = it.locality ?: it.subAdminArea ?: it.adminArea ?: it.subLocality ?: it.thoroughfare
            val country = it.countryName
            Pair(city, country)
        } ?: Pair(null, null)
    }

    private suspend fun getFromNominatim(latitude: Double, longitude: Double): Pair<String?, String?> = withContext(Dispatchers.IO) {
        delay(1000) // Minimum 1 second delay policy
        val url = URL("https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude")
        val connection = url.openConnection() as HttpURLConnection
        connection.setRequestProperty("User-Agent", "dev.elainedb.ytdash_android_gemini/1.0")
        connection.connectTimeout = 5000
        connection.readTimeout = 5000

        try {
            if (connection.responseCode == 200) {
                val response = connection.inputStream.bufferedReader().use { it.readText() }
                val json = JSONObject(response)
                val address = json.optJSONObject("address")
                if (address != null) {
                    val city = address.optString("city", null) ?: 
                               address.optString("town", null) ?: 
                               address.optString("village", null) ?: 
                               address.optString("county", null)
                    val country = address.optString("country", null)
                    return@withContext Pair(city, country)
                }
            }
            Pair(null, null)
        } finally {
            connection.disconnect()
        }
    }

    private fun parseLocationFromSnippet(description: String): Pair<String?, String?> {
        val regex = Regex("([^,]+),\\s*([^\\n]+)")
        val match = regex.find(description)
        return if (match != null) {
            Pair(match.groupValues[1].trim(), match.groupValues[2].trim())
        } else {
            Pair(null, null)
        }
    }
}
