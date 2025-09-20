import 'package:equatable/equatable.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';

enum SortKey { publicationDate, recordingDate }

enum SortDirection { asc, desc }

class VideoSort with EquatableMixin {
  final SortKey key;
  final SortDirection direction;

  VideoSort({required this.key, required this.direction});

  @override
  List<Object?> get props => [key, direction];
}

class VideoFilter with EquatableMixin {
  final String? channel;
  final String? country;

  VideoFilter({this.channel, this.country});

  @override
  List<Object?> get props => [channel, country];
}

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> originalVideos;
  final List<Video> filteredVideos;
  final VideoSort sort;
  final VideoFilter filter;

  const VideoLoaded({
    required this.originalVideos,
    required this.filteredVideos,
    required this.sort,
    required this.filter,
  });

  @override
  List<Object?> get props => [originalVideos, filteredVideos, sort, filter];
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object?> get props => [message];
}