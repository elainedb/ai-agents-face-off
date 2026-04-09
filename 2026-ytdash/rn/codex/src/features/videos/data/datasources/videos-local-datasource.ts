import * as SQLite from 'expo-sqlite';

import { CacheException } from '@/src/core/error/exceptions';
import { VideoModel } from '@/src/features/videos/data/models/video-model';

type VideoRow = {
  id: string;
  title: string;
  channel_name: string;
  thumbnail_url: string;
  published_at: string;
  tags: string;
  city: string | null;
  country: string | null;
  latitude: number | null;
  longitude: number | null;
  recording_date: string | null;
};

export class VideosLocalDataSource {
  private dbPromise: Promise<SQLite.SQLiteDatabase> | null = null;

  private async getDb(): Promise<SQLite.SQLiteDatabase> {
    if (!this.dbPromise) {
      this.dbPromise = this.initDb();
    }

    return this.dbPromise;
  }

  private async initDb(): Promise<SQLite.SQLiteDatabase> {
    const db = await SQLite.openDatabaseAsync('videos.db');

    await db.execAsync(`
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

    return db;
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos ORDER BY published_at DESC',
      );
      return rows.map((row) => this.mapRow(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to read cached videos.',
      );
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const db = await this.getDb();
      const cachedAt = Date.now();

      await db.withTransactionAsync(async () => {
        await db.runAsync('DELETE FROM videos');

        for (const video of videos) {
          const insertSql = this.buildInsertSql(video, cachedAt);

          await db.execAsync(insertSql);
        }
      });
    } catch (error) {
      console.error('[VideosLocalDataSource.cacheVideos] Failed to cache videos', {
        count: videos.length,
        firstVideo: videos[0]
          ? {
              id: videos[0].id,
              publishedAt: videos[0].publishedAt,
              recordingDate: videos[0].recordingDate,
              tagsType: Array.isArray(videos[0].tags) ? 'array' : typeof videos[0].tags,
            }
          : null,
        error,
      });
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to cache videos.',
      );
    }
  }

  async isCacheValid(maxAge = 24 * 60 * 60 * 1000): Promise<boolean> {
    try {
      const db = await this.getDb();
      const result = await db.getFirstAsync<{ cached_at: number }>(
        'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1',
      );

      if (!result) {
        return false;
      }

      return Date.now() - result.cached_at < maxAge;
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to validate cache.',
      );
    }
  }

  async getVideosByChannel(channelName: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE channel_name = ? ORDER BY published_at DESC',
        channelName,
      );
      return rows.map((row) => this.mapRow(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to read videos by channel.',
      );
    }
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE country = ? ORDER BY published_at DESC',
        country,
      );
      return rows.map((row) => this.mapRow(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to read videos by country.',
      );
    }
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC',
      );
      return rows.map((row) => this.mapRow(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to read videos with location.',
      );
    }
  }

  async clearCache(): Promise<void> {
    try {
      const db = await this.getDb();
      await db.runAsync('DELETE FROM videos');
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Unable to clear cache.',
      );
    }
  }

  private mapRow(row: VideoRow): VideoModel {
    return VideoModel.fromJson({
      id: row.id,
      title: row.title,
      channelName: row.channel_name,
      thumbnailUrl: row.thumbnail_url,
      publishedAt: row.published_at,
      tags: JSON.parse(row.tags) as string[],
      city: row.city,
      country: row.country,
      latitude: row.latitude,
      longitude: row.longitude,
      recordingDate: row.recording_date,
    });
  }

  private buildInsertSql(video: VideoModel, cachedAt: number): string {
    const entries = [
      ['id', video.id],
      ['title', video.title],
      ['channel_name', video.channelName],
      ['thumbnail_url', video.thumbnailUrl],
      ['published_at', video.publishedAt],
      ['tags', JSON.stringify(video.tags)],
      ['city', video.city],
      ['country', video.country],
      ['latitude', video.latitude],
      ['longitude', video.longitude],
      ['recording_date', video.recordingDate],
      ['cached_at', cachedAt],
    ] as const;

    const serializedValues = entries.map(([key, value], index) => ({
      key,
      value: this.serializeSqlLiteral(value, index, video.id),
    }));

    console.log('[VideosLocalDataSource.cacheVideos] SQLite bind values prepared', {
      videoId: video.id,
      fields: serializedValues.map(({ key, value }) => ({
        key,
        preview: value.slice(0, 80),
      })),
    });

    return `INSERT INTO videos (
      id, title, channel_name, thumbnail_url, published_at, tags,
      city, country, latitude, longitude, recording_date, cached_at
    ) VALUES (${serializedValues.map(({ value }) => value).join(', ')})`;
  }

  private serializeSqlLiteral(value: unknown, index: number, videoId: string): string {
    if (value == null) {
      return 'NULL';
    }

    if (typeof value === 'string') {
      return `'${this.escapeSqlString(value)}'`;
    }

    if (typeof value === 'number') {
      return Number.isFinite(value) ? String(value) : 'NULL';
    }

    if (typeof value === 'boolean') {
      return value ? '1' : '0';
    }

    if (value instanceof Date) {
      return `'${value.toISOString()}'`;
    }

    const serialized = JSON.stringify(value);
    console.error('[VideosLocalDataSource.cacheVideos] Non-primitive SQLite value detected', {
      videoId,
      index,
      valueType: typeof value,
      constructorName:
        typeof value === 'object' && value && 'constructor' in value
          ? (value as { constructor?: { name?: string } }).constructor?.name
          : null,
      serialized,
    });

    return serialized ? `'${this.escapeSqlString(serialized)}'` : 'NULL';
  }

  private escapeSqlString(value: string): string {
    return value.replaceAll("'", "''");
  }
}
