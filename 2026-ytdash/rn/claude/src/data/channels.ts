import { SourceChannel } from '../domain/types';
import channelsJson from '../../config/channels.json';

export function getSourceChannels(): SourceChannel[] {
  return channelsJson as SourceChannel[];
}
