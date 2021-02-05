import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../contracts/number_trivia/number_trivia_repository.dart';
import '../../entities/number_trivia.dart';
import '../usecase.dart';

class GetRandomNumberTrivia
    implements UseCase<Either<Failure, NumberTrivia>, None> {
  final NumberTriviaRepository _numberTriviaRepository;

  GetRandomNumberTrivia({
    @required NumberTriviaRepository numberTriviaRepository,
  }) : _numberTriviaRepository = numberTriviaRepository;

  @override
  Future<Either<Failure, NumberTrivia>> call([None params]) {
    return _numberTriviaRepository.getRandomNumberTrivia();
  }
}
