import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';

part 'videos_bloc.freezed.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

@freezed
class VideosEvent with _$VideosEvent {
  const factory VideosEvent.loadVideos() = LoadVideos;
  const factory VideosEvent.refreshVideos() = RefreshVideos;
  const factory VideosEvent.filterByChannel(String? channelName) =
      FilterByChannel;
  const factory VideosEvent.filterByCountry(String? country) = FilterByCountry;
  const factory VideosEvent.sortVideos(SortBy sortBy, SortOrder sortOrder) =
      SortVideos;
  const factory VideosEvent.clearFilters() = ClearFilters;
}

@freezed
class VideosState with _$VideosState {
  const VideosState._();

  const factory VideosState.initial() = VideosInitial;
  const factory VideosState.loading() = VideosLoading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    @Default(SortBy.publishedDate) SortBy sortBy,
    @Default(SortOrder.descending) SortOrder sortOrder,
    @Default(false) bool isRefreshing,
  }) = VideosLoaded;
  const factory VideosState.error(String message) = VideosError;
}

extension VideosLoadedX on VideosLoaded {
  List<String> get availableChannels {
    final channels = videos.map((video) => video.channelName).toSet().toList()
      ..sort();
    return channels;
  }

  List<String> get availableCountries {
    final countries =
        videos
            .map((video) => video.country)
            .whereType<String>()
            .where((country) => country.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return countries;
  }

  bool get hasActiveFilters {
    return selectedChannel != null ||
        selectedCountry != null ||
        sortBy != SortBy.publishedDate ||
        sortOrder != SortOrder.descending;
  }
}

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  VideosBloc(this._getVideos) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos, transformer: droppable());
    on<RefreshVideos>(_onRefreshVideos, transformer: restartable());
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  static const List<String> _channelIds = <String>[
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  final GetVideos _getVideos;

  Future<void> _onLoadVideos(
    LoadVideos event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosState.loading());
    final result = await _getVideos(
      const GetVideosParams(channelIds: _channelIds),
    );
    emit(
      result.fold(
        _mapFailureToState,
        (videos) => _applyFiltersAndSort(videos: videos),
      ),
    );
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      add(const VideosEvent.loadVideos());
      return;
    }

    emit(currentState.copyWith(isRefreshing: true));
    final result = await _getVideos(
      const GetVideosParams(channelIds: _channelIds, forceRefresh: true),
    );

    emit(
      result.fold(
        _mapFailureToState,
        (videos) => _applyFiltersAndSort(
          videos: videos,
          selectedChannel: currentState.selectedChannel,
          selectedCountry: currentState.selectedCountry,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
          isRefreshing: false,
        ),
      ),
    );
  }

  void _onFilterByChannel(FilterByChannel event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }

    emit(
      _applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: event.channelName,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ),
    );
  }

  void _onFilterByCountry(FilterByCountry event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }

    emit(
      _applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: event.country,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ),
    );
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }

    emit(
      _applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ),
    );
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }

    emit(_applyFiltersAndSort(videos: currentState.videos));
  }

  VideosState _applyFiltersAndSort({
    required List<Video> videos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy = SortBy.publishedDate,
    SortOrder sortOrder = SortOrder.descending,
    bool isRefreshing = false,
  }) {
    var filtered = List<Video>.from(videos);

    if (selectedChannel != null) {
      filtered = filtered
          .where((video) => video.channelName == selectedChannel)
          .toList();
    }

    if (selectedCountry != null) {
      filtered = filtered
          .where((video) => video.country == selectedCountry)
          .toList();
    }

    filtered = _sortVideos(filtered, sortBy, sortOrder);

    return VideosState.loaded(
      videos: videos,
      filteredVideos: filtered,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: isRefreshing,
    );
  }

  List<Video> _sortVideos(
    List<Video> videos,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    final sorted = List<Video>.from(videos);
    int compare(Video a, Video b) {
      final aDate = sortBy == SortBy.publishedDate
          ? a.publishedAt
          : (a.recordingDate ?? DateTime(1970));
      final bDate = sortBy == SortBy.publishedDate
          ? b.publishedAt
          : (b.recordingDate ?? DateTime(1970));
      return aDate.compareTo(bDate);
    }

    sorted.sort(compare);
    if (sortOrder == SortOrder.descending) {
      return sorted.reversed.toList();
    }
    return sorted;
  }

  VideosState _mapFailureToState(Failure failure) {
    return VideosState.error(failure.message);
  }
}
