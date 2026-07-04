import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/models/video.dart';
import '../../../../core/error/result.dart';

// Events
abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {}

class RefreshVideos extends VideoEvent {}

class ApplyFilter extends VideoEvent {
  final String? category;
  ApplyFilter(this.category);
  @override
  List<Object?> get props => [category];
}

class ApplySort extends VideoEvent {
  final bool ascending;
  ApplySort({required this.ascending});
  @override
  List<Object?> get props => [ascending];
}

// States
abstract class VideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> allVideos;
  final List<Video> displayedVideos;
  final String? currentFilter;
  final bool currentSortAscending;

  VideoLoaded({
    required this.allVideos,
    required this.displayedVideos,
    this.currentFilter,
    this.currentSortAscending = false,
  });

  @override
  List<Object?> get props => [
    allVideos,
    displayedVideos,
    currentFilter,
    currentSortAscending,
  ];
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository videoRepository;

  VideoBloc({required this.videoRepository}) : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    final result = await videoRepository.getVideos();
    if (result is Success<List<Video>>) {
      emit(
        VideoLoaded(
          allVideos: result.data,
          displayedVideos: _sortVideos(result.data, false),
          currentSortAscending: false,
        ),
      );
    } else if (result is Error<List<Video>>) {
      emit(VideoError(result.failure.message));
    }
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideoState> emit,
  ) async {
    final currentState = state;
    if (currentState is VideoLoaded) {
      emit(
        VideoLoading(),
      ); // Wait, refresh should probably just show loading and keep old? Or just use a RefreshIndicator
    } else {
      emit(VideoLoading());
    }

    final result = await videoRepository.getVideos();
    if (result is Success<List<Video>>) {
      final filter = currentState is VideoLoaded
          ? currentState.currentFilter
          : null;
      final asc = currentState is VideoLoaded
          ? currentState.currentSortAscending
          : false;

      var displayed = result.data;
      if (filter != null) {
        displayed = displayed.where((v) => v.category == filter).toList();
      }
      displayed = _sortVideos(displayed, asc);

      emit(
        VideoLoaded(
          allVideos: result.data,
          displayedVideos: displayed,
          currentFilter: filter,
          currentSortAscending: asc,
        ),
      );
    } else if (result is Error<List<Video>>) {
      // If we are refreshing, maybe emit error state? The spec says "no error state" if offline fallback works.
      // Our repository handles offline fallback. If it still fails, show error.
      emit(VideoError(result.failure.message));
    }
  }

  void _onApplyFilter(ApplyFilter event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final current = state as VideoLoaded;
      var displayed = current.allVideos;
      if (event.category != null) {
        displayed = displayed
            .where((v) => v.category == event.category)
            .toList();
      }
      displayed = _sortVideos(displayed, current.currentSortAscending);

      emit(
        VideoLoaded(
          allVideos: current.allVideos,
          displayedVideos: displayed,
          currentFilter: event.category,
          currentSortAscending: current.currentSortAscending,
        ),
      );
    }
  }

  void _onApplySort(ApplySort event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final current = state as VideoLoaded;
      var displayed = current.displayedVideos;
      displayed = _sortVideos(displayed, event.ascending);

      emit(
        VideoLoaded(
          allVideos: current.allVideos,
          displayedVideos: displayed,
          currentFilter: current.currentFilter,
          currentSortAscending: event.ascending,
        ),
      );
    }
  }

  List<Video> _sortVideos(List<Video> videos, bool ascending) {
    final copy = List<Video>.from(videos);
    copy.sort((a, b) {
      if (ascending) {
        return a.publishedAt.compareTo(b.publishedAt);
      } else {
        return b.publishedAt.compareTo(a.publishedAt);
      }
    });
    return copy;
  }
}
