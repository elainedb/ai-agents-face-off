import * as SQLite from 'expo-sqlite';
import { CacheException } from '@/src/core/error/exceptions';
import { VideoModel } from '../models/video-model';

const DB_NAME = 'videos.db';

function sqlEscape(value: string | null): string {
  if (value === null || value === undefined) return 'NULL';
  return `'${value.replace(/'/g, "''")}'`;
}

function sqlNum(value: number | null): string {
  if (value === null || value === undefined) return 'NULL';
  return String(value);
}

export class VideosLocalDataSource {
  private db: SQLite.SQLiteDatabase | null = null;

  private async getDb(): Promise<SQLite.SQLiteDatabase> {
    if (!this.db) {
      this.db = await SQLite.openDatabaseAsync(DB_NAME);
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
    }
    return this.db;
  }

  private rowToModel(row: Record<string, unknown>): VideoModel {
    return new VideoModel(
      row['id'] as string,
      row['title'] as string,
      row['channel_name'] as string,
      row['thumbnail_url'] as string,
      row['published_at'] as string,
      JSON.parse(row['tags'] as string),
      row['city'] as string | null,
      row['country'] as string | null,
      row['latitude'] as number | null,
      row['longitude'] as number | null,
      row['recording_date'] as string | null,
    );
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync('SELECT * FROM videos ORDER BY published_at DESC');
      return (rows as Record<string, unknown>[]).map((r) => this.rowToModel(r));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache read error';
      throw new CacheException(message);
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const db = await this.getDb();
      const now = new Date().toISOString();

      await db.execAsync('DELETE FROM videos');
      for (const v of videos) {
        const sql = `INSERT INTO videos (id, title, channel_name, thumbnail_url, published_at, tags, city, country, latitude, longitude, recording_date, cached_at)
          VALUES (${sqlEscape(v.id)}, ${sqlEscape(v.title)}, ${sqlEscape(v.channelName)}, ${sqlEscape(v.thumbnailUrl)}, ${sqlEscape(v.publishedAt)}, ${sqlEscape(JSON.stringify(v.tags))}, ${sqlEscape(v.city)}, ${sqlEscape(v.country)}, ${sqlNum(v.latitude)}, ${sqlNum(v.longitude)}, ${sqlEscape(v.recordingDate)}, ${sqlEscape(now)})`;
        await db.execAsync(sql);
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache write error';
      throw new CacheException(message);
    }
  }

  async isCacheValid(maxAge: number = 24 * 60 * 60 * 1000): Promise<boolean> {
    try {
      const db = await this.getDb();
      const row = await db.getFirstAsync<{ cached_at: string }>(
        'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1',
      );
      if (!row) return false;
      const cachedAt = new Date(row.cached_at).getTime();
      return Date.now() - cachedAt < maxAge;
    } catch {
      return false;
    }
  }

  async getVideosByChannel(channelName: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        `SELECT * FROM videos WHERE channel_name = ${sqlEscape(channelName)} ORDER BY published_at DESC`,
      );
      return (rows as Record<string, unknown>[]).map((r) => this.rowToModel(r));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache read error';
      throw new CacheException(message);
    }
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        `SELECT * FROM videos WHERE country = ${sqlEscape(country)} ORDER BY published_at DESC`,
      );
      return (rows as Record<string, unknown>[]).map((r) => this.rowToModel(r));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache read error';
      throw new CacheException(message);
    }
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync(
        'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC',
      );
      return (rows as Record<string, unknown>[]).map((r) => this.rowToModel(r));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache read error';
      throw new CacheException(message);
    }
  }

  async clearCache(): Promise<void> {
    try {
      const db = await this.getDb();
      await db.execAsync('DELETE FROM videos');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache clear error';
      throw new CacheException(message);
    }
  }
}
