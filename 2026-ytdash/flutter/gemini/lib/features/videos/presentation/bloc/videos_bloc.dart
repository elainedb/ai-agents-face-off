import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/videos_usecases.dart';
import 'videos_event.dart';
import 'videos_state.dart';

@injectable
class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos getVideos;

  static const List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  VideosBloc({required this.getVideos}) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideos(const GetVideosParams(_channelIds, false));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        emit(VideosState.loaded(
          videos: videos,
          filteredVideos: _applyFiltersAndSort(videos, null, null, SortBy.publishedDate, SortOrder.descending),
        ));
      },
    );
  }

  Future<void> _onRefreshVideos(RefreshVideos event, Emitter<VideosState> emit) async {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      
      final result = await getVideos(const GetVideosParams(_channelIds, true));
      result.fold(
        (failure) {
          emit(VideosState.error(failure.message));
        },
        (videos) {
          emit(currentState.copyWith(
            videos: videos,
            filteredVideos: _applyFiltersAndSort(
              videos, 
              currentState.selectedChannel, 
              currentState.selectedCountry, 
              currentState.sortBy, 
              currentState.sortOrder
            ),
            isRefreshing: false,
          ));
        },
      );
    }
  }

  void _onFilterByChannel(FilterByChannel event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(
        selectedChannel: event.channelName,
        filteredVideos: _applyFiltersAndSort(
          currentState.videos,
          event.channelName,
          currentState.selectedCountry,
          currentState.sortBy,
          currentState.sortOrder,
        ),
      ));
    }
  }

  void _onFilterByCountry(FilterByCountry event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(
        selectedCountry: event.country,
        filteredVideos: _applyFiltersAndSort(
          currentState.videos,
          currentState.selectedChannel,
          event.country,
          currentState.sortBy,
          currentState.sortOrder,
        ),
      ));
    }
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        filteredVideos: _applyFiltersAndSort(
          currentState.videos,
          currentState.selectedChannel,
          currentState.selectedCountry,
          event.sortBy,
          event.sortOrder,
        ),
      ));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
        filteredVideos: _applyFiltersAndSort(
          currentState.videos,
          null,
          null,
          SortBy.publishedDate,
          SortOrder.descending,
        ),
      ));
    }
  }

  List<Video> _applyFiltersAndSort(
    List<Video> videos,
    String? channel,
    String? country,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    var filtered = videos.toList();
    if (channel != null) {
      filtered = filtered.where((v) => v.channelName == channel).toList();
    }
    if (country != null) {
      filtered = filtered.where((v) => v.country == country).toList();
    }

    filtered.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      
      if (sortBy == SortBy.recordingDate) {
        dateA = a.recordingDate ?? DateTime(1970);
        dateB = b.recordingDate ?? DateTime(1970);
      } else {
        dateA = a.publishedAt;
        dateB = b.publishedAt;
      }

      if (sortOrder == SortOrder.ascending) {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    return filtered;
  }
}
