import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_state.freezed.dart';

@freezed
abstract class VideoState with _$VideoState {
  const factory VideoState.initial() = _Initial;
  const factory VideoState.loading() = _Loading;
  const factory VideoState.loaded(List<Video> videos) = _Loaded;
  const factory VideoState.error(String message) = _Error;
}
