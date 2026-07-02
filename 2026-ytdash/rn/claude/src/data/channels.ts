import channelsJson from '../../config/channels.json';
import type { SourceChannel } from '../domain/models';

export function loadSourceChannels(): SourceChannel[] {
  return channelsJson as SourceChannel[];
}
