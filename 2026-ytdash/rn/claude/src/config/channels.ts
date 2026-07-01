import { Channel } from '../data/api';
// Source channels to aggregate (bundled config; NO catch-all endpoint exists — the app must
// iterate these and merge). Kept out of src/ so it stays the single shared config file.
import raw from '../../config/channels.json';

export const CHANNELS: Channel[] = (raw as { id: string; label: string }[]).map((c) => ({
  id: c.id,
  label: c.label,
}));
