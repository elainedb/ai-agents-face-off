import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByCountry {
  const GetVideosByCountry(this.repository);

  final VideosRepository repository;

  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) {
    return repository.getVideosByCountry(params.country);
  }
}

class GetVideosByCountryParams extends Equatable {
  const GetVideosByCountryParams(this.country);

  final String country;

  @override
  List<Object?> get props => [country];
}
