import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/video.dart';

part 'videos_state.freezed.dart';

enum SortBy { publishedDate, recordingDate }
enum SortOrder { ascending, descending }

@freezed
class VideosState with _$VideosState {
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
