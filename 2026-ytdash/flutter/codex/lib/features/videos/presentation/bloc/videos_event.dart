import 'package:equatable/equatable.dart';

import 'videos_state.dart';

abstract class VideosEvent extends Equatable {
  const VideosEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideosEvent {
  const LoadVideos();
}

class RefreshVideos extends VideosEvent {
  const RefreshVideos();
}

class FilterByChannel extends VideosEvent {
  const FilterByChannel(this.channelName);

  final String? channelName;

  @override
  List<Object?> get props => [channelName];
}

class FilterByCountry extends VideosEvent {
  const FilterByCountry(this.country);

  final String? country;

  @override
  List<Object?> get props => [country];
}

class SortVideos extends VideosEvent {
  const SortVideos(this.sortBy, this.sortOrder);

  final SortBy sortBy;
  final SortOrder sortOrder;

  @override
  List<Object?> get props => [sortBy, sortOrder];
}

class ClearFilters extends VideosEvent {
  const ClearFilters();
}
