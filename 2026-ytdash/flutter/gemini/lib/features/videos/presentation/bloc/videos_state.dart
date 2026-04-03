import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/video.dart';
import 'videos_event.dart';

part 'videos_state.freezed.dart';

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
  }) = VideosLoaded;
  const factory VideosState.error(String message) = _Error;

  List<String> get availableChannels {
    if (this is! VideosLoaded) return [];
    final v = (this as VideosLoaded).videos;
    return v.map((e) => e.channelName).toSet().toList()..sort();
  }

  List<String> get availableCountries {
    if (this is! VideosLoaded) return [];
    final v = (this as VideosLoaded).videos;
    return v.where((e) => e.country != null).map((e) => e.country!).toSet().toList()..sort();
  }
}
