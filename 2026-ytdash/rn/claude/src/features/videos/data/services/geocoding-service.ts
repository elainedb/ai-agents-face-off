interface GeoResult {
  city: string | null;
  country: string | null;
}

export class GeocodingService {
  private cache = new Map<string, GeoResult>();
  private lastRequestTime = 0;

  private cacheKey(lat: number, lng: number): string {
    return `${lat.toFixed(3)},${lng.toFixed(3)}`;
  }

  private async delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  private async enforceRateLimit(): Promise<void> {
    const now = Date.now();
    const elapsed = now - this.lastRequestTime;
    if (elapsed < 1000) {
      await this.delay(1000 - elapsed);
    }
    this.lastRequestTime = Date.now();
  }

  async reverseGeocode(lat: number, lng: number): Promise<GeoResult> {
    const key = this.cacheKey(lat, lng);
    const cached = this.cache.get(key);
    if (cached) return cached;

    let lastError: Error | null = null;
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        await this.enforceRateLimit();
        const response = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`,
          {
            headers: {
              'User-Agent': 'dev.elainedb.rn_claude/1.0',
              Accept: 'application/json',
            },
          },
        );
        if (response.status >= 500) {
          throw new Error(`Server error: ${response.status}`);
        }
        const data = await response.json();
        const result: GeoResult = {
          city:
            data.address?.city ??
            data.address?.town ??
            data.address?.village ??
            null,
          country: data.address?.country ?? null,
        };
        this.cache.set(key, result);
        return result;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));
        const backoff = Math.pow(2, attempt) * 1000;
        await this.delay(backoff);
      }
    }

    console.warn(`Geocoding failed for ${lat},${lng}: ${lastError?.message}`);
    const fallback: GeoResult = { city: null, country: null };
    this.cache.set(key, fallback);
    return fallback;
  }

  parseLocationDescription(description: string | null): GeoResult {
    if (!description) return { city: null, country: null };
    const match = description.match(/^(.+),\s*(.+)$/);
    if (match) {
      return { city: match[1].trim(), country: match[2].trim() };
    }
    return { city: null, country: description.trim() || null };
  }
}
