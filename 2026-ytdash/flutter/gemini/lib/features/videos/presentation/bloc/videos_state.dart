part of 'videos_bloc.dart';

@freezed
class VideosState with _$VideosState {
  const factory VideosState.initial() = _Initial;
  const factory VideosState.loading() = _Loading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
    required bool isRefreshing,
  }) = _Loaded;
  const factory VideosState.error(String message) = _Error;
}

extension VideosStateX on VideosState {
  List<String> get availableChannels {
    return map(
      initial: (_) => [],
      loading: (_) => [],
      error: (_) => [],
      loaded: (state) {
        final channels = state.videos.map((v) => v.channelName).toSet().toList();
        channels.sort();
        return channels;
      },
    );
  }

  List<String> get availableCountries {
    return map(
      initial: (_) => [],
      loading: (_) => [],
      error: (_) => [],
      loaded: (state) {
        final countries = state.videos
            .where((v) => v.country != null)
            .map((v) => v.country!)
            .toSet()
            .toList();
        countries.sort();
        return countries;
      },
    );
  }
}
