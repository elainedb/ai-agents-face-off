import 'package:equatable/equatable.dart';

import '../../domain/entities/video.dart';

enum SortBy { publishedDate, recordingDate }

enum SortOrder { ascending, descending }

abstract class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosLoaded extends VideosState {
  const VideosLoaded({
    required this.videos,
    required this.filteredVideos,
    required this.selectedChannel,
    required this.selectedCountry,
    required this.sortBy,
    required this.sortOrder,
    required this.isRefreshing,
  });

  final List<Video> videos;
  final List<Video> filteredVideos;
  final String? selectedChannel;
  final String? selectedCountry;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final bool isRefreshing;

  List<String> get availableChannels =>
      videos.map((video) => video.channelName).toSet().toList()..sort();

  List<String> get availableCountries =>
      videos
          .where((video) => video.country != null && video.country!.isNotEmpty)
          .map((video) => video.country!)
          .toSet()
          .toList()
        ..sort();

  bool get hasActiveFilters =>
      selectedChannel != null ||
      selectedCountry != null ||
      sortBy != SortBy.publishedDate ||
      sortOrder != SortOrder.descending;

  VideosLoaded copyWith({
    List<Video>? videos,
    List<Video>? filteredVideos,
    Object? selectedChannel = _sentinel,
    Object? selectedCountry = _sentinel,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool? isRefreshing,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      filteredVideos: filteredVideos ?? this.filteredVideos,
      selectedChannel: identical(selectedChannel, _sentinel)
          ? this.selectedChannel
          : selectedChannel as String?,
      selectedCountry: identical(selectedCountry, _sentinel)
          ? this.selectedCountry
          : selectedCountry as String?,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    videos,
    filteredVideos,
    selectedChannel,
    selectedCountry,
    sortBy,
    sortOrder,
    isRefreshing,
  ];
}

class VideosError extends VideosState {
  const VideosError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

const _sentinel = Object();
