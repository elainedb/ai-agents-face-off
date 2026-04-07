import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/clear_cache.dart';
import '../../domain/usecases/get_videos.dart';
import '../../domain/usecases/get_videos_by_channel.dart';
import '../../domain/usecases/get_videos_by_country.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

sealed class VideosEvent {
  const VideosEvent();
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
}

class FilterByCountry extends VideosEvent {
  const FilterByCountry(this.country);

  final String? country;
}

class SortVideos extends VideosEvent {
  const SortVideos(this.sortBy, this.sortOrder);

  final SortBy sortBy;
  final SortOrder sortOrder;
}

class ClearFilters extends VideosEvent {
  const ClearFilters();
}

sealed class VideosState {
  const VideosState();
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

  List<String> get availableChannels =>
      videos.map((Video video) => video.channelName).toSet().toList()..sort();

  List<String> get availableCountries =>
      videos
          .where((Video video) => (video.country ?? '').isNotEmpty)
          .map((Video video) => video.country!)
          .toSet()
          .toList()
        ..sort();

  bool get hasActiveFilters =>
      selectedChannel != null ||
      selectedCountry != null ||
      sortBy != SortBy.publishedDate ||
      sortOrder != SortOrder.descending;

  VideosLoaded copyWith({
    List<Video>? videos,
    List<Video>? filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? isRefreshing,
    bool clearChannel = false,
    bool clearCountry = false,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      filteredVideos: filteredVideos ?? this.filteredVideos,
      selectedChannel: clearChannel
          ? null
          : selectedChannel ?? this.selectedChannel,
      selectedCountry: clearCountry
          ? null
          : selectedCountry ?? this.selectedCountry,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class VideosError extends VideosState {
  const VideosError(this.message);

  final String message;
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

  static const List<String> _channelIds = <String>[
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
          videos: videos,
          selectedChannel: null,
          selectedCountry: null,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    final VideosLoaded? current = state is VideosLoaded
        ? state as VideosLoaded
        : null;
    if (current != null) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const VideosLoading());
    }

    await clearCache(const NoParams());
    final result = await getVideos(
      const GetVideosParams(channelIds: _channelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosError(failure.message)),
      (videos) => emit(
        _applyFiltersAndSort(
          videos: videos,
          selectedChannel: current?.selectedChannel,
          selectedCountry: current?.selectedCountry,
          sortBy: current?.sortBy ?? SortBy.publishedDate,
          sortOrder: current?.sortOrder ?? SortOrder.descending,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> _onFilterByChannel(
    FilterByChannel event,
    Emitter<VideosState> emit,
  ) async {
    final VideosLoaded? current = state is VideosLoaded
        ? state as VideosLoaded
        : null;
    if (current == null) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        videos: current.videos,
        selectedChannel: event.channelName,
        selectedCountry: current.selectedCountry,
        sortBy: current.sortBy,
        sortOrder: current.sortOrder,
        isRefreshing: false,
      ),
    );
  }

  Future<void> _onFilterByCountry(
    FilterByCountry event,
    Emitter<VideosState> emit,
  ) async {
    final VideosLoaded? current = state is VideosLoaded
        ? state as VideosLoaded
        : null;
    if (current == null) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        videos: current.videos,
        selectedChannel: current.selectedChannel,
        selectedCountry: event.country,
        sortBy: current.sortBy,
        sortOrder: current.sortOrder,
        isRefreshing: false,
      ),
    );
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
    final VideosLoaded? current = state is VideosLoaded
        ? state as VideosLoaded
        : null;
    if (current == null) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        videos: current.videos,
        selectedChannel: current.selectedChannel,
        selectedCountry: current.selectedCountry,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        isRefreshing: false,
      ),
    );
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    final VideosLoaded? current = state is VideosLoaded
        ? state as VideosLoaded
        : null;
    if (current == null) {
      return;
    }
    emit(
      _applyFiltersAndSort(
        videos: current.videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
        isRefreshing: false,
      ),
    );
  }

  VideosLoaded _applyFiltersAndSort({
    required List<Video> videos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
    required bool isRefreshing,
  }) {
    Iterable<Video> filtered = videos;

    if (selectedChannel != null) {
      filtered = filtered.where(
        (Video video) => video.channelName == selectedChannel,
      );
    }
    if (selectedCountry != null) {
      filtered = filtered.where(
        (Video video) => video.country == selectedCountry,
      );
    }

    final List<Video> sorted = filtered.toList()
      ..sort((Video a, Video b) => _compareVideos(a, b, sortBy, sortOrder));

    return VideosLoaded(
      videos: videos,
      filteredVideos: sorted,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: isRefreshing,
    );
  }

  int _compareVideos(Video a, Video b, SortBy sortBy, SortOrder sortOrder) {
    final DateTime left = sortBy == SortBy.publishedDate
        ? a.publishedAt
        : (a.recordingDate ?? DateTime(1970));
    final DateTime right = sortBy == SortBy.publishedDate
        ? b.publishedAt
        : (b.recordingDate ?? DateTime(1970));

    final int comparison = left.compareTo(right);
    return sortOrder == SortOrder.ascending ? comparison : -comparison;
  }
}
