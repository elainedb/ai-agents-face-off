import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

@injectable
class GetVideosByCountry implements UseCase<List<Video>, GetVideosByCountryParams> {
  final VideosRepository repository;

  GetVideosByCountry(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) async {
    return await repository.getVideosByCountry(params.country);
  }
}

class GetVideosByCountryParams extends Equatable {
  final String country;

  const GetVideosByCountryParams({required this.country});

  @override
  List<Object?> get props => [country];
}