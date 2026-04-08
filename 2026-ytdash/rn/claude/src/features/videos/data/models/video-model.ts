import { z } from 'zod';
import type { Video } from '../../domain/entities/video';

export const videoModelSchema = z.object({
  id: z.string(),
  title: z.string(),
  channelName: z.string(),
  thumbnailUrl: z.string(),
  publishedAt: z.string(),
  tags: z.array(z.string()),
  city: z.string().nullable(),
  country: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  recordingDate: z.string().nullable(),
});

export type VideoModelData = z.infer<typeof videoModelSchema>;

export class VideoModel {
  constructor(
    readonly id: string,
    readonly title: string,
    readonly channelName: string,
    readonly thumbnailUrl: string,
    readonly publishedAt: string,
    readonly tags: string[],
    readonly city: string | null,
    readonly country: string | null,
    readonly latitude: number | null,
    readonly longitude: number | null,
    readonly recordingDate: string | null,
  ) {}

  toEntity(): Video {
    return {
      id: this.id,
      title: this.title,
      channelName: this.channelName,
      thumbnailUrl: this.thumbnailUrl,
      publishedAt: new Date(this.publishedAt),
      tags: this.tags,
      city: this.city,
      country: this.country,
      latitude: this.latitude,
      longitude: this.longitude,
      recordingDate: this.recordingDate ? new Date(this.recordingDate) : null,
    };
  }
}
