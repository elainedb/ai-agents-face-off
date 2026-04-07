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
      await event.when(
        loadVideos: () => _onLoadVideos(emit),
        refreshVideos: () => _onRefreshVideos(emit),
        filterByChannel: (channelName) =>
            _onFilterByChannel(emit, channelName),
        filterByCountry: (country) => _onFilterByCountry(emit, country),
        sortVideos: (sortBy, sortOrder) =>
            _onSortVideos(emit, sortBy, sortOrder),
        clearFilters: () => _onClearFilters(emit),
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
      const GetVideosParams(channelIds: _channelIds),
    );
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: _sortVideos(videos, SortBy.publishedDate,
            SortOrder.descending),
      )),
    );
  }

  Future<void> _onRefreshVideos(Emitter<VideosState> emit) async {
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
      const GetVideosParams(channelIds: _channelIds, forceRefresh: true),
    );
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        final filtered = _applyFiltersAndSort(
          videos,
          selectedChannel,
          selectedCountry,
          sortBy,
          sortOrder,
        );
        emit(VideosState.loaded(
          videos: videos,
          filteredVideos: filtered,
          selectedChannel: selectedChannel,
          selectedCountry: selectedCountry,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ));
      },
    );
  }

  Future<void> _onFilterByChannel(
      Emitter<VideosState> emit, String? channelName) async {
    final currentState = state;
    if (currentState is! VideosLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.videos,
      channelName,
      currentState.selectedCountry,
      currentState.sortBy,
      currentState.sortOrder,
    );
    emit(currentState.copyWith(
      filteredVideos: filtered,
      selectedChannel: channelName,
    ));
  }

  Future<void> _onFilterByCountry(
      Emitter<VideosState> emit, String? country) async {
    final currentState = state;
    if (currentState is! VideosLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.videos,
      currentState.selectedChannel,
      country,
      currentState.sortBy,
      currentState.sortOrder,
    );
    emit(currentState.copyWith(
      filteredVideos: filtered,
      selectedCountry: country,
    ));
  }

  Future<void> _onSortVideos(
      Emitter<VideosState> emit, SortBy sortBy, SortOrder sortOrder) async {
    final currentState = state;
    if (currentState is! VideosLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.videos,
      currentState.selectedChannel,
      currentState.selectedCountry,
      sortBy,
      sortOrder,
    );
    emit(currentState.copyWith(
      filteredVideos: filtered,
      sortBy: sortBy,
      sortOrder: sortOrder,
    ));
  }

  Future<void> _onClearFilters(Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is! VideosLoaded) return;

    emit(currentState.copyWith(
      filteredVideos: _sortVideos(
          currentState.videos, SortBy.publishedDate, SortOrder.descending),
      selectedChannel: null,
      selectedCountry: null,
      sortBy: SortBy.publishedDate,
      sortOrder: SortOrder.descending,
    ));
  }

  List<Video> _applyFiltersAndSort(
    List<Video> videos,
    String? channelName,
    String? country,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    var filtered = List<Video>.from(videos);

    if (channelName != null) {
      filtered =
          filtered.where((v) => v.channelName == channelName).toList();
    }

    if (country != null) {
      filtered = filtered.where((v) => v.country == country).toList();
    }

    return _sortVideos(filtered, sortBy, sortOrder);
  }

  List<Video> _sortVideos(
      List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sorted = List<Video>.from(videos);
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
