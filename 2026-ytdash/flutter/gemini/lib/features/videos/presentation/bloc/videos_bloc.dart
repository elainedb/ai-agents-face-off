import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/videos_usecases.dart';

part 'videos_event.dart';
part 'videos_state.dart';
part 'videos_bloc.freezed.dart';

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
    on<VideosEvent>((event, emit) async {
      await event.map(
        loadVideos: (e) => _onLoadVideos(e, emit),
        refreshVideos: (e) => _onRefreshVideos(e, emit),
        filterByChannel: (e) => _onFilterByChannel(e, emit),
        filterByCountry: (e) => _onFilterByCountry(e, emit),
        sortVideos: (e) => _onSortVideos(e, emit),
        clearFilters: (e) => _onClearFilters(e, emit),
      );
    });
  }

  Future<void> _onLoadVideos(_LoadVideos event, Emitter<VideosState> emit) async {
    emit(const VideosState.loading());
    final result = await getVideos(GetVideosParams(channelIds: _channelIds));
    result.fold(
      (failure) => emit(VideosState.error(failure.message)),
      (videos) => emit(VideosState.loaded(
        videos: videos,
        filteredVideos: _applyFiltersAndSort(
          videos,
          null,
          null,
          SortBy.publishedDate,
          SortOrder.descending,
        ),
        selectedChannel: null,
        selectedCountry: null,
        sortBy: SortBy.publishedDate,
        sortOrder: SortOrder.descending,
        isRefreshing: false,
      )),
    );
  }

  Future<void> _onRefreshVideos(_RefreshVideos event, Emitter<VideosState> emit) async {
    await state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) async {
        emit((state as Loaded).copyWith(isRefreshing: true));
        final result = await getVideos(GetVideosParams(channelIds: _channelIds, forceRefresh: true));
        result.fold(
          (failure) => emit(VideosState.error(failure.message)),
          (newVideos) => emit(VideosState.loaded(
            videos: newVideos,
            filteredVideos: _applyFiltersAndSort(
              newVideos,
              selectedChannel,
              selectedCountry,
              sortBy,
              sortOrder,
            ),
            selectedChannel: selectedChannel,
            selectedCountry: selectedCountry,
            sortBy: sortBy,
            sortOrder: sortOrder,
            isRefreshing: false,
          )),
        );
      },
      orElse: () async => add(const VideosEvent.loadVideos()),
    );
  }

  Future<void> _onFilterByChannel(_FilterByChannel event, Emitter<VideosState> emit) async {
    state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
        emit((state as Loaded).copyWith(
          selectedChannel: event.channelName,
          filteredVideos: _applyFiltersAndSort(
            videos,
            event.channelName,
            selectedCountry,
            sortBy,
            sortOrder,
          ),
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onFilterByCountry(_FilterByCountry event, Emitter<VideosState> emit) async {
    state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
        emit((state as Loaded).copyWith(
          selectedCountry: event.country,
          filteredVideos: _applyFiltersAndSort(
            videos,
            selectedChannel,
            event.country,
            sortBy,
            sortOrder,
          ),
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onSortVideos(_SortVideos event, Emitter<VideosState> emit) async {
    state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
        emit((state as Loaded).copyWith(
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          filteredVideos: _applyFiltersAndSort(
            videos,
            selectedChannel,
            selectedCountry,
            event.sortBy,
            event.sortOrder,
          ),
        ));
      },
      orElse: () {},
    );
  }

  Future<void> _onClearFilters(_ClearFilters event, Emitter<VideosState> emit) async {
    state.maybeWhen(
      loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
        emit((state as Loaded).copyWith(
          selectedChannel: null,
          selectedCountry: null,
          sortBy: SortBy.publishedDate,
          sortOrder: SortOrder.descending,
          filteredVideos: _applyFiltersAndSort(
            videos,
            null,
            null,
            SortBy.publishedDate,
            SortOrder.descending,
          ),
        ));
      },
      orElse: () {},
    );
  }

  List<Video> _applyFiltersAndSort(
    List<Video> videos,
    String? channel,
    String? country,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    var filtered = videos;

    if (channel != null) {
      filtered = filtered.where((v) => v.channelName == channel).toList();
    }

    if (country != null) {
      filtered = filtered.where((v) => v.country == country).toList();
    }

    final comparator = (Video a, Video b) {
      int comparison;
      if (sortBy == SortBy.publishedDate) {
        comparison = a.publishedAt.compareTo(b.publishedAt);
      } else {
        final dateA = a.recordingDate ?? DateTime(1970);
        final dateB = b.recordingDate ?? DateTime(1970);
        comparison = dateA.compareTo(dateB);
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    };

    return List<Video>.from(filtered)..sort(comparator);
  }
}
