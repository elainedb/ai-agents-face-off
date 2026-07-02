import { SOURCE_CHANNELS } from './channels';
import { loadVideos, saveVideos } from './videoCache';
import { fetchChannelVideos, fetchVideoLocations } from './youtubeApi';
import { Result, Video, err, ok } from '../domain/types';

// Fetches ALL configured channels (no catch-all query exists), follows pagination for each,
// merges + dedupes by video id, then hydrates locations, persists, and returns the merged list.
// On any failure the caller (videoStore) falls back to the persisted cache — this function itself
// never touches the cache on the failure path, keeping "network refresh" and "cache fallback" as
// separate, individually testable concerns.
export async function refresh(baseUrl: string, apiKey: string): Promise<Result<Video[]>> {
  try {
    const perChannel = await Promise.all(SOURCE_CHANNELS.map((channel) => fetchChannelVideos(baseUrl, apiKey, channel)));

    const merged = new Map<string, (typeof perChannel)[number][number]>();
    for (const stubs of perChannel) {
      for (const stub of stubs) {
        if (!merged.has(stub.id)) merged.set(stub.id, stub);
      }
    }

    const ids = [...merged.keys()];
    const locations = await fetchVideoLocations(baseUrl, apiKey, ids);

    const videos: Video[] = ids.map((id) => {
      const stub = merged.get(id)!;
      return {
        id: stub.id,
        title: stub.title,
        description: stub.description,
        publishedAt: stub.publishedAt,
        category: stub.category,
        thumbnailUrl: stub.thumbnailUrl,
        location: locations.get(id) ?? null,
        youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
      };
    });

    await saveVideos(videos);
    return ok(videos);
  } catch (cause) {
    return err('Failed to refresh videos from the API', cause);
  }
}

export async function loadCached(): Promise<Video[] | null> {
  return loadVideos();
}
