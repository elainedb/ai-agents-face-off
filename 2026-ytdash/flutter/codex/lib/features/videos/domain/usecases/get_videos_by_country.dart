import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByCountryParams extends Equatable {
  const GetVideosByCountryParams(this.country);

  final String country;

  @override
  List<Object?> get props => <Object?>[country];
}

@injectable
class GetVideosByCountry
    implements UseCase<List<Video>, GetVideosByCountryParams> {
  GetVideosByCountry(this._repository);

  final VideosRepository _repository;

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) {
    return _repository.getVideosByCountry(params.country);
  }
}
