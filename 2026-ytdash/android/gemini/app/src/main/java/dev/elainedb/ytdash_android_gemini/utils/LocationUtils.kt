package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONArray
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.delay
import kotlin.coroutines.suspendCoroutine
import kotlin.coroutines.resume

object LocationUtils {

    private val cache = ConcurrentHashMap<Pair<Double, Double>, Pair<String?, String?>>()
    private val semaphore = Semaphore(5)
    private val httpClient = OkHttpClient()

    private fun roundCoordinates(lat: Double, lon: Double): Pair<Double, Double> {
        return Pair(Math.round(lat * 1000.0) / 1000.0, Math.round(lon * 1000.0) / 1000.0)
    }

    suspend fun reverseGeocode(context: Context, latitude: Double, longitude: Double, description: String?): Pair<String?, String?> = withContext(Dispatchers.IO) {
        val rounded = roundCoordinates(latitude, longitude)
        cache[rounded]?.let { return@withContext it }

        semaphore.withPermit {
            var attempt = 0
            val maxRetries = 3
            var result: Pair<String?, String?> = Pair(null, null)

            while (attempt < maxRetries) {
                try {
                    val geocoder = Geocoder(context, Locale.getDefault())
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val addresses = suspendCoroutine<List<Address>> { cont ->
                            geocoder.getFromLocation(latitude, longitude, 1) { addresses ->
                                cont.resume(addresses)
                            }
                        }
                        result = extractAddress(addresses.firstOrNull())
                    } else {
                        @Suppress("DEPRECATION")
                        val addresses = geocoder.getFromLocation(latitude, longitude, 1)
                        result = extractAddress(addresses?.firstOrNull())
                    }
                    if (result.first != null || result.second != null) {
                        cache[rounded] = result
                        return@withContext result
                    }
                } catch (e: Exception) {
                    attempt++
                    if (attempt < maxRetries) {
                        delay(500L * attempt)
                    }
                }
            }

            // Fallback to Nominatim
            try {
                val url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude"
                val request = Request.Builder()
                    .url(url)
                    .header("User-Agent", "dev.elainedb.ytdash_android_gemini/1.0")
                    .build()
                
                val response = httpClient.newCall(request).execute()
                if (response.isSuccessful) {
                    val json = org.json.JSONObject(response.body?.string() ?: "{}")
                    val addressObj = json.optJSONObject("address")
                    if (addressObj != null) {
                        val city = addressObj.optString("city", addressObj.optString("town", addressObj.optString("village", null)))
                        val country = addressObj.optString("country", null)
                        result = Pair(city.takeIf { it.isNotEmpty() }, country.takeIf { it.isNotEmpty() })
                    }
                }
                delay(1000) // Nominatim policy
            } catch (e: Exception) {
                // Ignore
            }

            // Fallback to description regex
            if (result.first == null && result.second == null && description != null) {
                val regex = Regex("(?i)Location:\\s*([A-Za-z ]+),\\s*([A-Za-z ]+)")
                val match = regex.find(description)
                if (match != null) {
                    result = Pair(match.groupValues[1].trim(), match.groupValues[2].trim())
                }
            }

            cache[rounded] = result
            result
        }
    }

    private fun extractAddress(address: Address?): Pair<String?, String?> {
        if (address == null) return Pair(null, null)
        val city = address.locality ?: address.subAdminArea ?: address.adminArea ?: address.subLocality ?: address.thoroughfare
        return Pair(city, address.countryName)
    }
}