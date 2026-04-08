part of 'videos_bloc.dart';

@freezed
class VideosEvent with _$VideosEvent {
  const factory VideosEvent.loadVideos() = _LoadVideos;
  const factory VideosEvent.refreshVideos() = _RefreshVideos;
  const factory VideosEvent.filterByChannel(String? channelName) = _FilterByChannel;
  const factory VideosEvent.filterByCountry(String? country) = _FilterByCountry;
  const factory VideosEvent.sortVideos(SortBy sortBy, SortOrder sortOrder) = _SortVideos;
  const factory VideosEvent.clearFilters() = _ClearFilters;
}
