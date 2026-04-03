package dev.elainedb.ytdash_android_gemini.network

import retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import java.util.concurrent.TimeUnit

object RetrofitClient {
    private const val BASE_URL = "https://www.googleapis.com/youtube/v3/"

    // Add X-Android-Package and X-Android-Cert interceptor if needed
    // The spec says: OkHttp client adds X-Android-Package and X-Android-Cert headers for API key restrictions.
    private val client = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BODY })
        // Note: For a real app, you might need to compute the SHA1 cert dynamically or inject it.
        // For this demo, assuming it runs, we could add a simple interceptor.
        .addInterceptor { chain ->
            val request = chain.request().newBuilder()
                // .addHeader("X-Android-Package", "dev.elainedb.ytdash_android_gemini")
                // .addHeader("X-Android-Cert", "YOUR_CERT_SHA1")
                .build()
            chain.proceed(request)
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    private val json = Json { ignoreUnknownKeys = true; coerceInputValues = true }

    val apiService: YouTubeApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
            .create(YouTubeApiService::class.java)
    }
}
