import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/video/domain/usecases/get_videos.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_event.dart';
import 'package:flutter_gemini/features/video/presentation/bloc/video_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideos _getVideos;

  VideoBloc(this._getVideos) : super(const VideoState.initial()) {
    on<VideoEvent>((event, emit) async {
      await event.when(
        getVideos: () async {
          emit(const VideoState.loading());
          final result = await _getVideos(NoParams());
          result.fold(
            (failure) => emit(VideoState.error(failure.toString())),
            (videos) => emit(VideoState.loaded(videos)),
          );
        },
      );
    });
  }
}
