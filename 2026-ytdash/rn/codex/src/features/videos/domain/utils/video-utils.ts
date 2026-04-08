import type { Video } from '@/src/features/videos/domain/entities/video';

export const hasLocation = (video: Video) => video.city !== null || video.country !== null;

export const hasCoordinates = (video: Video) =>
  video.latitude !== null && video.longitude !== null;

export const hasRecordingDate = (video: Video) => video.recordingDate !== null;

export const locationText = (video: Video) => {
  if (video.city && video.country) {
    return `${video.city}, ${video.country}`;
  }

  if (video.city) {
    return video.city;
  }

  if (video.country) {
    return video.country;
  }

  if (hasCoordinates(video)) {
    return `${video.latitude?.toFixed(4)}, ${video.longitude?.toFixed(4)}`;
  }

  return 'Location unavailable';
};
