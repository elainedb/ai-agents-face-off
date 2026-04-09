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
