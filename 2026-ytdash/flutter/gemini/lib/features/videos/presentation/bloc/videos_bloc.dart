import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';

part 'videos_event.dart';
part 'videos_state.dart';
part 'videos_bloc.freezed.dart';

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos getVideosUseCase;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc({required this.getVideosUseCase}) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideosUseCase(const GetVideosParams(channelIds: _channelIds));
    
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: videos,
      )),
    );
  }

  Future<void> _onRefreshVideos(RefreshVideos event, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is VideosLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
      
      final result = await getVideosUseCase(const GetVideosParams(
        channelIds: _channelIds,
        forceRefresh: true,
      ));
      
      result.fold(
        (failure) => emit(VideosState.error(failure.message)),
        (videos) {
          final newState = currentState.copyWith(
            videos: videos,
            isRefreshing: false,
          );
          _applyFiltersAndSort(newState, emit);
        },
      );
    }
  }

  void _onFilterByChannel(FilterByChannel event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      final newState = currentState.copyWith(selectedChannel: event.channelName);
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onFilterByCountry(FilterByCountry event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      final newState = currentState.copyWith(selectedCountry: event.country);
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      final newState = currentState.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      final newState = currentState.copyWith(
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      );
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _applyFiltersAndSort(VideosLoaded state, Emitter<VideosState> emit) {
    var filtered = state.videos;

    if (state.selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == state.selectedChannel).toList();
    }

    if (state.selectedCountry != null) {
      filtered = filtered.where((v) => v.country == state.selectedCountry).toList();
    }

    filtered = _sortVideos(filtered, state.sortBy, state.sortOrder);

    emit(state.copyWith(filteredVideos: filtered));
  }

  List<Video> _sortVideos(List<Video> videos, SortBy sortBy, SortOrder sortOrder) {
    final sorted = List<Video>.from(videos);
    
    sorted.sort((a, b) {
      int comparison;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else {
        final aDate = a.recordingDate ?? DateTime(1970);
        final bDate = b.recordingDate ?? DateTime(1970);
        comparison = aDate.compareTo(bDate);
      }
      
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return sorted;
  }
}
