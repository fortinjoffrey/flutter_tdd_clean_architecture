part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {}

class EmptyNumberTriviaState extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class LoadingNumberTriviaState extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class LoadedNumberTriviaState extends NumberTriviaState {
  final NumberTrivia trivia;

  LoadedNumberTriviaState(this.trivia);

  @override
  List<Object> get props => [trivia];
}

class ErrorNumberTriviaState extends NumberTriviaState {
  final String message;

  ErrorNumberTriviaState({this.message});

  @override
  List<Object> get props => [message];
}
