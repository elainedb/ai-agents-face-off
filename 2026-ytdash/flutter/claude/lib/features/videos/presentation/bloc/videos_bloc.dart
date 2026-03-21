import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos.dart';

part 'videos_bloc.freezed.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

@freezed
sealed class VideosEvent with _$VideosEvent {
  const factory VideosEvent.loadVideos() = _LoadVideos;
  const factory VideosEvent.refreshVideos() = _RefreshVideos;
  const factory VideosEvent.filterByChannel(String? channelName) =
      _FilterByChannel;
  const factory VideosEvent.filterByCountry(String? country) =
      _FilterByCountry;
  const factory VideosEvent.sortVideos(SortBy sortBy, SortOrder sortOrder) =
      _SortVideos;
  const factory VideosEvent.clearFilters() = _ClearFilters;
}

@freezed
sealed class VideosState with _$VideosState {
  const factory VideosState.initial() = _Initial;
  const factory VideosState.loading() = _Loading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    @Default(SortBy.publishedDate) SortBy sortBy,
    @Default(SortOrder.descending) SortOrder sortOrder,
    @Default(false) bool isRefreshing,
  }) = VideosLoaded;
  const factory VideosState.error(String message) = _Error;
}

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
    on<VideosEvent>((event, emit) async {
      await event.map(
        loadVideos: (_) => _onLoadVideos(emit),
        refreshVideos: (_) => _onRefreshVideos(emit),
        filterByChannel: (e) => _onFilterByChannel(e.channelName, emit),
        filterByCountry: (e) => _onFilterByCountry(e.country, emit),
        sortVideos: (e) => _onSortVideos(e.sortBy, e.sortOrder, emit),
        clearFilters: (_) => _onClearFilters(emit),
      );
    });
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
          .where((v) => v.country != null)
          .map((v) => v.country!)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  Future<void> _onLoadVideos(Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await _getVideos(
        const GetVideosParams(channelIds: _channelIds));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        final sorted = _sortVideos(
            videos, SortBy.publishedDate, SortOrder.descending);
        emit(VideosState.loaded(
          videos: videos,
          filteredVideos: sorted,
        ));
      },
    );
  }

  Future<void> _onRefreshVideos(Emitter<VideosState> emit) async {
    final currentState = state;
    String? channel;
    String? country;
    SortBy sortBy = SortBy.publishedDate;
    SortOrder sortOrder = SortOrder.descending;

    if (currentState is VideosLoaded) {
      channel = currentState.selectedChannel;
      country = currentState.selectedCountry;
      sortBy = currentState.sortBy;
      sortOrder = currentState.sortOrder;
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _getVideos(
        const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        emit(_applyFiltersAndSort(
          videos: videos,
          selectedChannel: channel,
          selectedCountry: country,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ));
      },
    );
  }

  Future<void> _onFilterByChannel(
      String? channelName, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: channelName,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ));
    }
  }

  Future<void> _onFilterByCountry(
      String? country, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: country,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ));
    }
  }

  Future<void> _onSortVideos(
      SortBy sortBy, SortOrder sortOrder, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    }
  }

  Future<void> _onClearFilters(Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(_applyFiltersAndSort(
        videos: currentState.videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
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
    var filtered = videos.toList();

    if (selectedChannel != null) {
      filtered =
          filtered.where((v) => v.channelName == selectedChannel).toList();
    }

    if (selectedCountry != null) {
      filtered =
          filtered.where((v) => v.country == selectedCountry).toList();
    }

    filtered = _sortVideos(filtered, sortBy, sortOrder);

    return VideosLoaded(
      videos: videos,
      filteredVideos: filtered,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  List<Video> _sortVideos(
      List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sorted = videos.toList();
    sorted.sort((a, b) {
      final DateTime dateA;
      final DateTime dateB;

      if (sortBy == SortBy.recordingDate) {
        dateA = a.recordingDate ?? DateTime(1970);
        dateB = b.recordingDate ?? DateTime(1970);
      } else {
        dateA = a.publishedAt;
        dateB = b.publishedAt;
      }

      return sortOrder == SortOrder.descending
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    return sorted;
  }
}
