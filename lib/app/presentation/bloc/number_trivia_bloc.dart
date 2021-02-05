import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/error/failure.dart';
import '../../../core/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import '../../domain/usecases/number_trivia/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive ineger or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia _getConcreteNumberTrivia;
  final GetRandomNumberTrivia _getRandomNumberTrivia;
  final InputConverter _inputConverter;

  NumberTriviaBloc({
    @required GetConcreteNumberTrivia getConcreteNumberTrivia,
    @required GetRandomNumberTrivia getRandomNumberTrivia,
    @required InputConverter inputConverter,
  })  : assert(getConcreteNumberTrivia != null),
        assert(getRandomNumberTrivia != null),
        assert(inputConverter != null),
        _getConcreteNumberTrivia = getConcreteNumberTrivia,
        _getRandomNumberTrivia = getRandomNumberTrivia,
        _inputConverter = inputConverter,
        super(EmptyNumberTriviaState());

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    yield state;
    if (event is GetTriviaForConcreteNumberEvent) {
      final inputEither =
          _inputConverter.stringToUnsignedInteger(event.numberString);

      yield* inputEither.fold(
        (failure) async* {
          yield ErrorNumberTriviaState(message: invalidInputFailureMessage);
        },
        (integer) async* {
          yield LoadingNumberTriviaState();
          final failureOrTrivia = await _getConcreteNumberTrivia(integer);
          yield* _eitherLoadedOrErrorState(failureOrTrivia);
        },
      );
    } else if (event is GetTriviaForRandomNumberEvent) {
      yield LoadingNumberTriviaState();
      final failureOrTrivia = await _getRandomNumberTrivia();
      yield* _eitherLoadedOrErrorState(failureOrTrivia);
    }
  }
}

extension NumberTriviaBlocX on NumberTriviaBloc {
  Stream<NumberTriviaState> _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) async* {
    yield failureOrTrivia.fold(
      (failure) =>
          ErrorNumberTriviaState(message: _mapFailureToMessage(failure)),
      (trivia) => LoadedNumberTriviaState(trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
        break;
      case CacheFailure:
        return cacheFailureMessage;
        break;
      default:
        return 'Unexpected error';
    }
  }
}
