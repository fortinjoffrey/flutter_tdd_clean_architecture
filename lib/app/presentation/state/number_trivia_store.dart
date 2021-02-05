import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../core/error/failure.dart';
import '../../../core/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import '../../domain/usecases/number_trivia/get_random_number_trivia.dart';

part 'number_trivia_store.g.dart';

enum StoreState { initial, pending, complete, error }

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive ineger or zero';

class NumberTriviaStore extends _NumberTriviaStore with _$NumberTriviaStore {
  NumberTriviaStore(
    GetConcreteNumberTrivia getConcreteNumberTrivia,
    GetRandomNumberTrivia getRandomNumberTrivia,
    InputConverter inputConverter,
  ) : super(
          getConcreteNumberTrivia,
          getRandomNumberTrivia,
          inputConverter,
        );
}

abstract class _NumberTriviaStore with Store {
  final GetConcreteNumberTrivia _getConcreteNumberTrivia;
  final GetRandomNumberTrivia _getRandomNumberTrivia;
  final InputConverter _inputConverter;

  _NumberTriviaStore(
    this._getConcreteNumberTrivia,
    this._getRandomNumberTrivia,
    this._inputConverter,
  );

  @observable
  ObservableFuture<Either<Failure, NumberTrivia>> _numberTriviaFuture;

  @observable
  NumberTrivia numberTrivia;

  @observable
  String errorMessage;

  @computed
  StoreState get state {
    if (_numberTriviaFuture == null ||
        _numberTriviaFuture.status == FutureStatus.rejected) {
      return StoreState.initial;
    }

    if (_numberTriviaFuture.value != null &&
            _numberTriviaFuture.value.isLeft() ||
        errorMessage != null) {
      return StoreState.error;
    }

    return _numberTriviaFuture.status == FutureStatus.pending
        ? StoreState.pending
        : StoreState.complete;
  }

  @action
  Future<void> getConcrete(String numberString) async {
    errorMessage = null;

    final inputEither = _inputConverter.stringToUnsignedInteger(numberString);

    inputEither.fold((failure) {
      errorMessage = invalidInputFailureMessage;
    }, (integer) async {
      _numberTriviaFuture = ObservableFuture(_getConcreteNumberTrivia(integer));
      await _fetchNumberTrivia();
    });
  }

  Future _fetchNumberTrivia() async {
    final result = await _numberTriviaFuture;
    result.fold(
      (failure) {
        errorMessage = _mapFailureToMessage(failure);
      },
      (trivia) {
        numberTrivia = trivia;
      },
    );
  }

  Future<void> getRandom() async {
    errorMessage = null;

    _numberTriviaFuture = ObservableFuture(_getRandomNumberTrivia());
    await _fetchNumberTrivia();
  }

  // Private implementations
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
