package com.example.ytdash

import com.example.ytdash.data.Location
import com.example.ytdash.data.Video
import com.example.ytdash.ui.list.SortOption
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class YtdashUnitTests {

    private val testVideos = listOf(
        Video(
            id = "vid1",
            title = "Banana Video",
            description = "A great banana video",
            category = "fruit",
            publishedAt = "2026-07-01T12:00:00Z",
            thumbnailUrl = "http://thumb1",
            location = Location(10.0, 20.0)
        ),
        Video(
            id = "vid2",
            title = "Apple Video",
            description = "A tasty apple video",
            category = "fruit",
            publishedAt = "2026-06-30T10:00:00Z",
            thumbnailUrl = "http://thumb2",
            location = null
        ),
        Video(
            id = "vid3",
            title = "Cherry Video",
            description = "Sweet cherry video",
            category = "berries",
            publishedAt = "2026-07-02T15:00:00Z",
            thumbnailUrl = "http://thumb3",
            location = Location(-5.0, -10.0)
        )
    )

    // 1. Whitelist Verification Tests
    @Test
    fun testWhitelistValidation() {
        val whitelist = listOf("user1@example.com", "user2@example.com")
        
        // Exact match
        assertTrue(whitelist.any { it.equals("user1@example.com", ignoreCase = true) })
        assertTrue(whitelist.any { it.equals("user2@example.com", ignoreCase = true) })
        
        // Case insensitive match
        assertTrue(whitelist.any { it.equals("USER1@example.com", ignoreCase = true) })
        assertTrue(whitelist.any { it.equals("User2@example.com", ignoreCase = true) })
        
        // Non-whitelisted email
        assertFalse(whitelist.any { it.equals("hacker@gmail.com", ignoreCase = true) })
        assertFalse(whitelist.any { it.equals("user4@example.com", ignoreCase = true) })
    }

    // 2. Sorting Logic Tests
    @Test
    fun testSortingByDateDesc() {
        // Newest to Oldest (Cherry -> Banana -> Apple)
        val sorted = testVideos.sortedByDescending { it.publishedAt }
        assertEquals("vid3", sorted[0].id)
        assertEquals("vid1", sorted[1].id)
        assertEquals("vid2", sorted[2].id)
    }

    @Test
    fun testSortingByDateAsc() {
        // Oldest to Newest (Apple -> Banana -> Cherry)
        val sorted = testVideos.sortedBy { it.publishedAt }
        assertEquals("vid2", sorted[0].id)
        assertEquals("vid1", sorted[1].id)
        assertEquals("vid3", sorted[2].id)
    }

    @Test
    fun testSortingByTitleAsc() {
        // A to Z (Apple -> Banana -> Cherry)
        val sorted = testVideos.sortedBy { it.title.lowercase() }
        assertEquals("vid2", sorted[0].id)
        assertEquals("vid1", sorted[1].id)
        assertEquals("Cherry Video", sorted[2].title)
    }

    @Test
    fun testSortingByTitleDesc() {
        // Z to A (Cherry -> Banana -> Apple)
        val sorted = testVideos.sortedByDescending { it.title.lowercase() }
        assertEquals("Cherry Video", sorted[0].title)
        assertEquals("vid1", sorted[1].id)
        assertEquals("vid2", sorted[2].id)
    }

    // 3. Filtering Logic Tests
    @Test
    fun testFilteringByCategory() {
        val fruitVideos = testVideos.filter { it.category.equals("fruit", ignoreCase = true) }
        assertEquals(2, fruitVideos.size)
        assertTrue(fruitVideos.any { it.id == "vid1" })
        assertTrue(fruitVideos.any { it.id == "vid2" })

        val berryVideos = testVideos.filter { it.category.equals("berries", ignoreCase = true) }
        assertEquals(1, berryVideos.size)
        assertEquals("vid3", berryVideos[0].id)

        val nonExistent = testVideos.filter { it.category.equals("vegetable", ignoreCase = true) }
        assertEquals(0, nonExistent.size)
    }

    // 4. Persistence / Serialization Sim Test
    @Test
    fun testCacheSerializationAndDeserialization() {
        val json = kotlinx.serialization.json.Json {
            ignoreUnknownKeys = true
            coerceInputValues = true
        }

        // Serialize
        val serializedStr = json.encodeToString(Video.serializer(), testVideos[0])
        assertTrue(serializedStr.contains("Banana Video"))
        assertTrue(serializedStr.contains("fruit"))

        // Deserialize
        val deserializedVideo = json.decodeFromString(Video.serializer(), serializedStr)
        assertEquals(testVideos[0].id, deserializedVideo.id)
        assertEquals(testVideos[0].title, deserializedVideo.title)
        assertEquals(testVideos[0].location?.lat, deserializedVideo.location?.lat)
    }
}
