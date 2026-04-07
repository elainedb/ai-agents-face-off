import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos.dart';
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

  VideosBloc(this.getVideos) : super(const VideosState.initial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<FilterByChannel>(_onFilterByChannel);
    on<FilterByCountry>(_onFilterByCountry);
    on<SortVideos>(_onSortVideos);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideos(GetVideosParams(_channelIds));
    
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) {
        emit(VideosState.loaded(
          videos,
          videos,
          null,
          null,
          SortBy.publishedDate,
          SortOrder.descending,
          false,
        ));
      },
    );
  }

  Future<void> _onRefreshVideos(RefreshVideos event, Emitter<VideosState> emit) async {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      
      final result = await getVideos(GetVideosParams(_channelIds, forceRefresh: true));
      
      result.fold(
        (failure) {
          emit(VideosState.error(failure.message));
        },
        (videos) {
          _applyFiltersAndSort(
            emit,
            videos,
            currentState.selectedChannel,
            currentState.selectedCountry,
            currentState.sortBy,
            currentState.sortOrder,
          );
        },
      );
    } else {
      add(const LoadVideos());
    }
  }

  void _onFilterByChannel(FilterByChannel event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _applyFiltersAndSort(
        emit,
        currentState.videos,
        event.channelName,
        currentState.selectedCountry,
        currentState.sortBy,
        currentState.sortOrder,
      );
    }
  }

  void _onFilterByCountry(FilterByCountry event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _applyFiltersAndSort(
        emit,
        currentState.videos,
        currentState.selectedChannel,
        event.country,
        currentState.sortBy,
        currentState.sortOrder,
      );
    }
  }

  void _onSortVideos(SortVideos event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _applyFiltersAndSort(
        emit,
        currentState.videos,
        currentState.selectedChannel,
        currentState.selectedCountry,
        event.sortBy,
        event.sortOrder,
      );
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<VideosState> emit) {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      _applyFiltersAndSort(
        emit,
        currentState.videos,
        null,
        null,
        SortBy.publishedDate,
        SortOrder.descending,
      );
    }
  }

  void _applyFiltersAndSort(
    Emitter<VideosState> emit,
    List<Video> allVideos,
    String? channelName,
    String? country,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    var filtered = List<Video>.from(allVideos);

    if (channelName != null) {
      filtered = filtered.where((v) => v.channelName == channelName).toList();
    }

    if (country != null) {
      filtered = filtered.where((v) => v.country == country).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else if (sortBy == SortBy.recordingDate) {
        final dateA = a.recordingDate ?? DateTime(1970);
        final dateB = b.recordingDate ?? DateTime(1970);
        comparison = dateA.compareTo(dateB);
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    emit(VideosState.loaded(
      allVideos,
      filtered,
      channelName,
      country,
      sortBy,
      sortOrder,
      false,
    ));
  }

  List<String> getAvailableChannels(List<Video> videos) {
    final channels = videos.map((v) => v.channelName).toSet().toList();
    channels.sort();
    return channels;
  }

  List<String> getAvailableCountries(List<Video> videos) {
    final countries = videos.map((v) => v.country).where((c) => c != null).cast<String>().toSet().toList();
    countries.sort();
    return countries;
  }
}
