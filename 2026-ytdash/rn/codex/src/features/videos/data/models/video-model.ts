import { z } from 'zod';

import type { Video } from '@/src/features/videos/domain/entities/video';

export const videoModelSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  channelName: z.string().min(1),
  thumbnailUrl: z.string().url(),
  publishedAt: z.string(),
  tags: z.array(z.string()),
  city: z.string().nullable(),
  country: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  recordingDate: z.string().nullable(),
});

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
    readonly recordingDate: string | null
  ) {}

  static fromJson(data: unknown): VideoModel {
    const parsed = videoModelSchema.parse(data);
    return new VideoModel(
      parsed.id,
      parsed.title,
      parsed.channelName,
      parsed.thumbnailUrl,
      parsed.publishedAt,
      parsed.tags,
      parsed.city,
      parsed.country,
      parsed.latitude,
      parsed.longitude,
      parsed.recordingDate
    );
  }

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
