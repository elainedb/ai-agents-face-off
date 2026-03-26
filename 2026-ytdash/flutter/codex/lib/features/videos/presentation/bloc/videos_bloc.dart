import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video.dart';
import '../../domain/usecases/clear_cache.dart';
import '../../domain/usecases/get_videos.dart';
import '../../domain/usecases/get_videos_by_channel.dart';
import '../../domain/usecases/get_videos_by_country.dart';
import 'videos_event.dart';
import 'videos_state.dart';

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  VideosBloc({
    required this.getVideos,
    required this.getVideosByChannel,
    required this.getVideosByCountry,
    required this.clearCache,
  }) : super(const VideosInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  static const List<String> channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  final GetVideos getVideos;
  final GetVideosByChannel getVideosByChannel;
  final GetVideosByCountry getVideosByCountry;
  final ClearCache clearCache;

  Future<void> _onLoadVideos(
    LoadVideos event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosLoading());
    final result = await getVideos(
      const GetVideosParams(channelIds: channelIds),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(_buildLoadedState(videos: videos)),
    );
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      add(const LoadVideos());
      return;
    }

    emit(current.copyWith(isRefreshing: true));
    final result = await getVideos(
      const GetVideosParams(channelIds: channelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _buildLoadedState(
          videos: videos,
          selectedChannel: current.selectedChannel,
          selectedCountry: current.selectedCountry,
          sortBy: current.sortBy,
          sortOrder: current.sortOrder,
        ),
      ),
    );
  }

  Future<void> _onFilterByChannel(
    FilterByChannel event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        current.copyWith(selectedChannel: event.channelName),
      ),
    );
  }

  Future<void> _onFilterByCountry(
    FilterByCountry event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }
    emit(
      _applyFiltersAndSort(current.copyWith(selectedCountry: event.country)),
    );
  }

  Future<void> _onSortVideos(
    SortVideos event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        current.copyWith(sortBy: event.sortBy, sortOrder: event.sortOrder),
      ),
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }
    emit(_buildLoadedState(videos: current.videos));
  }

  VideosLoaded _buildLoadedState({
    required List<Video> videos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy = SortBy.publishedDate,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    return _applyFiltersAndSort(
      VideosLoaded(
        videos: videos,
        filteredVideos: videos,
        selectedChannel: selectedChannel,
        selectedCountry: selectedCountry,
        sortBy: sortBy,
        sortOrder: sortOrder,
        isRefreshing: false,
      ),
    );
  }

  VideosLoaded _applyFiltersAndSort(VideosLoaded state) {
    var filtered = List<Video>.from(state.videos);

    if (state.selectedChannel != null) {
      filtered = filtered
          .where((video) => video.channelName == state.selectedChannel)
          .toList();
    }

    if (state.selectedCountry != null) {
      filtered = filtered
          .where((video) => video.country == state.selectedCountry)
          .toList();
    }

    filtered.sort(
      (a, b) => _sortValue(a, state).compareTo(_sortValue(b, state)),
    );
    if (state.sortOrder == SortOrder.descending) {
      filtered = filtered.reversed.toList();
    }

    return state.copyWith(filteredVideos: filtered, isRefreshing: false);
  }

  DateTime _sortValue(Video video, VideosLoaded state) {
    switch (state.sortBy) {
      case SortBy.publishedDate:
        return video.publishedAt;
      case SortBy.recordingDate:
        return video.recordingDate ?? DateTime(1970);
    }
  }
}
