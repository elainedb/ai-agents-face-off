import * as SQLite from 'expo-sqlite';

import { CacheException } from '@/src/core/error/exceptions';
import { VideoModel } from '@/src/features/videos/data/models/video-model';

const DB_NAME = 'videos.db';
const DAY_IN_MS = 24 * 60 * 60 * 1000;

export class VideosLocalDataSource {
  private databasePromise: Promise<SQLite.SQLiteDatabase> | null = null;

  private async getDatabase() {
    if (!this.databasePromise) {
      this.databasePromise = SQLite.openDatabaseAsync(DB_NAME);
    }

    const database = await this.databasePromise;

    await database.execAsync(`
      CREATE TABLE IF NOT EXISTS videos (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        channel_name TEXT NOT NULL,
        thumbnail_url TEXT NOT NULL,
        published_at TEXT NOT NULL,
        tags TEXT NOT NULL,
        city TEXT,
        country TEXT,
        latitude REAL,
        longitude REAL,
        recording_date TEXT,
        cached_at INTEGER NOT NULL
      );
      CREATE INDEX IF NOT EXISTS idx_videos_channel_name ON videos(channel_name);
      CREATE INDEX IF NOT EXISTS idx_videos_country ON videos(country);
      CREATE INDEX IF NOT EXISTS idx_videos_published_at ON videos(published_at);
      CREATE INDEX IF NOT EXISTS idx_videos_cached_at ON videos(cached_at);
    `);

    return database;
  }

  private mapRow(row: unknown): VideoModel {
    const values = row as Record<string, unknown>;
    return VideoModel.fromJson({
      id: values.id,
      title: values.title,
      channelName: values.channel_name,
      thumbnailUrl: values.thumbnail_url,
      publishedAt: values.published_at,
      tags: JSON.parse(String(values.tags)),
      city: values.city ?? null,
      country: values.country ?? null,
      latitude: typeof values.latitude === 'number' ? values.latitude : null,
      longitude: typeof values.longitude === 'number' ? values.longitude : null,
      recordingDate: values.recording_date ?? null,
    });
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const database = await this.getDatabase();
      const rows = await database.getAllAsync('SELECT * FROM videos ORDER BY published_at DESC');
      return rows.map((row) => this.mapRow(row));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Unable to read cache.');
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const database = await this.getDatabase();
      const cachedAt = Date.now();

      await database.withExclusiveTransactionAsync(async (tx) => {
        await tx.execAsync('DELETE FROM videos');

        for (const video of videos) {
          await tx.runAsync(
            `INSERT INTO videos (
              id, title, channel_name, thumbnail_url, published_at, tags,
              city, country, latitude, longitude, recording_date, cached_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
              video.id,
              video.title,
              video.channelName,
              video.thumbnailUrl,
              video.publishedAt,
              JSON.stringify(video.tags),
              video.city,
              video.country,
              video.latitude,
              video.longitude,
              video.recordingDate,
              cachedAt,
            ]
          );
        }
      });
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Unable to cache videos.');
    }
  }

  async isCacheValid(maxAge: number = DAY_IN_MS): Promise<boolean> {
    const database = await this.getDatabase();
    const row = await database.getFirstAsync<{ cached_at?: number }>(
      'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1'
    );

    if (!row?.cached_at) {
      return false;
    }

    return Date.now() - row.cached_at < maxAge;
  }

  async getVideosByChannel(channelName: string): Promise<VideoModel[]> {
    const database = await this.getDatabase();
    const rows = await database.getAllAsync(
      'SELECT * FROM videos WHERE channel_name = ? ORDER BY published_at DESC',
      [channelName]
    );
    return rows.map((row) => this.mapRow(row));
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    const database = await this.getDatabase();
    const rows = await database.getAllAsync(
      'SELECT * FROM videos WHERE country = ? ORDER BY published_at DESC',
      [country]
    );
    return rows.map((row) => this.mapRow(row));
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    const database = await this.getDatabase();
    const rows = await database.getAllAsync(
      'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC'
    );
    return rows.map((row) => this.mapRow(row));
  }

  async clearCache(): Promise<void> {
    const database = await this.getDatabase();
    await database.execAsync('DELETE FROM videos');
  }
}
