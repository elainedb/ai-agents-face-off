part of 'videos_bloc.dart';

enum SortBy { publishedDate, recordingDate }
enum SortOrder { ascending, descending }

@freezed
class VideosState with _$VideosState {
  const VideosState._();

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

  List<String> get availableChannels {
    if (this is! VideosLoaded) return [];
    final loadedState = this as VideosLoaded;
    return loadedState.videos.map((v) => v.channelName).toSet().toList()..sort();
  }

  List<String> get availableCountries {
    if (this is! VideosLoaded) return [];
    final loadedState = this as VideosLoaded;
    return loadedState.videos
        .where((v) => v.country != null)
        .map((v) => v.country!)
        .toSet()
        .toList()..sort();
  }
}
