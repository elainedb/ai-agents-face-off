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
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: videos,
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
        isRefreshing: false,
      )),
    );
  }

  Future<void> _onRefreshVideos(_RefreshVideos event, Emitter<VideosState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const VideosState.loading());
    }

    final result = await getVideos(const GetVideosParams(channelIds: _channelIds, forceRefresh: true));
    
    result.fold(
      (failure) {
        if (currentState is _Loaded) {
          emit(currentState.copyWith(isRefreshing: false));
          // Optionally, handle error state or show a snackbar
        } else {
          emit(VideosState.error(failure.message));
        }
      },
      (videos) {
        if (currentState is _Loaded) {
          final newState = currentState.copyWith(videos: videos, isRefreshing: false);
          _applyFiltersAndSort(emit, newState);
        } else {
          emit(VideosState.loaded(
            videos: videos,
            filteredVideos: videos,
            selectedChannel: null,
            selectedCountry: null,
            sortBy: SortBy.publishedDate,
            sortOrder: SortOrder.descending,
            isRefreshing: false,
          ));
        }
      },
    );
  }

  void _onFilterByChannel(_FilterByChannel event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(selectedChannel: event.channelName);
      _applyFiltersAndSort(emit, newState);
    }
  }

  void _onFilterByCountry(_FilterByCountry event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(selectedCountry: event.country);
      _applyFiltersAndSort(emit, newState);
    }
  }

  void _onSortVideos(_SortVideos event, Emitter<VideosState> emit) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      final newState = currentState.copyWith(sortBy: event.sortBy, sortOrder: event.sortOrder);
      _applyFiltersAndSort(emit, newState);
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
      _applyFiltersAndSort(emit, newState);
    }
  }

  void _applyFiltersAndSort(Emitter<VideosState> emit, _Loaded currentState) {
    List<Video> filtered = currentState.videos;

    if (currentState.selectedChannel != null) {
      filtered = filtered.where((v) => v.channelName == currentState.selectedChannel).toList();
    }

    if (currentState.selectedCountry != null) {
      filtered = filtered.where((v) => v.country == currentState.selectedCountry).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      if (currentState.sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else if (currentState.sortBy == SortBy.recordingDate) {
        final aDate = a.recordingDate ?? DateTime(1970);
        final bDate = b.recordingDate ?? DateTime(1970);
        comparison = aDate.compareTo(bDate);
      }

      if (currentState.sortOrder == SortOrder.descending) {
        return -comparison;
      }
      return comparison;
    });

    emit(currentState.copyWith(filteredVideos: filtered));
  }
}