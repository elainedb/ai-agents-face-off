import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';

class MockGetVideos extends Mock implements GetVideos {}

void main() {
  late VideosBloc bloc;
  late MockGetVideos mockGetVideos;

  final testVideos = [
    Video(
      id: '1',
      title: 'Video 1',
      channelName: 'Channel A',
      thumbnailUrl: 'https://example.com/thumb1.jpg',
      publishedAt: DateTime(2024, 1, 15),
      tags: ['tag1'],
      country: 'Brazil',
    ),
    Video(
      id: '2',
      title: 'Video 2',
      channelName: 'Channel B',
      thumbnailUrl: 'https://example.com/thumb2.jpg',
      publishedAt: DateTime(2024, 2, 10),
      tags: ['tag2'],
      country: 'Portugal',
      recordingDate: DateTime(2024, 2, 5),
    ),
    Video(
      id: '3',
      title: 'Video 3',
      channelName: 'Channel A',
      thumbnailUrl: 'https://example.com/thumb3.jpg',
      publishedAt: DateTime(2024, 3, 1),
      tags: [],
      country: 'Brazil',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(
        const GetVideosParams(channelIds: []));
  });

  setUp(() {
    mockGetVideos = MockGetVideos();
    bloc = VideosBloc(mockGetVideos);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is VideosState.initial', () {
    expect(bloc.state, const VideosState.initial());
  });

  group('loadVideos', () {
    blocTest<VideosBloc, VideosState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockGetVideos(any()))
            .thenAnswer((_) async => Right(testVideos));
        return bloc;
      },
      act: (bloc) => bloc.add(const VideosEvent.loadVideos()),
      expect: () => [
        const VideosState.loading(),
        isA<VideosLoaded>()
            .having((s) => s.videos.length, 'videos count', 3)
            .having(
                (s) => s.filteredVideos.length, 'filtered count', 3),
      ],
    );

    blocTest<VideosBloc, VideosState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockGetVideos(any())).thenAnswer(
            (_) async => const Left(Failure.server('API error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const VideosEvent.loadVideos()),
      expect: () => [
        const VideosState.loading(),
        const VideosState.error('API error'),
      ],
    );
  });

  group('filterByChannel', () {
    blocTest<VideosBloc, VideosState>(
      'filters videos by channel name',
      build: () {
        when(() => mockGetVideos(any()))
            .thenAnswer((_) async => Right(testVideos));
        return bloc;
      },
      seed: () => VideosState.loaded(
        videos: testVideos,
        filteredVideos: testVideos,
      ),
      act: (bloc) =>
          bloc.add(const VideosEvent.filterByChannel('Channel A')),
      expect: () => [
        isA<VideosLoaded>()
            .having((s) => s.filteredVideos.length, 'filtered count', 2)
            .having((s) => s.selectedChannel, 'channel', 'Channel A'),
      ],
    );
  });

  group('filterByCountry', () {
    blocTest<VideosBloc, VideosState>(
      'filters videos by country',
      build: () {
        when(() => mockGetVideos(any()))
            .thenAnswer((_) async => Right(testVideos));
        return bloc;
      },
      seed: () => VideosState.loaded(
        videos: testVideos,
        filteredVideos: testVideos,
      ),
      act: (bloc) =>
          bloc.add(const VideosEvent.filterByCountry('Brazil')),
      expect: () => [
        isA<VideosLoaded>()
            .having((s) => s.filteredVideos.length, 'filtered count', 2)
            .having((s) => s.selectedCountry, 'country', 'Brazil'),
      ],
    );
  });

  group('sortVideos', () {
    blocTest<VideosBloc, VideosState>(
      'sorts by published date ascending',
      build: () => bloc,
      seed: () => VideosState.loaded(
        videos: testVideos,
        filteredVideos: testVideos,
      ),
      act: (bloc) => bloc.add(const VideosEvent.sortVideos(
          SortBy.publishedDate, SortOrder.ascending)),
      expect: () => [
        isA<VideosLoaded>()
            .having((s) => s.filteredVideos.first.id, 'first id', '1')
            .having((s) => s.sortBy, 'sortBy', SortBy.publishedDate)
            .having(
                (s) => s.sortOrder, 'sortOrder', SortOrder.ascending),
      ],
    );
  });

  group('clearFilters', () {
    blocTest<VideosBloc, VideosState>(
      'resets to defaults',
      build: () => bloc,
      seed: () => VideosState.loaded(
        videos: testVideos,
        filteredVideos: [testVideos.first],
        selectedChannel: 'Channel A',
        selectedCountry: 'Brazil',
        sortBy: SortBy.recordingDate,
        sortOrder: SortOrder.ascending,
      ),
      act: (bloc) => bloc.add(const VideosEvent.clearFilters()),
      expect: () => [
        isA<VideosLoaded>()
            .having((s) => s.filteredVideos.length, 'filtered count', 3)
            .having((s) => s.selectedChannel, 'channel', null)
            .having((s) => s.selectedCountry, 'country', null)
            .having((s) => s.sortBy, 'sortBy', SortBy.publishedDate)
            .having(
                (s) => s.sortOrder, 'sortOrder', SortOrder.descending),
      ],
    );
  });
}
