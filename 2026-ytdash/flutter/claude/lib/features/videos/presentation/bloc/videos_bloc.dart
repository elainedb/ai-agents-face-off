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
        loadVideos: (_) async {
          emit(const VideosState.loading());
          final result = await _getVideos(
              const GetVideosParams(channelIds: _channelIds));
          result.fold(
            (failure) => emit(VideosState.error(failure.message)),
            (videos) => emit(_applyFiltersAndSort(
              videos: videos,
              filteredVideos: videos,
              selectedChannel: null,
              selectedCountry: null,
              sortBy: SortBy.publishedDate,
              sortOrder: SortOrder.descending,
            )),
          );
        },
        refreshVideos: (_) async {
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
          } else {
            emit(const VideosState.loading());
          }

          final result = await _getVideos(
              const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
          result.fold(
            (failure) => emit(VideosState.error(failure.message)),
            (videos) => emit(_applyFiltersAndSort(
              videos: videos,
              filteredVideos: videos,
              selectedChannel: channel,
              selectedCountry: country,
              sortBy: sortBy,
              sortOrder: sortOrder,
            )),
          );
        },
        filterByChannel: (e) async {
          final currentState = state;
          if (currentState is VideosLoaded) {
            emit(_applyFiltersAndSort(
              videos: currentState.videos,
              filteredVideos: currentState.videos,
              selectedChannel: e.channelName,
              selectedCountry: currentState.selectedCountry,
              sortBy: currentState.sortBy,
              sortOrder: currentState.sortOrder,
            ));
          }
        },
        filterByCountry: (e) async {
          final currentState = state;
          if (currentState is VideosLoaded) {
            emit(_applyFiltersAndSort(
              videos: currentState.videos,
              filteredVideos: currentState.videos,
              selectedChannel: currentState.selectedChannel,
              selectedCountry: e.country,
              sortBy: currentState.sortBy,
              sortOrder: currentState.sortOrder,
            ));
          }
        },
        sortVideos: (e) async {
          final currentState = state;
          if (currentState is VideosLoaded) {
            emit(_applyFiltersAndSort(
              videos: currentState.videos,
              filteredVideos: currentState.videos,
              selectedChannel: currentState.selectedChannel,
              selectedCountry: currentState.selectedCountry,
              sortBy: e.sortBy,
              sortOrder: e.sortOrder,
            ));
          }
        },
        clearFilters: (_) async {
          final currentState = state;
          if (currentState is VideosLoaded) {
            emit(_applyFiltersAndSort(
              videos: currentState.videos,
              filteredVideos: currentState.videos,
              selectedChannel: null,
              selectedCountry: null,
              sortBy: SortBy.publishedDate,
              sortOrder: SortOrder.descending,
            ));
          }
        },
      );
    });
  }

  VideosLoaded _applyFiltersAndSort({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    var result = List<Video>.from(videos);

    if (selectedChannel != null) {
      result = result.where((v) => v.channelName == selectedChannel).toList();
    }

    if (selectedCountry != null) {
      result = result.where((v) => v.country == selectedCountry).toList();
    }

    result = _sortVideos(result, sortBy, sortOrder);

    return VideosLoaded(
      videos: videos,
      filteredVideos: result,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  List<Video> _sortVideos(
      List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sorted = List<Video>.from(videos);
    sorted.sort((a, b) {
      final dateA = sortBy == SortBy.publishedDate
          ? a.publishedAt
          : (a.recordingDate ?? DateTime(1970));
      final dateB = sortBy == SortBy.publishedDate
          ? b.publishedAt
          : (b.recordingDate ?? DateTime(1970));
      return sortOrder == SortOrder.descending
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
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
