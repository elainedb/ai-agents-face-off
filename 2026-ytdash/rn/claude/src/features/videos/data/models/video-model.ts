import { z } from 'zod';
import { Video } from '../../domain/entities/video';

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
    public readonly id: string,
    public readonly title: string,
    public readonly channelName: string,
    public readonly thumbnailUrl: string,
    public readonly publishedAt: string,
    public readonly tags: string[],
    public city: string | null,
    public country: string | null,
    public readonly latitude: number | null,
    public readonly longitude: number | null,
    public readonly recordingDate: string | null,
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
