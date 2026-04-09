import { Video } from '@/src/features/videos/domain/entities/video';

export const hasLocation = (video: Video): boolean => video.city != null || video.country != null;

export const hasCoordinates = (video: Video): boolean =>
  video.latitude != null && video.longitude != null;

export const hasRecordingDate = (video: Video): boolean => video.recordingDate != null;

export const locationText = (video: Video): string => {
  const location = [video.city, video.country].filter(Boolean).join(', ');

  if (location) {
    return location;
  }

  if (hasCoordinates(video)) {
    return `${video.latitude}, ${video.longitude}`;
  }

  return 'Unknown location';
};
