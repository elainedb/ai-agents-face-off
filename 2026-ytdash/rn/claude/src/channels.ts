import channelsJson from '../config/channels.json';

// The configured set of source YouTube channels to aggregate. Each carries a user-facing `label`
// which becomes the video's category (spec/youtube-api.md: "category = source-channel label").
// Read from config at build time so whatever the harness configures is honored — never hard-coded.
export type SourceChannel = { id: string; label: string };

export const SOURCE_CHANNELS: SourceChannel[] = (channelsJson as SourceChannel[]).filter(
  (c) => c && c.id && c.label
);
