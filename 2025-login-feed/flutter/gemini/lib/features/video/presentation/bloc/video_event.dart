import 'package:equatable/equatable.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_state.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideos extends VideoEvent {
  final bool forceRefresh;

  const FetchVideos({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SortVideos extends VideoEvent {
  final VideoSort sort;

  const SortVideos(this.sort);

  @override
  List<Object?> get props => [sort];
}

class FilterVideos extends VideoEvent {
  final VideoFilter filter;

  const FilterVideos(this.filter);

  @override
  List<Object?> get props => [filter];
}
