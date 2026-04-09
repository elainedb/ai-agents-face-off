const USER_AGENT = 'dev.elainedb.rn_claude/1.0';
const RATE_LIMIT_MS = 1100;
const MAX_RETRIES = 3;

interface GeoResult {
  city: string | null;
  country: string | null;
}

const cache = new Map<string, GeoResult>();
let lastRequestTime = 0;

function cacheKey(lat: number, lng: number): string {
  return `${lat.toFixed(3)},${lng.toFixed(3)}`;
}

async function waitForRateLimit(): Promise<void> {
  const now = Date.now();
  const elapsed = now - lastRequestTime;
  if (elapsed < RATE_LIMIT_MS) {
    await new Promise((resolve) => setTimeout(resolve, RATE_LIMIT_MS - elapsed));
  }
  lastRequestTime = Date.now();
}

async function fetchWithRetry(lat: number, lng: number): Promise<GeoResult> {
  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    try {
      await waitForRateLimit();
      const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=10`;
      const response = await fetch(url, {
        headers: { 'User-Agent': USER_AGENT },
      });
      if (response.status >= 500) {
        throw new Error(`Server error: ${response.status}`);
      }
      if (!response.ok) {
        return { city: null, country: null };
      }
      const data = await response.json();
      const address = data.address ?? {};
      const city = address.city ?? address.town ?? address.village ?? address.municipality ?? null;
      const country = address.country ?? null;
      return { city, country };
    } catch (error: unknown) {
      if (attempt < MAX_RETRIES - 1) {
        const backoff = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, backoff));
        continue;
      }
      return { city: null, country: null };
    }
  }
  return { city: null, country: null };
}

function parseLocationDescription(description: string | undefined | null): GeoResult {
  if (!description) return { city: null, country: null };
  const match = description.match(/^(.+),\s*(.+)$/);
  if (match) {
    return { city: match[1].trim(), country: match[2].trim() };
  }
  return { city: null, country: null };
}

export async function reverseGeocode(
  lat: number,
  lng: number,
  locationDescription?: string | null,
): Promise<GeoResult> {
  const key = cacheKey(lat, lng);
  const cached = cache.get(key);
  if (cached) return cached;

  const result = await fetchWithRetry(lat, lng);

  if (result.city || result.country) {
    cache.set(key, result);
    return result;
  }

  const fallback = parseLocationDescription(locationDescription);
  cache.set(key, fallback);
  return fallback;
}

export function clearGeoCache(): void {
  cache.clear();
}
