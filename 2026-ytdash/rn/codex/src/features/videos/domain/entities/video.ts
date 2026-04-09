export interface Video {
  readonly id: string;
  readonly title: string;
  readonly channelName: string;
  readonly thumbnailUrl: string;
  readonly publishedAt: Date;
  readonly tags: readonly string[];
  readonly city: string | null;
  readonly country: string | null;
  readonly latitude: number | null;
  readonly longitude: number | null;
  readonly recordingDate: Date | null;
}

export const hasLocation = (video: Video): boolean => Boolean(video.city || video.country);

export const hasCoordinates = (video: Video): boolean =>
  typeof video.latitude === 'number' && typeof video.longitude === 'number';

export const hasRecordingDate = (video: Video): boolean => video.recordingDate !== null;

export const locationText = (video: Video): string => {
  const parts = [video.city, video.country].filter(Boolean);
  if (parts.length > 0) {
    return parts.join(', ');
  }

  if (hasCoordinates(video)) {
    return `${video.latitude?.toFixed(4)}, ${video.longitude?.toFixed(4)}`;
  }

  return 'Location unavailable';
};
