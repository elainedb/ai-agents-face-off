
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/di.dart';
import 'package:flutter_gemini/features/map/presentation/bloc/map_bloc.dart';
import 'package:flutter_gemini/features/map/presentation/widgets/video_bottom_sheet.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MapBloc>()..add(LoadVideoLocations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map Screen'),
        ),
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MapError) {
              return Center(child: Text(state.message));
            } else if (state is MapLoaded) {
              return FlutterMap(
                options: MapOptions(
                  bounds: LatLngBounds.fromPoints(
                      state.locations.map((e) => e.coordinates).toList()),
                  boundsOptions:
                      const FitBoundsOptions(padding: EdgeInsets.all(50)),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fluttergemini.app',
                  ),
                  MarkerLayer(
                    markers: state.locations
                        .map(
                          (location) => Marker(
                            point: location.coordinates,
                            builder: (context) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) =>
                                      VideoBottomSheet(location: location),
                                );
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
