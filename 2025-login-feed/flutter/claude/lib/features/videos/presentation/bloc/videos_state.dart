import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/video.dart';

part 'videos_state.freezed.dart';

@freezed
class VideosState with _$VideosState {
  const factory VideosState.initial() = VideosInitial;
  const factory VideosState.loading() = VideosLoading;
  const factory VideosState.loaded(List<Video> videos) = VideosLoaded;
  const factory VideosState.error(String message) = VideosError;
}