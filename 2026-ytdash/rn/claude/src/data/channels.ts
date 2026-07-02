import channelsJson from '../../config/channels.json';

export type SourceChannel = {
  id: string;
  label: string;
};

// config/channels.json is non-secret build configuration (which channels to aggregate), not a
// fixture value — bundling it is expected per spec.md. It is NOT the video data itself.
export const SOURCE_CHANNELS: SourceChannel[] = channelsJson;
