import channelsJson from '../../config/channels.json';
import { SourceChannel } from '../domain/types';

// The configured set of source channels to aggregate. Read from config (anti-overfit): there is no
// catch-all endpoint — the app iterates these and merges/dedupes (spec §Iteration 2, youtube-api §).
export const SOURCE_CHANNELS: SourceChannel[] = channelsJson as SourceChannel[];
