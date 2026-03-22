import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/usecases/get_videos.dart';

part 'videos_event.dart';
part 'videos_state.dart';
part 'videos_bloc.freezed.dart';

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos getVideos;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc(this.getVideos) : super(const VideosState.initial()) {
    on<_LoadVideos>(_onLoadVideos);
    on<_RefreshVideos>(_onRefreshVideos);
    on<_FilterByChannel>(_onFilterByChannel);
    on<_FilterByCountry>(_onFilterByCountry);
    on<_SortVideos>(_onSortVideos);
    on<_ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(_LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideos(const GetVideosParams(channelIds: _channelIds));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(_applyFiltersAndSort(
        videos: videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      )),
    );
  }

  Future<void> _onRefreshVideos(_RefreshVideos event, Emitter<VideosState> emit) async {
    if (state is! VideosLoaded) return;
    final currentState = state as VideosLoaded;
    
    emit(currentState.copyWith(isRefreshing: true));
    
    final result = await getVideos(const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(_applyFiltersAndSort(
        videos: videos,
        selectedChannel: currentState.selectedChannel,
        selectedCountry: currentState.selectedCountry,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      )),
    );
  }

  void _onFilterByChannel(_FilterByChannel event, Emitter<VideosState> emit) {
    if (state is! VideosLoaded) return;
    final currentState = state as VideosLoaded;
    emit(_applyFiltersAndSort(
      videos: currentState.videos,
      selectedChannel: event.channelName,
      selectedCountry: currentState.selectedCountry,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
    ));
  }

  void _onFilterByCountry(_FilterByCountry event, Emitter<VideosState> emit) {
    if (state is! VideosLoaded) return;
    final currentState = state as VideosLoaded;
    emit(_applyFiltersAndSort(
      videos: currentState.videos,
      selectedChannel: currentState.selectedChannel,
      selectedCountry: event.country,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
    ));
  }

  void _onSortVideos(_SortVideos event, Emitter<VideosState> emit) {
    if (state is! VideosLoaded) return;
    final currentState = state as VideosLoaded;
    emit(_applyFiltersAndSort(
      videos: currentState.videos,
      selectedChannel: currentState.selectedChannel,
      selectedCountry: currentState.selectedCountry,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    ));
  }

  void _onClearFilters(_ClearFilters event, Emitter<VideosState> emit) {
    if (state is! VideosLoaded) return;
    final currentState = state as VideosLoaded;
    emit(_applyFiltersAndSort(
      videos: currentState.videos,
      selectedChannel: null,
      selectedCountry: null,
      sortBy: SortBy.publishedDate,
      sortOrder: SortOrder.descending,
    ));
  }

  VideosState _applyFiltersAndSort({
    required List<Video> videos,
    required String? selectedChannel,
    required String? selectedCountry,
    required SortBy sortBy,
    required SortOrder sortOrder,
  }) {
    var filtered = List<Video>.from(videos);

    if (selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == selectedChannel).toList();
    }

    if (selectedCountry != null) {
      filtered = filtered.where((v) => v.country == selectedCountry).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else if (sortBy == SortBy.recordingDate) {
        final aDate = a.recordingDate ?? DateTime(1970);
        final bDate = b.recordingDate ?? DateTime(1970);
        comparison = aDate.compareTo(bDate);
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return VideosState.loaded(
      videos: videos,
      filteredVideos: filtered,
      selectedChannel: selectedChannel,
      selectedCountry: selectedCountry,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isRefreshing: false,
    );
  }
}
