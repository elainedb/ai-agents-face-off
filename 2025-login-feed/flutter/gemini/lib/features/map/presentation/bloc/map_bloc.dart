
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/map/domain/entities/video_location.dart';
import 'package:flutter_gemini/features/map/domain/usecases/get_video_locations.dart';
import 'package:injectable/injectable.dart';

part 'map_event.dart';
part 'map_state.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetVideoLocations getVideoLocations;

  MapBloc(this.getVideoLocations) : super(MapInitial()) {
    on<LoadVideoLocations>(_onLoadVideoLocations);
  }

  Future<void> _onLoadVideoLocations(
    LoadVideoLocations event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    final result = await getVideoLocations(NoParams());
    result.fold(
      (failure) => emit(MapError(failure.toString())),
      (locations) => emit(MapLoaded(locations)),
    );
  }
}
