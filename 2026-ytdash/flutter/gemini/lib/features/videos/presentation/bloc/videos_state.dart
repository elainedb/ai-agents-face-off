part of 'videos_bloc.dart';

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

extension VideosStateX on VideosState {
  List<String> get availableChannels {
    return maybeMap(
      loaded: (state) {
        final channels = state.videos.map((v) => v.channelName).toSet().toList();
        channels.sort();
        return channels;
      },
      orElse: () => [],
    );
  }

  List<String> get availableCountries {
    return maybeMap(
      loaded: (state) {
        final countries = state.videos.where((v) => v.country != null).map((v) => v.country!).toSet().toList();
        countries.sort();
        return countries;
      },
      orElse: () => [],
    );
  }
}
