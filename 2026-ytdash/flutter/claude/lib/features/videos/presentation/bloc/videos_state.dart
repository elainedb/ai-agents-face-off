import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';

part 'videos_state.freezed.dart';

@freezed
sealed class VideosState with _$VideosState {
  const factory VideosState.initial() = VideosInitial;
  const factory VideosState.loading() = VideosLoading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
    @Default(false) bool isRefreshing,
  }) = VideosLoaded;
  const factory VideosState.error(String message) = VideosError;
}
