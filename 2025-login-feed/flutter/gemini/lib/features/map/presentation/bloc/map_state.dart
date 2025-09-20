
part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<VideoLocation> locations;

  const MapLoaded(this.locations);

  @override
  List<Object> get props => [locations];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object> get props => [message];
}
