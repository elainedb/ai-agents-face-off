import { z } from 'zod';

import { Video } from '@/src/features/videos/domain/entities/video';

export const videoModelSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  channelName: z.string().min(1),
  thumbnailUrl: z.string().url(),
  publishedAt: z.string().min(1),
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
    public readonly city: string | null,
    public readonly country: string | null,
    public readonly latitude: number | null,
    public readonly longitude: number | null,
    public readonly recordingDate: string | null,
  ) {}

  static fromJson(json: unknown): VideoModel {
    const parsed = videoModelSchema.parse(json);
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
      parsed.recordingDate,
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
