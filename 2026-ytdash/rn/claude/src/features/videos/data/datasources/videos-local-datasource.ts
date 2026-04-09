import * as SQLite from 'expo-sqlite';
import { CacheException } from '../../../../core/error/exceptions';
import { VideoModel } from '../models/video-model';

function escapeSql(value: string): string {
  return value.replace(/'/g, "''");
}

function sqlString(value: string | null): string {
  if (value === null) return 'NULL';
  return `'${escapeSql(value)}'`;
}

function sqlNumber(value: number | null): string {
  if (value === null) return 'NULL';
  return String(value);
}

export interface VideosLocalDataSource {
  getCachedVideos(): Promise<VideoModel[]>;
  cacheVideos(videos: VideoModel[]): Promise<void>;
  isCacheValid(maxAge?: number): Promise<boolean>;
  getVideosByChannel(channelName: string): Promise<VideoModel[]>;
  getVideosByCountry(country: string): Promise<VideoModel[]>;
  getVideosWithLocation(): Promise<VideoModel[]>;
  clearCache(): Promise<void>;
}

export class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  private db: SQLite.SQLiteDatabase | null = null;

  private async getDb(): Promise<SQLite.SQLiteDatabase> {
    if (this.db) return this.db;
    this.db = await SQLite.openDatabaseAsync('videos.db');
    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS videos (
        id TEXT PRIMARY KEY,
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
        cached_at TEXT NOT NULL
      );
      CREATE INDEX IF NOT EXISTS idx_channel_name ON videos(channel_name);
      CREATE INDEX IF NOT EXISTS idx_country ON videos(country);
      CREATE INDEX IF NOT EXISTS idx_published_at ON videos(published_at);
      CREATE INDEX IF NOT EXISTS idx_cached_at ON videos(cached_at);
    `);
    return this.db;
  }

  private rowToModel(row: Record<string, unknown>): VideoModel {
    const tags: string[] = (() => {
      try {
        return JSON.parse(row['tags'] as string);
      } catch {
        return [];
      }
    })();
    return new VideoModel(
      row['id'] as string,
      row['title'] as string,
      row['channel_name'] as string,
      row['thumbnail_url'] as string,
      row['published_at'] as string,
      tags,
      (row['city'] as string) ?? null,
      (row['country'] as string) ?? null,
      (row['latitude'] as number) ?? null,
      (row['longitude'] as number) ?? null,
      (row['recording_date'] as string) ?? null,
    );
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync('SELECT * FROM videos ORDER BY published_at DESC');
      return (rows as Record<string, unknown>[]).map((row) => this.rowToModel(row));
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to read cache: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const db = await this.getDb();
      const cachedAt = new Date().toISOString();

      let sql = 'DELETE FROM videos;\n';

      for (const video of videos) {
        const tagsJson = JSON.stringify(video.tags);
        sql += `INSERT INTO videos (id, title, channel_name, thumbnail_url, published_at, tags, city, country, latitude, longitude, recording_date, cached_at) VALUES (${sqlString(video.id)}, ${sqlString(video.title)}, ${sqlString(video.channelName)}, ${sqlString(video.thumbnailUrl)}, ${sqlString(video.publishedAt)}, ${sqlString(tagsJson)}, ${sqlString(video.city)}, ${sqlString(video.country)}, ${sqlNumber(video.latitude)}, ${sqlNumber(video.longitude)}, ${sqlString(video.recordingDate)}, ${sqlString(cachedAt)});\n`;
      }

      await db.execAsync(sql);
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to cache videos: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async isCacheValid(maxAge: number = 24 * 60 * 60 * 1000): Promise<boolean> {
    try {
      const db = await this.getDb();
      const row = await db.getFirstAsync(
        'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1',
      );
      if (!row) return false;
      const cachedAt = new Date((row as Record<string, unknown>)['cached_at'] as string).getTime();
      return Date.now() - cachedAt < maxAge;
    } catch {
      return false;
    }
  }

  async getVideosByChannel(channelName: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        'SELECT * FROM videos WHERE channel_name = ? ORDER BY published_at DESC',
        [channelName],
      );
      return (rows as Record<string, unknown>[]).map((row) => this.rowToModel(row));
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to query by channel: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        'SELECT * FROM videos WHERE country = ? ORDER BY published_at DESC',
        [country],
      );
      return (rows as Record<string, unknown>[]).map((row) => this.rowToModel(row));
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to query by country: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC',
      );
      return (rows as Record<string, unknown>[]).map((row) => this.rowToModel(row));
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to query videos with location: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async clearCache(): Promise<void> {
    try {
      const db = await this.getDb();
      await db.execAsync('DELETE FROM videos');
    } catch (error: unknown) {
      throw new CacheException(
        `Failed to clear cache: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}
