import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_videos.dart';
import 'videos_event.dart';
import 'videos_state.dart';

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos getVideos;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc({required this.getVideos}) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
  }

  Future<void> _onLoadVideos(
    LoadVideos event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosState.loading());

    final result = await getVideos(GetVideosParams(channelIds: _channelIds));

    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(videos)),
    );
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    // For refresh, we don't show loading state if we already have data
    if (state is! VideosLoaded) {
      emit(const VideosState.loading());
    }

    final result = await getVideos(GetVideosParams(channelIds: _channelIds));

    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(videos)),
    );
  }
}