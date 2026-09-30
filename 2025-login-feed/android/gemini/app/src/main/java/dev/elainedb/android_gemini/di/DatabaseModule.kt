package dev.elainedb.android_gemini.di

import androidx.room.Room
import dev.elainedb.android_gemini.data.database.YoutubeVideoDatabase
import org.koin.android.ext.koin.androidContext
import org.koin.dsl.module

val databaseModule = module {

    single {
        Room.databaseBuilder(
            androidContext(),
            YoutubeVideoDatabase::class.java,
            "youtube_videos.db"
        ).fallbackToDestructiveMigration().build()
    }

    single {
        get<YoutubeVideoDatabase>().youtubeVideoDao()
    }
}