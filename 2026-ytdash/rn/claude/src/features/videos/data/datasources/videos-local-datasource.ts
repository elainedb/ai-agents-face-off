import * as SQLite from 'expo-sqlite';
import { CacheException } from '@/src/core/error/exceptions';
import { VideoModel } from '../models/video-model';

export interface VideosLocalDataSource {
  getCachedVideos(): Promise<VideoModel[]>;
  cacheVideos(videos: VideoModel[]): Promise<void>;
  isCacheValid(maxAge?: number): Promise<boolean>;
  getVideosByChannel(channelName: string): Promise<VideoModel[]>;
  getVideosByCountry(country: string): Promise<VideoModel[]>;
  getVideosWithLocation(): Promise<VideoModel[]>;
  clearCache(): Promise<void>;
}

interface VideoRow {
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
  cached_at: string;
}

/**
 * Escape a string for use in a SQL literal by doubling single quotes.
 */
function sqlEscape(value: string): string {
  return value.replace(/'/g, "''");
}

/**
 * Format a value as a SQL literal: strings are quoted, numbers are bare, null is NULL.
 */
function sqlLiteral(value: string | number | null | undefined): string {
  if (value === null || value === undefined) return 'NULL';
  if (typeof value === 'number') return String(value);
  return `'${sqlEscape(String(value))}'`;
}

export class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  private db: SQLite.SQLiteDatabase | null = null;

  private async getDb(): Promise<SQLite.SQLiteDatabase> {
    if (!this.db) {
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
    }
    return this.db;
  }

  private rowToModel(row: VideoRow): VideoModel {
    let tags: string[] = [];
    try {
      tags = JSON.parse(row.tags);
    } catch {
      tags = [];
    }
    return new VideoModel(
      row.id,
      row.title,
      row.channel_name,
      row.thumbnail_url,
      row.published_at,
      tags,
      row.city,
      row.country,
      row.latitude,
      row.longitude,
      row.recording_date,
    );
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos ORDER BY published_at DESC',
      );
      return rows.map((row) => this.rowToModel(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to read cache',
      );
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const db = await this.getDb();
      const now = new Date().toISOString();

      // Build all INSERT statements as raw SQL to bypass expo-sqlite v14's
      // Kotlin JSI bridge issues with parameterized queries containing nulls.
      const statements = ['DELETE FROM videos'];
      for (const video of videos) {
        const sql = `INSERT INTO videos (id, title, channel_name, thumbnail_url, published_at, tags, city, country, latitude, longitude, recording_date, cached_at)
VALUES (${sqlLiteral(video.id)}, ${sqlLiteral(video.title)}, ${sqlLiteral(video.channelName)}, ${sqlLiteral(video.thumbnailUrl)}, ${sqlLiteral(video.publishedAt)}, ${sqlLiteral(JSON.stringify(video.tags))}, ${sqlLiteral(video.city)}, ${sqlLiteral(video.country)}, ${sqlLiteral(video.latitude)}, ${sqlLiteral(video.longitude)}, ${sqlLiteral(video.recordingDate)}, ${sqlLiteral(now)})`;
        statements.push(sql);
      }

      await db.execAsync('BEGIN TRANSACTION');
      try {
        for (const stmt of statements) {
          await db.execAsync(stmt);
        }
        await db.execAsync('COMMIT');
      } catch (e) {
        await db.execAsync('ROLLBACK');
        throw e;
      }
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to cache videos',
      );
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
      const rows = await db.getAllAsync<VideoRow>(
        `SELECT * FROM videos WHERE channel_name = ${sqlLiteral(channelName)} ORDER BY published_at DESC`,
      );
      return rows.map((row) => this.rowToModel(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to query by channel',
      );
    }
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        `SELECT * FROM videos WHERE country = ${sqlLiteral(country)} ORDER BY published_at DESC`,
      );
      return rows.map((row) => this.rowToModel(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to query by country',
      );
    }
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    try {
      const db = await this.getDb();
      const rows = await db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC',
      );
      return rows.map((row) => this.rowToModel(row));
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to query located videos',
      );
    }
  }

  async clearCache(): Promise<void> {
    try {
      const db = await this.getDb();
      await db.execAsync('DELETE FROM videos');
    } catch (error) {
      throw new CacheException(
        error instanceof Error ? error.message : 'Failed to clear cache',
      );
    }
  }
}
