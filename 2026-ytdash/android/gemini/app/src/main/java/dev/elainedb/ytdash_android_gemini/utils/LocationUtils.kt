package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.roundToInt

object LocationUtils {
    // Cache map: Key is Pair(lat, lng) rounded, Value is Pair(City?, Country?)
    private val locationCache = ConcurrentHashMap<Pair<Double, Double>, Pair<String?, String?>>()
    private val semaphore = Semaphore(5)

    suspend fun getCityCountry(
        context: Context,
        lat: Double,
        lng: Double,
        description: String?
    ): Pair<String?, String?> = withContext(Dispatchers.IO) {
        val roundedLat = (lat * 1000.0).roundToInt() / 1000.0
        val roundedLng = (lng * 1000.0).roundToInt() / 1000.0
        val cacheKey = Pair(roundedLat, roundedLng)

        locationCache[cacheKey]?.let { return@withContext it }

        semaphore.withPermit {
            var result: Pair<String?, String?> = Pair(null, null)
            val geocoder = Geocoder(context)

            if (Geocoder.isPresent()) {
                var retryCount = 0
                val maxRetries = 3
                var delayMs = 500L

                while (retryCount < maxRetries && result.first == null && result.second == null) {
                    try {
                        val addresses = getFromLocationCompat(geocoder, lat, lng)
                        if (addresses.isNotEmpty()) {
                            val address = addresses[0]
                            val city = address.locality ?: address.subAdminArea ?: address.adminArea ?: address.subLocality ?: address.thoroughfare
                            val country = address.countryName
                            if (city != null || country != null) {
                                result = Pair(city, country)
                                break
                            }
                        }
                    } catch (e: Exception) {
                        retryCount++
                        if (retryCount < maxRetries) {
                            delay(delayMs)
                            delayMs *= 2
                        }
                    }
                }
            }

            if (result.first == null && result.second == null) {
                // Fallback to Nominatim
                try {
                    delay(1000) // Nominatim policy
                    val url = URL("https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng")
                    val connection = url.openConnection() as HttpURLConnection
                    connection.setRequestProperty("User-Agent", "dev.elainedb.ytdash_android_gemini/1.0")
                    connection.connectTimeout = 5000
                    connection.readTimeout = 5000
                    if (connection.responseCode == 200) {
                        val response = connection.inputStream.bufferedReader().readText()
                        val json = Json.parseToJsonElement(response).jsonObject
                        val addressJson = json["address"]?.jsonObject
                        val city = addressJson?.get("city")?.jsonPrimitive?.content
                            ?: addressJson?.get("town")?.jsonPrimitive?.content
                            ?: addressJson?.get("village")?.jsonPrimitive?.content
                        val country = addressJson?.get("country")?.jsonPrimitive?.content
                        if (city != null || country != null) {
                            result = Pair(city, country)
                        }
                    }
                    connection.disconnect()
                } catch (e: Exception) {
                    // Ignore
                }
            }

            if (result.first == null && result.second == null && description != null) {
                // Regex fallback
                val regex = Regex("""([A-Z][a-z]+(?: [A-Z][a-z]+)*),\s*([A-Z][a-z]+(?: [A-Z][a-z]+)*)""")
                val match = regex.find(description)
                if (match != null) {
                    result = Pair(match.groupValues[1], match.groupValues[2])
                }
            }

            locationCache[cacheKey] = result
            return@withContext result
        }
    }

    private suspend fun getFromLocationCompat(geocoder: Geocoder, lat: Double, lng: Double): List<Address> = withContext(Dispatchers.IO) {
        return@withContext if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            kotlin.coroutines.suspendCoroutine { cont ->
                geocoder.getFromLocation(lat, lng, 1) { addresses ->
                    cont.resumeWith(Result.success(addresses))
                }
            }
        } else {
            @Suppress("DEPRECATION")
            geocoder.getFromLocation(lat, lng, 1) ?: emptyList()
        }
    }
}
