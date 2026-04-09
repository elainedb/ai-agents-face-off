import { z } from 'zod';

import type { Video } from '@/src/features/videos/domain/entities/video';

export const videoModelSchema = z.object({
  id: z.string(),
  title: z.string(),
  channelName: z.string(),
  thumbnailUrl: z.string().url(),
  publishedAt: z.string(),
  tags: z.array(z.string()),
  city: z.string().nullable(),
  country: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  recordingDate: z.string().nullable(),
  locationDescription: z.string().nullable().optional(),
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
    readonly recordingDate: string | null,
    readonly locationDescription: string | null = null
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

  withResolvedLocation(location: { city: string | null; country: string | null }): VideoModel {
    return new VideoModel(
      this.id,
      this.title,
      this.channelName,
      this.thumbnailUrl,
      this.publishedAt,
      this.tags,
      location.city,
      location.country,
      this.latitude,
      this.longitude,
      this.recordingDate,
      this.locationDescription
    );
  }
}
