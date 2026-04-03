import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';
import 'videos_event.dart';
import 'videos_state.dart';

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos _getVideos;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc(this._getVideos) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideosEvent>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await _getVideos(const GetVideosParams(channelIds: _channelIds));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => _emitLoaded(emit, videos: videos),
    );
  }

  Future<void> _onRefreshVideos(RefreshVideos event, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const VideosState.loading());
    }

    final result = await _getVideos(const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        if (currentState is VideosLoaded) {
          _emitLoaded(
            emit,
            videos: videos,
            selectedChannel: currentState.selectedChannel,
            selectedCountry: currentState.selectedCountry,
            sortBy: currentState.sortBy,
            sortOrder: currentState.sortOrder,
          );
        } else {
           _emitLoaded(emit, videos: videos);
        }
      },
    );
  }

  void _onFilterByChannel(FilterByChannel event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _emitLoaded(
        emit,
        videos: currentState.videos,
        selectedChannel: event.channelName,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      );
    }
  }

  void _onFilterByCountry(FilterByCountry event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _emitLoaded(
        emit,
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: event.country,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      );
    }
  }

  void _onSortVideos(SortVideosEvent event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _emitLoaded(
        emit,
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _emitLoaded(
        emit,
        videos: currentState.videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      );
    }
  }

  void _emitLoaded(
    Emitter<VideosState> emit, {
    required List<Video> videos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy = SortBy.publishedDate,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    List<Video> filtered = List.from(videos);

    if (selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == selectedChannel).toList();
    }
    if (selectedCountry != null) {
      filtered = filtered.where((v) => v.country == selectedCountry).toList();
    }

    filtered.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      if (sortBy == SortBy.publishedDate) {
        dateA = a.publishedAt;
        dateB = b.publishedAt;
      } else {
        dateA = a.recordingDate ?? DateTime(1970);
        dateB = b.recordingDate ?? DateTime(1970);
      }

      if (sortOrder == SortOrder.ascending) {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    emit(VideosState.loaded(
      videos: videos,
      filteredVideos: filtered,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: false,
    ));
  }
}
