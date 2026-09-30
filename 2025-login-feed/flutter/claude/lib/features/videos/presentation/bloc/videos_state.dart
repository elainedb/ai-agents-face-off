import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/video.dart';
import 'videos_event.dart';

part 'videos_state.freezed.dart';

@freezed
class VideosState with _$VideosState {
  const factory VideosState.initial() = VideosInitial;
  const factory VideosState.loading() = VideosLoading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    @Default(SortBy.publishedDate) SortBy sortBy,
    @Default(SortOrder.descending) SortOrder sortOrder,
    @Default(false) bool isRefreshing,
  }) = VideosLoaded;
  const factory VideosState.error(String message) = VideosError;
}