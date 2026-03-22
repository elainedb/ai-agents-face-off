import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video.dart';
import '../../domain/usecases/clear_cache.dart';
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

class VideosLoaded extends VideosState {
  const VideosLoaded({
    required this.videos,
    required this.filteredVideos,
    this.selectedChannel,
    this.selectedCountry,
    this.sortBy = SortBy.publishedDate,
    this.sortOrder = SortOrder.descending,
    this.isRefreshing = false,
  });

  final List<Video> videos;
  final List<Video> filteredVideos;
  final String? selectedChannel;
  final String? selectedCountry;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isRefreshing;

  List<String> get availableChannels =>
      videos.map((video) => video.channelName).toSet().toList()..sort();

  List<String> get availableCountries =>
      videos
          .where((video) => video.country != null && video.country!.isNotEmpty)
          .map((video) => video.country!)
          .toSet()
          .toList()
        ..sort();

  VideosLoaded copyWith({
    List<Video>? videos,
    List<Video>? filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    bool clearSelectedChannel = false,
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

class VideosError extends VideosState {
  const VideosError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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

  static const List<String> _channelIds = [
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
      const GetVideosParams(channelIds: _channelIds),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _applyFiltersAndSort(
          VideosLoaded(videos: videos, filteredVideos: videos),
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
    final result = await getVideos(
      const GetVideosParams(channelIds: _channelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _applyFiltersAndSort(
          current.copyWith(
            videos: videos,
            filteredVideos: videos,
            isRefreshing: false,
          ),
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
        current.copyWith(
          selectedChannel: event.channelName,
          clearSelectedChannel: event.channelName == null,
        ),
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
      _applyFiltersAndSort(
        current.copyWith(
          selectedCountry: event.country,
          clearSelectedCountry: event.country == null,
        ),
      ),
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
    var filtered = [...state.videos];

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

    _sortVideos(filtered, state.sortBy, state.sortOrder);

    return state.copyWith(filteredVideos: filtered, isRefreshing: false);
  }

  void _sortVideos(List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    videos.sort((a, b) {
      final left = sortBy == SortBy.publishedDate
          ? a.publishedAt
          : (a.recordingDate ?? DateTime(1970));
      final right = sortBy == SortBy.publishedDate
          ? b.publishedAt
          : (b.recordingDate ?? DateTime(1970));
      final comparison = left.compareTo(right);
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }
}
