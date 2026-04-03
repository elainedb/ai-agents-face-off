part of 'videos_bloc.dart';

@freezed
class VideosState with _$VideosState {
  const factory VideosState.initial() = _Initial;
  const factory VideosState.loading() = _Loading;
  const factory VideosState.loaded({
    required List<Video> videos,
    required List<Video> filteredVideos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
    required bool isRefreshing,
  }) = _Loaded;
  const factory VideosState.error(String message) = _Error;
}

extension VideosStateX on VideosState {
  List<String> get availableChannels {
    return maybeWhen(
      loaded: (videos, _, __, ___, ____, _____, ______) {
        final channels = videos.map((v) => v.channelName).toSet().toList();
        channels.sort();
        return channels;
      },
      orElse: () => [],
    );
  }

  List<String> get availableCountries {
    return maybeWhen(
      loaded: (videos, _, __, ___, ____, _____, ______) {
        final countries = videos.map((v) => v.country).whereType<String>().toSet().toList();
        countries.sort();
        return countries;
      },
      orElse: () => [],
    );
  }
}