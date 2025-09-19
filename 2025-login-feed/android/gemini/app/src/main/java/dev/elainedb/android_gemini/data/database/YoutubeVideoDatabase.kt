
package dev.elainedb.android_gemini.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import dev.elainedb.android_gemini.domain.youtube.Location
 
 @Database(entities = [YoutubeVideoEntity::class, TagEntity::class, LocationEntity::class], version = 2, exportSchema = false)
 abstract class YoutubeVideoDatabase : RoomDatabase() {    abstract fun youtubeVideoDao(): YoutubeVideoDao
}
