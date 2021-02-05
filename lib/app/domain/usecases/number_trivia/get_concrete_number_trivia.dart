import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../contracts/number_trivia/number_trivia_repository.dart';
import '../../entities/number_trivia.dart';
import '../usecase.dart';

class GetConcreteNumberTrivia
    implements UseCase<Either<Failure, NumberTrivia>, int> {
  final NumberTriviaRepository _numberTriviaRepository;

  GetConcreteNumberTrivia({
    @required NumberTriviaRepository numberTriviaRepository,
  }) : _numberTriviaRepository = numberTriviaRepository;

  @override
  Future<Either<Failure, NumberTrivia>> call(int number) {
    return _numberTriviaRepository.getConcreteNumberTrivia(number);
  }
}
