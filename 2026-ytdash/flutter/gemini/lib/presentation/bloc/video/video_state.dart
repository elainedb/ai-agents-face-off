import 'package:equatable/equatable.dart';
import '../../../domain/entities/video.dart';

abstract class VideoState extends Equatable {
  const VideoState();
  
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> videos;
  final List<Video> filteredVideos;
  
  const VideoLoaded(this.videos, this.filteredVideos);
  
  @override
  List<Object?> get props => [videos, filteredVideos];
}

class VideoError extends VideoState {
  final String message;
  const VideoError(this.message);

  @override
  List<Object?> get props => [message];
}
