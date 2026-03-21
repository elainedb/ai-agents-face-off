import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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

  VideosBloc(this.getVideos) : super(const VideosState.initial()) {
    on<VideosEvent>((event, emit) async {
      await event.map(
        loadVideos: (e) => _onLoadVideos(emit),
        refreshVideos: (e) => _onRefreshVideos(emit),
        filterByChannel: (e) => _onFilterByChannel(e.channelName, emit),
        filterByCountry: (e) => _onFilterByCountry(e.country, emit),
        sortVideos: (e) => _onSortVideos(e.sortBy, e.sortOrder, emit),
        clearFilters: (e) => _onClearFilters(emit),
      );
    }, transformer: sequential());
  }

  Future<void> _onLoadVideos(Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideos(GetVideosParams(_channelIds, forceRefresh: false));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(_applyFiltersAndSort(
        videos: videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      )),
    );
  }

  Future<void> _onRefreshVideos(Emitter<VideosState> emit) async {
    await state.maybeMap(
      loaded: (currentState) async {
        emit(currentState.copyWith(isRefreshing: true));
        final result = await getVideos(GetVideosParams(_channelIds, forceRefresh: true));

        result.fold(
          (failure) => emit(VideosState.error(failure.message)),
          (videos) => emit(_applyFiltersAndSort(
            videos: videos,
            selectedChannel: currentState.selectedChannel,
            selectedCountry: currentState.selectedCountry,
            sortBy: currentState.sortBy,
            sortOrder: currentState.sortOrder,
          )),
        );
      },
      orElse: () async {},
    );
  }

  Future<void> _onFilterByChannel(String? channelName, Emitter<VideosState> emit) async {
    state.maybeMap(
      loaded: (currentState) {
        emit(_applyFiltersAndSort(
          videos: currentState.videos,
          selectedChannel: channelName,
          selectedCountry: currentState.selectedCountry,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onFilterByCountry(String? country, Emitter<VideosState> emit) async {
    state.maybeMap(
      loaded: (currentState) {
        emit(_applyFiltersAndSort(
          videos: currentState.videos,
          selectedChannel: currentState.selectedChannel,
          selectedCountry: country,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onSortVideos(SortBy sortBy, SortOrder sortOrder, Emitter<VideosState> emit) async {
    state.maybeMap(
      loaded: (currentState) {
        emit(_applyFiltersAndSort(
          videos: currentState.videos,
          selectedChannel: currentState.selectedChannel,
          selectedCountry: currentState.selectedCountry,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onClearFilters(Emitter<VideosState> emit) async {
    state.maybeMap(
      loaded: (currentState) {
        emit(_applyFiltersAndSort(
          videos: currentState.videos,
          selectedChannel: null,
          selectedCountry: null,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
        ));
      },
      orElse: () {},
    );
  }

  VideosState _applyFiltersAndSort({
    required List<Video> videos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    List<Video> filtered = List.from(videos);

    if (selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == selectedChannel).toList();
    }

    if (selectedCountry != null) {
      filtered = filtered.where((v) => v.country == selectedCountry).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case SortBy.publishedDate:
          comparison = a.publishedAt.compareTo(b.publishedAt);
          break;
        case SortBy.recordingDate:
          final dateA = a.recordingDate ?? DateTime(1970);
          final dateB = b.recordingDate ?? DateTime(1970);
          comparison = dateA.compareTo(dateB);
          break;
      }

      return sortOrder == SortOrder.descending ? -comparison : comparison;
    });

    return VideosState.loaded(
      videos: videos,
      filteredVideos: filtered,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: false,
    );
  }
}
