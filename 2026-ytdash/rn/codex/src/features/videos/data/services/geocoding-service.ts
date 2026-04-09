import { NetworkException } from '@/src/core/error/exceptions';

type GeocodeResult = {
  city: string | null;
  country: string | null;
};

export class GeocodingService {
  private readonly cache = new Map<string, GeocodeResult>();
  private lastRequestAt = 0;
  private queue = Promise.resolve();

  async reverseGeocode(
    latitude: number,
    longitude: number,
    locationDescription?: string | null,
  ): Promise<GeocodeResult> {
    const cacheKey = this.getCacheKey(latitude, longitude);
    const cached = this.cache.get(cacheKey);

    if (cached) {
      return cached;
    }

    return this.enqueue(async () => {
      const existing = this.cache.get(cacheKey);
      if (existing) {
        return existing;
      }

      const fromApi = await this.requestWithRetry(latitude, longitude).catch(() => null);
      const result = fromApi ?? this.parseLocationDescription(locationDescription);

      this.cache.set(cacheKey, result);
      return result;
    });
  }

  private enqueue<T>(task: () => Promise<T>): Promise<T> {
    const next = this.queue.then(async () => {
      await this.waitForRateLimit();
      const result = await task();
      this.lastRequestAt = Date.now();
      return result;
    });

    this.queue = next.then(() => undefined, () => undefined);
    return next;
  }

  private async waitForRateLimit(): Promise<void> {
    const elapsed = Date.now() - this.lastRequestAt;
    const waitMs = Math.max(0, 1000 - elapsed);

    if (waitMs > 0) {
      await new Promise((resolve) => setTimeout(resolve, waitMs));
    }
  }

  private async requestWithRetry(latitude: number, longitude: number): Promise<GeocodeResult> {
    const backoffSchedule = [1000, 2000, 4000];
    let lastError: unknown;

    for (let attempt = 0; attempt < backoffSchedule.length; attempt += 1) {
      try {
        const response = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`,
          {
            headers: {
              Accept: 'application/json',
              'User-Agent': 'dev.elainedb.rn_codex/1.0',
            },
          },
        );

        if (!response.ok) {
          if (response.status >= 500) {
            throw new NetworkException(`Geocoding service failed with ${response.status}.`);
          }

          return { city: null, country: null };
        }

        const payload = (await response.json()) as {
          address?: {
            city?: string;
            town?: string;
            village?: string;
            municipality?: string;
            country?: string;
          };
        };

        return {
          city:
            payload.address?.city ??
            payload.address?.town ??
            payload.address?.village ??
            payload.address?.municipality ??
            null,
          country: payload.address?.country ?? null,
        };
      } catch (error) {
        lastError = error;
        if (attempt < backoffSchedule.length - 1) {
          await new Promise((resolve) => setTimeout(resolve, backoffSchedule[attempt]));
        }
      }
    }

    throw lastError instanceof Error ? lastError : new NetworkException('Geocoding failed.');
  }

  private parseLocationDescription(locationDescription?: string | null): GeocodeResult {
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
    return `${latitude.toFixed(3)}:${longitude.toFixed(3)}`;
  }
}
