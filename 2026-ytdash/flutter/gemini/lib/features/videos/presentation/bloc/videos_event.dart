part of 'videos_bloc.dart';

@freezed
class VideosEvent with _$VideosEvent {
  const factory VideosEvent.loadVideos() = LoadVideos;
  const factory VideosEvent.refreshVideos() = RefreshVideos;
  const factory VideosEvent.filterByChannel(String? channelName) = FilterByChannel;
  const factory VideosEvent.filterByCountry(String? country) = FilterByCountry;
  const factory VideosEvent.sortVideos(SortBy sortBy, SortOrder sortOrder) = SortVideos;
  const factory VideosEvent.clearFilters() = ClearFilters;
}
