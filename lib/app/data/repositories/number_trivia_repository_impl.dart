import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/network_info.dart';
import '../../domain/contracts/number_trivia/number_trivia_repository.dart';
import '../../domain/entities/number_trivia.dart';
import '../dtos/number_trivia_dto.dart';
import '../sources/local/contracts/number_trivia_local_source.dart';
import '../sources/remote/contracts/number_trivia_remote_source.dart';

typedef ConcreteOrRandomChoose = Future<NumberTriviaDto> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteSource _remoteSource;
  final NumberTriviaLocalSource _localSource;
  final NetworkInfo _networkInfo;

  NumberTriviaRepositoryImpl({
    @required NumberTriviaRemoteSource remoteSource,
    @required NumberTriviaLocalSource localSource,
    @required NetworkInfo networkInfo,
  })  : _remoteSource = remoteSource,
        _localSource = localSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
          int number) async =>
      _getTrivia(() => _remoteSource.getConcreteNumberTrivia(number));

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async =>
      _getTrivia(() => _remoteSource.getRandomNumberTrivia());

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    ConcreteOrRandomChoose getConcreteOrRandom,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteTriviaDto = await getConcreteOrRandom();

        _localSource.cacheNumberTrivia(remoteTriviaDto);

        return Right(remoteTriviaDto.toDomain());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTriviaDto = await _localSource.getLastNumberTrivia();
        return Right(localTriviaDto.toDomain());
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
