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
      await switch (event) {
        _LoadVideos() => _onLoadVideos(emit),
        _RefreshVideos() => _onRefreshVideos(emit),
        _FilterByChannel(:final channelName) =>
          _onFilterByChannel(channelName, emit),
        _FilterByCountry(:final country) =>
          _onFilterByCountry(country, emit),
        _SortVideos(:final sortBy, :final sortOrder) =>
          _onSortVideos(sortBy, sortOrder, emit),
        _ClearFilters() => _onClearFilters(emit),
      };
    });
  }

  List<String> get availableChannels {
    if (state case VideosLoaded(:final videos)) {
      return videos.map((v) => v.channelName).toSet().toList()..sort();
    }
    return [];
  }

  List<String> get availableCountries {
    if (state case VideosLoaded(:final videos)) {
      return videos
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
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: _sortVideosList(
            videos, SortBy.publishedDate, SortOrder.descending),
      )),
    );
  }

  Future<void> _onRefreshVideos(Emitter<VideosState> emit) async {
    String? selectedChannel;
    String? selectedCountry;
    SortBy sortBy = SortBy.publishedDate;
    SortOrder sortOrder = SortOrder.descending;

    if (state case VideosLoaded(
      selectedChannel: final sc,
      selectedCountry: final sco,
      sortBy: final sb,
      sortOrder: final so,
    )) {
      selectedChannel = sc;
      selectedCountry = sco;
      sortBy = sb;
      sortOrder = so;
      emit(VideosLoaded(
        videos: (state as VideosLoaded).videos,
        filteredVideos: (state as VideosLoaded).filteredVideos,
        selectedChannel: sc,
        selectedCountry: sco,
        sortBy: sb,
        sortOrder: so,
        isRefreshing: true,
      ));
    } else {
      emit(const VideosState.loading());
    }

    final result = await _getVideos(
        const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        final filtered = _applyFiltersAndSort(
            videos, selectedChannel, selectedCountry, sortBy, sortOrder);
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
      String? channelName, Emitter<VideosState> emit) async {
    if (state case VideosLoaded(
      :final videos,
      :final selectedCountry,
      :final sortBy,
      :final sortOrder,
    )) {
      final filtered = _applyFiltersAndSort(
          videos, channelName, selectedCountry, sortBy, sortOrder);
      emit(VideosLoaded(
        videos: videos,
        filteredVideos: filtered,
        selectedChannel: channelName,
        selectedCountry: selectedCountry,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    }
  }

  Future<void> _onFilterByCountry(
      String? country, Emitter<VideosState> emit) async {
    if (state case VideosLoaded(
      :final videos,
      :final selectedChannel,
      :final sortBy,
      :final sortOrder,
    )) {
      final filtered = _applyFiltersAndSort(
          videos, selectedChannel, country, sortBy, sortOrder);
      emit(VideosLoaded(
        videos: videos,
        filteredVideos: filtered,
        selectedChannel: selectedChannel,
        selectedCountry: country,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    }
  }

  Future<void> _onSortVideos(
      SortBy sortBy, SortOrder sortOrder, Emitter<VideosState> emit) async {
    if (state case VideosLoaded(
      :final videos,
      :final selectedChannel,
      :final selectedCountry,
    )) {
      final filtered = _applyFiltersAndSort(
          videos, selectedChannel, selectedCountry, sortBy, sortOrder);
      emit(VideosLoaded(
        videos: videos,
        filteredVideos: filtered,
        selectedChannel: selectedChannel,
        selectedCountry: selectedCountry,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    }
  }

  Future<void> _onClearFilters(Emitter<VideosState> emit) async {
    if (state case VideosLoaded(:final videos)) {
      emit(VideosState.loaded(
        videos: videos,
        filteredVideos: _sortVideosList(
            videos, SortBy.publishedDate, SortOrder.descending),
      ));
    }
  }

  List<Video> _applyFiltersAndSort(
    List<Video> videos,
    String? channelName,
    String? country,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    var filtered = videos.toList();
    if (channelName != null) {
      filtered =
          filtered.where((v) => v.channelName == channelName).toList();
    }
    if (country != null) {
      filtered = filtered.where((v) => v.country == country).toList();
    }
    return _sortVideosList(filtered, sortBy, sortOrder);
  }

  List<Video> _sortVideosList(
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
