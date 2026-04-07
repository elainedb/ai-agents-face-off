import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/video.dart';
import 'videos_event.dart';

part 'videos_state.freezed.dart';

@freezed
class VideosState with _$VideosState {
  const factory VideosState.initial() = _Initial;
  const factory VideosState.loading() = _Loading;
  const factory VideosState.loaded(
    List<Video> videos,
    List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
    bool isRefreshing,
  ) = VideosLoaded;
  const factory VideosState.error(String message) = _Error;
}
