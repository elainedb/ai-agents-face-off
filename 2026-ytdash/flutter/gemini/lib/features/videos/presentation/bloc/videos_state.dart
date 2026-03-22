part of 'videos_bloc.dart';

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
    required SortBy sortBy,
    required SortOrder sortOrder,
    @Default(false) bool isRefreshing,
  }) = Loaded;
  const factory VideosState.error(String message) = _Error;

  List<String> get availableChannels {
    return maybeWhen(
      loaded: (videos, _, __, ___, ____, _____, ______) =>
          videos.map((v) => v.channelName).toSet().toList()..sort(),
      orElse: () => [],
    );
  }

  List<String> get availableCountries {
    return maybeWhen(
      loaded: (videos, _, __, ___, ____, _____, ______) => videos
          .where((v) => v.country != null)
          .map((v) => v.country!)
          .toSet()
          .toList()
        ..sort(),
      orElse: () => [],
    );
  }
}
