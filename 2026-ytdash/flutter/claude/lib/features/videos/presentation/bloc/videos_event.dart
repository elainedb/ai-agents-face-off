import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';

part 'videos_event.freezed.dart';

@freezed
sealed class VideosEvent with _$VideosEvent {
  const factory VideosEvent.loadVideos() = LoadVideos;
  const factory VideosEvent.refreshVideos() = RefreshVideos;
  const factory VideosEvent.filterByChannel(String? channelName) =
      FilterByChannel;
  const factory VideosEvent.filterByCountry(String? country) = FilterByCountry;
  const factory VideosEvent.sortVideos(SortBy sortBy, SortOrder sortOrder) =
      SortVideosEvent;
  const factory VideosEvent.clearFilters() = ClearFilters;
}
