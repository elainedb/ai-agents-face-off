import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';

part 'videos_bloc.freezed.dart';
part 'videos_event.dart';
part 'videos_state.dart';

enum SortBy { publishedDate, recordingDate }
enum SortOrder { ascending, descending }

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
    on<_LoadVideos>(_onLoadVideos);
    on<_RefreshVideos>(_onRefreshVideos);
    on<_FilterByChannel>(_onFilterByChannel);
    on<_FilterByCountry>(_onFilterByCountry);
    on<_SortVideos>(_onSortVideos);
    on<_ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(_LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideosUseCase(const GetVideosParams(channelIds: _channelIds));
    
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        emit(VideosState.loaded(
          videos: videos,
          filteredVideos: _sortVideosList(videos, SortBy.publishedDate, SortOrder.descending),
          selectedChannel: null,
          selectedCountry: null,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onRefreshVideos(_RefreshVideos event, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(isRefreshing: true));
      
      final result = await getVideosUseCase(const GetVideosParams(
        channelIds: _channelIds,
        forceRefresh: true,
      ));
      
      result.fold(
        (failure) {
          emit(VideosState.error(failure.message));
        },
        (videos) {
          final newState = currentState.copyWith(
            videos: videos,
            isRefreshing: false,
          );
          _applyFiltersAndSort(newState, emit);
        },
      );
    } else {
      add(const VideosEvent.loadVideos());
    }
  }

  void _onFilterByChannel(_FilterByChannel event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(selectedChannel: event.channelName);
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onFilterByCountry(_FilterByCountry event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(selectedCountry: event.country);
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onSortVideos(_SortVideos event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _onClearFilters(_ClearFilters event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
      );
      _applyFiltersAndSort(newState, emit);
    }
  }

  void _applyFiltersAndSort(_Loaded stateData, Emitter<VideosState> emit) {
    List<Video> filtered = List.from(stateData.videos);

    if (stateData.selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == stateData.selectedChannel).toList();
    }

    if (stateData.selectedCountry != null) {
      filtered = filtered.where((v) => v.country == stateData.selectedCountry).toList();
    }

    filtered = _sortVideosList(filtered, stateData.sortBy, stateData.sortOrder);

    emit(stateData.copyWith(filteredVideos: filtered));
  }

  List<Video> _sortVideosList(List<Video> videos, SortBy sortBy, SortOrder order) {
    final list = List<Video>.from(videos);
    list.sort((a, b) {
      int comparison = 0;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else if (sortBy == SortBy.recordingDate) {
        final dateA = a.recordingDate ?? DateTime(1970);
        final dateB = b.recordingDate ?? DateTime(1970);
        comparison = dateA.compareTo(dateB);
      }

      return order == SortOrder.ascending ? comparison : -comparison;
    });
    return list;
  }
}
