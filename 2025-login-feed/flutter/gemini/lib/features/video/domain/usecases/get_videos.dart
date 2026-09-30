import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:flutter_gemini/features/video/domain/repositories/video_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVideos extends UseCase<List<Video>, GetVideosParams> {
  final VideoRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) async {
    return await repository.getVideos(forceRefresh: params.forceRefresh);
  }
}

class GetVideosParams extends Equatable {
  final bool forceRefresh;

  const GetVideosParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}