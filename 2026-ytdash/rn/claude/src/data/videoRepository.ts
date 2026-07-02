import { Video } from '../domain/types';
import { getSourceChannels } from './channels';
import { ApiConfig, fetchVideoDetails, searchAllChannelVideos } from './youtubeApi';
import { CacheStore } from './cacheStore';

export type RepositoryResult =
  | { kind: 'success'; videos: Video[] }
  | { kind: 'stale'; videos: Video[] }
  | { kind: 'error'; message: string };

export interface VideoRepository {
  getAll(cfg: ApiConfig): Promise<RepositoryResult>;
}

function toYoutubeUrl(id: string): string {
  return `https://www.youtube.com/watch?v=${id}`;
}

export class HttpVideoRepository implements VideoRepository {
  constructor(private readonly cache: CacheStore) {}

  async getAll(cfg: ApiConfig): Promise<RepositoryResult> {
    try {
      const videos = await this.fetchFromNetwork(cfg);
      await this.cache.write(videos, Date.now());
      return { kind: 'success', videos };
    } catch (err) {
      const cached = await this.cache.read();
      if (cached && cached.videos.length > 0) {
        return { kind: 'stale', videos: cached.videos };
      }
      const message = err instanceof Error ? err.message : 'Failed to load videos';
      return { kind: 'error', message };
    }
  }

  private async fetchFromNetwork(cfg: ApiConfig): Promise<Video[]> {
    const channels = getSourceChannels();

    // videoId -> the label of the FIRST configured channel it was found under (a video belongs to
    // exactly one source channel; the API has no cross-channel "ALL" query so we iterate all of
    // them and merge/dedupe by videoId).
    const labelById = new Map<string, string>();
    const fallbackSnippetById = new Map<
      string,
      { title: string; description: string; publishedAt: string; thumbnailUrl: string }
    >();

    for (const channel of channels) {
      const items = await searchAllChannelVideos(cfg, channel.id);
      for (const item of items) {
        const videoId = item.id.videoId;
        if (!videoId || labelById.has(videoId)) continue;
        labelById.set(videoId, channel.label);
        fallbackSnippetById.set(videoId, {
          title: item.snippet.title,
          description: item.snippet.description,
          publishedAt: item.snippet.publishedAt,
          thumbnailUrl: item.snippet.thumbnails.medium?.url ?? item.snippet.thumbnails.default?.url ?? '',
        });
      }
    }

    const ids = Array.from(labelById.keys());
    const details = await fetchVideoDetails(cfg, ids);
    const detailsById = new Map(details.map((d) => [d.id, d]));

    return ids.map((id) => {
      const detail = detailsById.get(id);
      const fallback = fallbackSnippetById.get(id)!;
      const location = detail?.recordingDetails?.location
        ? { lat: detail.recordingDetails.location.latitude, lng: detail.recordingDetails.location.longitude }
        : null;
      return {
        id,
        title: detail?.snippet.title ?? fallback.title,
        description: detail?.snippet.description ?? fallback.description,
        publishedAt: detail?.snippet.publishedAt ?? fallback.publishedAt,
        category: labelById.get(id)!,
        thumbnailUrl:
          detail?.snippet.thumbnails.medium?.url ??
          detail?.snippet.thumbnails.default?.url ??
          fallback.thumbnailUrl,
        location,
        youtubeUrl: toYoutubeUrl(id),
      };
    });
  }
}
