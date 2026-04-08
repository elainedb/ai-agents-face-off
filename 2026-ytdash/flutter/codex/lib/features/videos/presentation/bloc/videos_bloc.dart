import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';

part 'videos_bloc.freezed.dart';
part 'videos_event.dart';
part 'videos_state.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  VideosBloc(this._getVideos) : super(const VideosState.initial()) {
    on<_LoadVideos>(_onLoadVideos, transformer: droppable());
    on<_RefreshVideos>(_onRefreshVideos, transformer: sequential());
    on<_FilterByChannel>(_onFilterByChannel);
    on<_FilterByCountry>(_onFilterByCountry);
    on<_SortVideos>(_onSortVideos);
    on<_ClearFilters>(_onClearFilters);
  }

  static const List<String> channelIds = <String>[
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  final GetVideos _getVideos;

  Future<void> _onLoadVideos(_LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await _getVideos(
      const GetVideosParams(channelIds: channelIds),
    );
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(
        _buildLoadedState(
          allVideos: videos,
          selectedChannel: null,
          selectedCountry: null,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
        ),
      ),
    );
  }

  Future<void> _onRefreshVideos(
    _RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      add(const VideosEvent.loadVideos());
      return;
    }

    emit(currentState.copyWith(isRefreshing: true));
    final result = await _getVideos(
      const GetVideosParams(channelIds: channelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(
        _buildLoadedState(
          allVideos: videos,
          selectedChannel: currentState.selectedChannel,
          selectedCountry: currentState.selectedCountry,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
        ),
      ),
    );
  }

  void _onFilterByChannel(_FilterByChannel event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }
    emit(
      _buildLoadedState(
        allVideos: currentState.videos,
        selectedChannel: event.channelName,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ),
    );
  }

  void _onFilterByCountry(_FilterByCountry event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }
    emit(
      _buildLoadedState(
        allVideos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: event.country,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ),
    );
  }

  void _onSortVideos(_SortVideos event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }
    emit(
      _buildLoadedState(
        allVideos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ),
    );
  }

  void _onClearFilters(_ClearFilters event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is! VideosLoaded) {
      return;
    }
    emit(
      _buildLoadedState(
        allVideos: currentState.videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      ),
    );
  }

  VideosLoaded _buildLoadedState({
    required List<Video> allVideos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    final filteredVideos = _applyFiltersAndSort(
      videos: allVideos,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    return VideosLoaded(
      videos: allVideos,
      filteredVideos: filteredVideos,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: false,
    );
  }

  List<Video> _applyFiltersAndSort({
    required List<Video> videos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    var output = List<Video>.from(videos);
    if (selectedChannel != null) {
      output = output.where((video) => video.channelName == selectedChannel).toList();
    }
    if (selectedCountry != null) {
      output = output.where((video) => video.country == selectedCountry).toList();
    }
    output.sort((left, right) => _compareVideos(left, right, sortBy, sortOrder));
    return output;
  }

  int _compareVideos(
    Video left,
    Video right,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    final leftValue = sortBy == SortBy.publishedDate
        ? left.publishedAt
        : (left.recordingDate ?? DateTime(1970));
    final rightValue = sortBy == SortBy.publishedDate
        ? right.publishedAt
        : (right.recordingDate ?? DateTime(1970));
    final comparison = leftValue.compareTo(rightValue);
    return sortOrder == SortOrder.ascending ? comparison : -comparison;
  }
}
