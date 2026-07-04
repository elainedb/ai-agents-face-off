import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/video_repository.dart';
import '../../../domain/entities/video.dart';
import 'video_event.dart';
import 'video_state.dart';

@injectable
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository repository;

  VideoBloc(this.repository) : super(VideoInitial()) {
    on<FetchVideos>((event, emit) async {
      emit(VideoLoading());
      final result = await repository.getVideos();
      result.fold(
        (failure) => emit(VideoError(failure.message)),
        (videos) {
          emit(VideoLoaded(videos, videos));
        },
      );
    });

    on<FilterVideos>((event, emit) {
      if (state is VideoLoaded) {
        final currentState = state as VideoLoaded;
        final filtered = currentState.videos.where((v) => 
          event.category.isEmpty || v.category.toLowerCase() == event.category.toLowerCase()
        ).toList();
        emit(VideoLoaded(currentState.videos, filtered));
      }
    });

    on<SortVideos>((event, emit) {
      if (state is VideoLoaded) {
        final currentState = state as VideoLoaded;
        final sorted = List<Video>.from(currentState.filteredVideos);
        if (event.ascending) {
          sorted.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
        } else {
          sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        }
        
        // Let's emit a completely new list to ensure the UI updates
        final newSorted = List<Video>.from(sorted);
        emit(VideoLoaded(currentState.videos, newSorted));
      }
    });
  }
}
