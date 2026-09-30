import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_gemini/features/video/domain/usecases/get_videos.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_event.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideos getVideos;

  VideoBloc(this.getVideos) : super(VideoInitial()) {
    on<FetchVideos>(_onFetchVideos, transformer: restartable());
    on<SortVideos>(_onSortVideos);
    on<FilterVideos>(_onFilterVideos);
  }

  Future<void> _onFetchVideos(
      FetchVideos event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    final failureOrVideos =
        await getVideos(GetVideosParams(forceRefresh: event.forceRefresh));
    failureOrVideos.fold(
      (failure) => emit(VideoError(failure.toString())),
      (videos) {
        final sortedVideos = List.of(videos)
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        emit(VideoLoaded(
          originalVideos: List.of(sortedVideos),
          filteredVideos: List.of(sortedVideos),
          sort: VideoSort(
              key: SortKey.publicationDate, direction: SortDirection.desc),
          filter: VideoFilter(),
        ));
      },
    );
  }

  void _onSortVideos(SortVideos event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      final videos = List.of(currentState.filteredVideos);

      videos.sort((a, b) {
        int comparison;
        if (event.sort.key == SortKey.publicationDate) {
          comparison = a.publishedAt.compareTo(b.publishedAt);
        } else {
          if (a.recordingDate == null && b.recordingDate == null) {
            comparison = 0;
          } else if (a.recordingDate == null) {
            comparison = 1;
          } else if (b.recordingDate == null) {
            comparison = -1;
          } else {
            comparison = a.recordingDate!.compareTo(b.recordingDate!);
          }
        }
        return event.sort.direction == SortDirection.asc
            ? comparison
            : -comparison;
      });

      emit(VideoLoaded(
        originalVideos: List.of(currentState.originalVideos),
        filteredVideos: videos,
        sort: event.sort,
        filter: currentState.filter,
      ));
    }
  }

  void _onFilterVideos(FilterVideos event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      final videos = List.of(currentState.originalVideos);

      final filteredVideos = videos.where((video) {
        final channelMatch = event.filter.channel == null ||
            video.channelTitle == event.filter.channel;
        final countryMatch = event.filter.country == null ||
            video.country == event.filter.country;
        return channelMatch && countryMatch;
      }).toList();

      emit(VideoLoaded(
        originalVideos: List.of(currentState.originalVideos),
        filteredVideos: filteredVideos,
        sort: currentState.sort,
        filter: event.filter,
      ));
    }
  }
}
