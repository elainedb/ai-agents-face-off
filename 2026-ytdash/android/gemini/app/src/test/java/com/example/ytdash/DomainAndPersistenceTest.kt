package com.example.ytdash

import android.content.Context
import android.content.SharedPreferences
import com.example.ytdash.data.model.TestConfig
import com.example.ytdash.data.model.Video
import com.example.ytdash.data.repository.AuthRepository
import com.example.ytdash.data.repository.VideoRepository
import com.example.ytdash.data.network.YouTubeApiService
import org.junit.Assert.*
import org.junit.Test
import org.mockito.Mockito

class DomainAndPersistenceTest {

    @Test
    fun testAuthRepositoryWhitelist_DefaultAndCustom() {
        val mockContext = Mockito.mock(Context::class.java)

        // 1. Default whitelist (no UI test mode)
        val normalConfig = TestConfig(uiTestMode = false)
        val normalRepo = AuthRepository(mockContext, normalConfig)
        assertTrue(normalRepo.isEmailWhitelisted("user1@example.com"))
        assertTrue(normalRepo.isEmailWhitelisted("user2@example.com"))
        assertFalse(normalRepo.isEmailWhitelisted("hacker@gmail.com"))

        // 2. Overridden whitelist (UI test mode)
        val testConfig = TestConfig(
            uiTestMode = true,
            authorizedEmails = listOf("test1@gmail.com", "test2@gmail.com")
        )
        val testRepo = AuthRepository(mockContext, testConfig)
        assertTrue(testRepo.isEmailWhitelisted("test1@gmail.com"))
        assertTrue(testRepo.isEmailWhitelisted("test2@gmail.com"))
        assertFalse(testRepo.isEmailWhitelisted("user1@example.com"))
    }

    @Test
    fun testVideoRepositoryCache_ReadAndWrite() {
        val mockContext = Mockito.mock(Context::class.java)
        val mockPrefs = Mockito.mock(SharedPreferences::class.java)

        Mockito.`when`(mockContext.getSharedPreferences("ytdash_cache", Context.MODE_PRIVATE))
            .thenReturn(mockPrefs)

        val dummyConfig = TestConfig()
        val dummyApi = YouTubeApiService(mockContext, dummyConfig)
        val repo = VideoRepository(mockContext, dummyApi)

        // Mock reading empty cache
        Mockito.`when`(mockPrefs.getString("cached_videos", null)).thenReturn(null)
        assertTrue(repo.getFromCache().isEmpty())

        // Mock saving/reading mock videos
        val videos = listOf(
            Video("v1", "Alpha Video", "Desc", "2026-07-02T10:00:00Z", "Category", "http://thumb", 12.34, 56.78),
            Video("v2", "Beta Video", "Desc2", "2026-07-01T10:00:00Z", "Category", "http://thumb2", null, null)
        )

        val gson = com.google.gson.Gson()
        val json = gson.toJson(videos)

        Mockito.`when`(mockPrefs.getString("cached_videos", null)).thenReturn(json)

        val retrieved = repo.getFromCache()
        assertEquals(2, retrieved.size)
        assertEquals("v1", retrieved[0].id)
        assertEquals("Alpha Video", retrieved[0].title)
        assertEquals(12.34, retrieved[0].lat ?: 0.0, 0.001)
        assertEquals("Beta Video", retrieved[1].title)
        assertNull(retrieved[1].lat)
    }

    @Test
    fun testSortingAndFilteringLogic() {
        val videos = listOf(
            Video("v1", "Z Video", "Desc", "2026-07-02T10:00:00Z", "cat-A", "http://thumb", 12.34, 56.78),
            Video("v2", "A Video", "Desc", "2026-07-01T10:00:00Z", "cat-B", "http://thumb2", null, null),
            Video("v3", "M Video", "Desc", "2026-07-03T10:00:00Z", "cat-A", "http://thumb3", null, null)
        )

        // Filter by category
        val filteredCatA = videos.filter { it.category.equals("cat-A", ignoreCase = true) }
        assertEquals(2, filteredCatA.size)
        assertTrue(filteredCatA.any { it.id == "v1" })
        assertTrue(filteredCatA.any { it.id == "v3" })

        // Sort by Date Descending
        val sortedDateDesc = videos.sortedByDescending { it.publishedAt }
        assertEquals("v3", sortedDateDesc[0].id) // 2026-07-03
        assertEquals("v1", sortedDateDesc[1].id) // 2026-07-02
        assertEquals("v2", sortedDateDesc[2].id) // 2026-07-01

        // Sort by Date Ascending
        val sortedDateAsc = videos.sortedBy { it.publishedAt }
        assertEquals("v2", sortedDateAsc[0].id) // 2026-07-01

        // Sort by Title Ascending
        val sortedTitleAsc = videos.sortedBy { it.title }
        assertEquals("v2", sortedTitleAsc[0].id) // "A Video"
        assertEquals("v3", sortedTitleAsc[1].id) // "M Video"
        assertEquals("v1", sortedTitleAsc[2].id) // "Z Video"

        // Sort by Title Descending
        val sortedTitleDesc = videos.sortedByDescending { it.title }
        assertEquals("v1", sortedTitleDesc[0].id) // "Z Video"
    }
}
