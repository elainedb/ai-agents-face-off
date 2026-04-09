import { NetworkException } from '@/src/core/error/exceptions';

interface ResolvedLocation {
  city: string | null;
  country: string | null;
}

const sleep = (duration: number): Promise<void> =>
  new Promise((resolve) => {
    setTimeout(resolve, duration);
  });

export class GeocodingService {
  private readonly cache = new Map<string, ResolvedLocation>();
  private queue = Promise.resolve();
  private lastRequestAt = 0;

  async reverseGeocode(
    latitude: number,
    longitude: number,
    locationDescription?: string | null
  ): Promise<ResolvedLocation> {
    const cacheKey = this.getCacheKey(latitude, longitude);
    const cached = this.cache.get(cacheKey);
    if (cached) {
      return cached;
    }

    const queuedLookup = this.queue.then(async () => {
      try {
        const resolved = await this.retryingLookup(latitude, longitude);
        this.cache.set(cacheKey, resolved);
        return resolved;
      } catch {
        const fallback = this.parseLocationDescription(locationDescription);
        this.cache.set(cacheKey, fallback);
        return fallback;
      }
    });

    this.queue = queuedLookup.then(() => undefined, () => undefined);
    return queuedLookup;
  }

  private async retryingLookup(latitude: number, longitude: number): Promise<ResolvedLocation> {
    const backoff = [1000, 2000, 4000];

    for (let index = 0; index < backoff.length; index += 1) {
      try {
        return await this.fetchReverseGeocode(latitude, longitude);
      } catch (error) {
        if (index === backoff.length - 1) {
          throw error;
        }

        await sleep(backoff[index]);
      }
    }

    throw new NetworkException('Geocoding failed.');
  }

  private async fetchReverseGeocode(latitude: number, longitude: number): Promise<ResolvedLocation> {
    const now = Date.now();
    const waitTime = Math.max(0, 1000 - (now - this.lastRequestAt));
    if (waitTime > 0) {
      await sleep(waitTime);
    }

    this.lastRequestAt = Date.now();

    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`,
      {
        headers: {
          'User-Agent': 'dev.elainedb.rn_codex/1.0',
        },
      }
    );

    if (!response.ok) {
      throw new NetworkException(`Geocoding failed with status ${response.status}.`);
    }

    const json = (await response.json()) as {
      address?: {
        city?: string;
        town?: string;
        village?: string;
        state?: string;
        country?: string;
      };
    };

    return {
      city: json.address?.city ?? json.address?.town ?? json.address?.village ?? json.address?.state ?? null,
      country: json.address?.country ?? null,
    };
  }

  private parseLocationDescription(locationDescription?: string | null): ResolvedLocation {
    if (!locationDescription) {
      return { city: null, country: null };
    }

    const match = locationDescription.match(/^\s*([^,]+)\s*,\s*([^,]+)\s*$/);
    if (!match) {
      return { city: null, country: null };
    }

    return {
      city: match[1]?.trim() ?? null,
      country: match[2]?.trim() ?? null,
    };
  }

  private getCacheKey(latitude: number, longitude: number): string {
    return `${latitude.toFixed(3)},${longitude.toFixed(3)}`;
  }
}
