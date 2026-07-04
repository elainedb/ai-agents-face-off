import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideos extends VideoEvent {}

class FilterVideos extends VideoEvent {
  final String category;
  const FilterVideos(this.category);

  @override
  List<Object?> get props => [category];
}

class SortVideos extends VideoEvent {
  final bool ascending;
  const SortVideos(this.ascending);

  @override
  List<Object?> get props => [ascending];
}
