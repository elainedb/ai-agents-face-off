import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_event.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_state.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos _getVideos;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc({required GetVideos getVideos})
      : _getVideos = getVideos,
        super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideosEvent>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(
      LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await _getVideos(
      GetVideosParams(channelIds: _channelIds),
    );
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: videos,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      )),
    );
  }

  Future<void> _onRefreshVideos(
      RefreshVideos event, Emitter<VideosState> emit) async {
    final currentState = state;
    String? selectedChannel;
    String? selectedCountry;
    SortBy sortBy = SortBy.publishedDate;
    SortOrder sortOrder = SortOrder.descending;

    if (currentState is VideosLoaded) {
      selectedChannel = currentState.selectedChannel;
      selectedCountry = currentState.selectedCountry;
      sortBy = currentState.sortBy;
      sortOrder = currentState.sortOrder;

      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const VideosState.loading());
    }

    final result = await _getVideos(
      GetVideosParams(channelIds: _channelIds, forceRefresh: true),
    );

    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        final loaded = VideosState.loaded(
          videos: videos,
          filteredVideos: videos,
          selectedChannel: selectedChannel,
          selectedCountry: selectedCountry,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ) as VideosLoaded;
        emit(_applyFiltersAndSort(loaded));
      },
    );
  }

  void _onFilterByChannel(
      FilterByChannel event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final updated =
          currentState.copyWith(selectedChannel: event.channelName);
      emit(_applyFiltersAndSort(updated));
    }
  }

  void _onFilterByCountry(
      FilterByCountry event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final updated =
          currentState.copyWith(selectedCountry: event.country);
      emit(_applyFiltersAndSort(updated));
    }
  }

  void _onSortVideos(
      SortVideosEvent event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final updated = currentState.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      emit(_applyFiltersAndSort(updated));
    }
  }

  void _onClearFilters(
      ClearFilters event, Emitter<VideosState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final updated = currentState.copyWith(
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      );
      emit(_applyFiltersAndSort(updated));
    }
  }

  VideosLoaded _applyFiltersAndSort(VideosLoaded state) {
    var filtered = state.videos.toList();

    if (state.selectedChannel != null) {
      filtered = filtered
          .where((v) => v.channelName == state.selectedChannel)
          .toList();
    }

    if (state.selectedCountry != null) {
      filtered =
          filtered.where((v) => v.country == state.selectedCountry).toList();
    }

    filtered = _sortVideos(filtered, state.sortBy, state.sortOrder);

    return state.copyWith(filteredVideos: filtered);
  }

  List<Video> _sortVideos(
      List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sorted = videos.toList();
    sorted.sort((a, b) {
      int comparison;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else {
        final aDate = a.recordingDate ?? DateTime(1970);
        final bDate = b.recordingDate ?? DateTime(1970);
        comparison = aDate.compareTo(bDate);
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    return sorted;
  }

  List<String> get availableChannels {
    final currentState = state;
    if (currentState is VideosLoaded) {
      return currentState.videos
          .map((v) => v.channelName)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  List<String> get availableCountries {
    final currentState = state;
    if (currentState is VideosLoaded) {
      return currentState.videos
          .where((v) => v.country != null && v.country!.isNotEmpty)
          .map((v) => v.country!)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }
}
