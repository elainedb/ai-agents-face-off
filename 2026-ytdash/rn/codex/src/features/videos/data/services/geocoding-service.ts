interface GeocodingResult {
  city: string | null;
  country: string | null;
}

const USER_AGENT = 'dev.elainedb.rn_claude/1.0';
const CITY_COUNTRY_PATTERN = /([A-Za-zÀ-ÿ.' -]+),\s*([A-Za-zÀ-ÿ.' -]+)/;

export class GeocodingService {
  private readonly cache = new Map<string, GeocodingResult>();

  private queue: Promise<void> = Promise.resolve();
  private lastRunAt = 0;

  private buildKey(latitude: number, longitude: number): string {
    return `${latitude.toFixed(3)},${longitude.toFixed(3)}`;
  }

  private async waitForRateLimit() {
    const elapsed = Date.now() - this.lastRunAt;
    const remaining = 1000 - elapsed;

    if (remaining > 0) {
      await new Promise((resolve) => setTimeout(resolve, remaining));
    }
  }

  private async request(latitude: number, longitude: number): Promise<GeocodingResult> {
    const query = new URLSearchParams({
      format: 'jsonv2',
      lat: String(latitude),
      lon: String(longitude),
      zoom: '10',
      addressdetails: '1',
    });

    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?${query.toString()}`,
      {
        headers: {
          Accept: 'application/json',
          'User-Agent': USER_AGENT,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Geocoding failed with status ${response.status}`);
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
  }

  private parseLocationDescription(locationDescription?: string | null): GeocodingResult {
    if (!locationDescription) {
      return { city: null, country: null };
    }

    const match = CITY_COUNTRY_PATTERN.exec(locationDescription);
    if (!match) {
      return { city: null, country: null };
    }

    return {
      city: match[1]?.trim() ?? null,
      country: match[2]?.trim() ?? null,
    };
  }

  private async runWithQueue(task: () => Promise<GeocodingResult>): Promise<GeocodingResult> {
    const previous = this.queue;
    let release = () => {};
    this.queue = new Promise<void>((resolve) => {
      release = resolve;
    });

    await previous;
    await this.waitForRateLimit();

    try {
      const result = await task();
      this.lastRunAt = Date.now();
      return result;
    } finally {
      release();
    }
  }

  async reverseGeocode(
    latitude: number,
    longitude: number,
    locationDescription?: string | null
  ): Promise<GeocodingResult> {
    const key = this.buildKey(latitude, longitude);
    const cached = this.cache.get(key);

    if (cached) {
      return cached;
    }

    for (const delay of [1000, 2000, 4000]) {
      try {
        const result = await this.runWithQueue(() => this.request(latitude, longitude));
        this.cache.set(key, result);
        return result;
      } catch {
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    const fallback = this.parseLocationDescription(locationDescription);
    this.cache.set(key, fallback);
    return fallback;
  }
}
