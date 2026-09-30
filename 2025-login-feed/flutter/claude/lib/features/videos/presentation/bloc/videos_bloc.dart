import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/video.dart';
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
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(
    LoadVideos event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosState.loading());

    final result = await getVideos(const GetVideosParams(channelIds: _channelIds));

    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: videos,
      )),
    );
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideosState> emit,
  ) async {
    // Show refreshing state while maintaining existing data
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const VideosState.loading());
    }

    final result = await getVideos(const GetVideosParams(
      channelIds: _channelIds,
      forceRefresh: true,
    ));

    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        // Preserve existing filter/sort settings
        if (state is VideosLoaded) {
          final currentState = state as VideosLoaded;
          emit(_applyFiltersAndSort(
            videos: videos,
            selectedChannel: currentState.selectedChannel,
            selectedCountry: currentState.selectedCountry,
            sortBy: currentState.sortBy,
            sortOrder: currentState.sortOrder,
          ));
        } else {
          emit(VideosState.loaded(
            videos: videos,
            filteredVideos: videos,
          ));
        }
      },
    );
  }

  void _onFilterByChannel(
    FilterByChannel event,
    Emitter<VideosState> emit,
  ) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: event.channelName,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ));
    }
  }

  void _onFilterByCountry(
    FilterByCountry event,
    Emitter<VideosState> emit,
  ) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: event.country,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ));
    }
  }

  void _onSortVideos(
    SortVideos event,
    Emitter<VideosState> emit,
  ) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ));
    }
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<VideosState> emit,
  ) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(VideosState.loaded(
        videos: currentState.videos,
        filteredVideos: _sortVideos(
          currentState.videos,
          SortBy.publishedDate,
          SortOrder.descending,
        ),
      ));
    }
  }

  VideosLoaded _applyFiltersAndSort({
    required List<Video> videos,
    String? selectedChannel,
    String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    var filteredVideos = List<Video>.from(videos);

    // Apply channel filter
    if (selectedChannel != null) {
      filteredVideos = filteredVideos
          .where((video) => video.channelName == selectedChannel)
          .toList();
    }

    // Apply country filter
    if (selectedCountry != null) {
      filteredVideos = filteredVideos
          .where((video) => video.country == selectedCountry)
          .toList();
    }

    // Apply sorting
    filteredVideos = _sortVideos(filteredVideos, sortBy, sortOrder);

    return VideosLoaded(
      videos: videos,
      filteredVideos: filteredVideos,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  List<Video> _sortVideos(List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sortedVideos = List<Video>.from(videos);

    switch (sortBy) {
      case SortBy.publishedDate:
        sortedVideos.sort((a, b) {
          final comparison = a.publishedAt.compareTo(b.publishedAt);
          return sortOrder == SortOrder.ascending ? comparison : -comparison;
        });
        break;
      case SortBy.recordingDate:
        sortedVideos.sort((a, b) {
          // Handle null recording dates by treating them as older
          final aDate = a.recordingDate ?? DateTime(1970);
          final bDate = b.recordingDate ?? DateTime(1970);
          final comparison = aDate.compareTo(bDate);
          return sortOrder == SortOrder.ascending ? comparison : -comparison;
        });
        break;
    }

    return sortedVideos;
  }

  // Helper method to get unique channel names
  List<String> get availableChannels {
    if (state is VideosLoaded) {
      final loadedState = state as VideosLoaded;
      return loadedState.videos
          .map((video) => video.channelName)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  // Helper method to get unique countries
  List<String> get availableCountries {
    if (state is VideosLoaded) {
      final loadedState = state as VideosLoaded;
      return loadedState.videos
          .where((video) => video.country != null)
          .map((video) => video.country!)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }
}