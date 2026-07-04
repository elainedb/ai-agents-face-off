package com.example.ytdash.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.ytdash.data.model.VideoEntity

@Database(entities = [VideoEntity::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun videoDao(): VideoDao
}
