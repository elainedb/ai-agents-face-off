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
  cached_at: string;
};

type Database = Awaited<ReturnType<typeof SQLite.openDatabaseAsync>>;

const escapeSqlValue = (value: string | number | null): string => {
  if (value === null) {
    return 'NULL';
  }

  if (typeof value === 'number') {
    return Number.isFinite(value) ? `${value}` : 'NULL';
  }

  return `'${value.replaceAll("'", "''")}'`;
};

export class VideosLocalDataSource {
  constructor(private readonly db: Database) {}

  async init(): Promise<void> {
    try {
      await this.db.execAsync(`
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
          cached_at TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_videos_channel_name ON videos(channel_name);
        CREATE INDEX IF NOT EXISTS idx_videos_country ON videos(country);
        CREATE INDEX IF NOT EXISTS idx_videos_published_at ON videos(published_at);
        CREATE INDEX IF NOT EXISTS idx_videos_cached_at ON videos(cached_at);
      `);
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to initialize cache.');
    }
  }

  async getCachedVideos(): Promise<VideoModel[]> {
    try {
      const rows = await this.db.getAllAsync<VideoRow>(
        'SELECT * FROM videos ORDER BY published_at DESC'
      );
      return rows.map((row) => this.mapRowToModel(row));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to read cached videos.');
    }
  }

  async cacheVideos(videos: VideoModel[]): Promise<void> {
    try {
      const cachedAt = new Date().toISOString();
      const statements = [
        'BEGIN TRANSACTION;',
        'DELETE FROM videos;',
        ...videos.map((video) => {
          const values: (string | number | null)[] = [
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
          ];

          return `INSERT INTO videos (
            id, title, channel_name, thumbnail_url, published_at, tags, city, country,
            latitude, longitude, recording_date, cached_at
          ) VALUES (${values.map(escapeSqlValue).join(', ')});`;
        }),
        'COMMIT;',
      ];

      await this.db.execAsync(statements.join('\n'));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to cache videos.');
    }
  }

  async isCacheValid(maxAge = 24 * 60 * 60 * 1000): Promise<boolean> {
    try {
      const latestRow = await this.db.getFirstAsync<{ cached_at: string }>(
        'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1'
      );

      if (!latestRow?.cached_at) {
        return false;
      }

      return Date.now() - new Date(latestRow.cached_at).getTime() < maxAge;
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to inspect cache.');
    }
  }

  async getVideosByChannel(channelName: string): Promise<VideoModel[]> {
    try {
      const rows = await this.db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE channel_name = ? ORDER BY published_at DESC',
        [channelName]
      );
      return rows.map((row) => this.mapRowToModel(row));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to filter cached videos.');
    }
  }

  async getVideosByCountry(country: string): Promise<VideoModel[]> {
    try {
      const rows = await this.db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE country = ? ORDER BY published_at DESC',
        [country]
      );
      return rows.map((row) => this.mapRowToModel(row));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to filter cached videos.');
    }
  }

  async getVideosWithLocation(): Promise<VideoModel[]> {
    try {
      const rows = await this.db.getAllAsync<VideoRow>(
        'SELECT * FROM videos WHERE latitude IS NOT NULL AND longitude IS NOT NULL ORDER BY published_at DESC'
      );
      return rows.map((row) => this.mapRowToModel(row));
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to read map videos.');
    }
  }

  async clearCache(): Promise<void> {
    try {
      await this.db.execAsync('DELETE FROM videos;');
    } catch (error) {
      throw new CacheException(error instanceof Error ? error.message : 'Failed to clear cache.');
    }
  }

  private mapRowToModel(row: VideoRow): VideoModel {
    return new VideoModel(
      row.id,
      row.title,
      row.channel_name,
      row.thumbnail_url,
      row.published_at,
      JSON.parse(row.tags) as string[],
      row.city,
      row.country,
      row.latitude,
      row.longitude,
      row.recording_date
    );
  }
}
