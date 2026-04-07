import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/channel_ids.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';
import '../../domain/usecases/get_videos_by_channel.dart';
import '../../domain/usecases/get_videos_by_country.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

sealed class VideosEvent extends Equatable {
  const VideosEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideosEvent {
  const LoadVideos();
}

class RefreshVideos extends VideosEvent {
  const RefreshVideos();
}

class FilterByChannel extends VideosEvent {
  const FilterByChannel(this.channelName);

  final String? channelName;

  @override
  List<Object?> get props => [channelName];
}

class FilterByCountry extends VideosEvent {
  const FilterByCountry(this.country);

  final String? country;

  @override
  List<Object?> get props => [country];
}

class SortVideos extends VideosEvent {
  const SortVideos(this.sortBy, this.sortOrder);

  final SortBy sortBy;
  final SortOrder sortOrder;

  @override
  List<Object?> get props => [sortBy, sortOrder];
}

class ClearFilters extends VideosEvent {
  const ClearFilters();
}

sealed class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosError extends VideosState {
  const VideosError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class VideosLoaded extends VideosState {
  const VideosLoaded({
    required this.videos,
    required this.filteredVideos,
    required this.selectedChannel,
    required this.selectedCountry,
    required this.sortBy,
    required this.sortOrder,
    required this.isRefreshing,
  });

  final List<Video> videos;
  final List<Video> filteredVideos;
  final String? selectedChannel;
  final String? selectedCountry;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isRefreshing;

  List<String> get availableChannels {
    final channels = videos.map((video) => video.channelName).toSet().toList()
      ..sort();
    return channels;
  }

  List<String> get availableCountries {
    final countries = videos
        .map((video) => video.country)
        .whereType<String>()
        .where((country) => country.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return countries;
  }

  bool get hasActiveFilters =>
      selectedChannel != null ||
      selectedCountry != null ||
      sortBy != SortBy.publishedDate ||
      sortOrder != SortOrder.descending;

  VideosLoaded copyWith({
    List<Video>? videos,
    List<Video>? filteredVideos,
    String? selectedChannel,
    bool clearSelectedChannel = false,
    String? selectedCountry,
    bool clearSelectedCountry = false,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? isRefreshing,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      filteredVideos: filteredVideos ?? this.filteredVideos,
      selectedChannel: clearSelectedChannel
          ? null
          : selectedChannel ?? this.selectedChannel,
      selectedCountry: clearSelectedCountry
          ? null
          : selectedCountry ?? this.selectedCountry,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    videos,
    filteredVideos,
    selectedChannel,
    selectedCountry,
    sortBy,
    sortOrder,
    isRefreshing,
  ];
}

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  VideosBloc({
    required GetVideos getVideos,
    required GetVideosByChannel getVideosByChannel,
    required GetVideosByCountry getVideosByCountry,
  }) : _getVideos = getVideos,
       _getVideosByChannel = getVideosByChannel,
       _getVideosByCountry = getVideosByCountry,
       super(const VideosInitial()) {
    on<LoadVideos>(_onLoadVideos, transformer: restartable());
    on<RefreshVideos>(_onRefreshVideos, transformer: restartable());
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  final GetVideos _getVideos;
  final GetVideosByChannel _getVideosByChannel;
  final GetVideosByCountry _getVideosByCountry;

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosLoading());
    final result = await _getVideos(
      const GetVideosParams(channelIds: youtubeChannelIds),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _applyFiltersAndSort(
          VideosLoaded(
            videos: videos,
            filteredVideos: videos,
            selectedChannel: null,
            selectedCountry: null,
            sortBy: SortBy.publishedDate,
            sortOrder: SortOrder.descending,
            isRefreshing: false,
          ),
        ),
      ),
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
    final result = await _getVideos(
      const GetVideosParams(channelIds: youtubeChannelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _applyFiltersAndSort(
          current.copyWith(videos: videos, isRefreshing: false),
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

    if (event.channelName == null) {
      emit(_applyFiltersAndSort(current.copyWith(clearSelectedChannel: true)));
      return;
    }

    await _getVideosByChannel(GetVideosByChannelParams(event.channelName!));
    emit(_applyFiltersAndSort(current.copyWith(selectedChannel: event.channelName)));
  }

  Future<void> _onFilterByCountry(
    FilterByCountry event,
    Emitter<VideosState> emit,
  ) async {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }

    if (event.country == null) {
      emit(_applyFiltersAndSort(current.copyWith(clearSelectedCountry: true)));
      return;
    }

    await _getVideosByCountry(GetVideosByCountryParams(event.country!));
    emit(_applyFiltersAndSort(current.copyWith(selectedCountry: event.country)));
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
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

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    final current = state;
    if (current is! VideosLoaded) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        current.copyWith(
          clearSelectedChannel: true,
          clearSelectedCountry: true,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
        ),
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

    filtered.sort((a, b) {
      final left = state.sortBy == SortBy.publishedDate
          ? a.publishedAt
          : (a.recordingDate ?? DateTime(1970));
      final right = state.sortBy == SortBy.publishedDate
          ? b.publishedAt
          : (b.recordingDate ?? DateTime(1970));
      return state.sortOrder == SortOrder.descending
          ? right.compareTo(left)
          : left.compareTo(right);
    });

    return state.copyWith(filteredVideos: filtered, isRefreshing: false);
  }
}
