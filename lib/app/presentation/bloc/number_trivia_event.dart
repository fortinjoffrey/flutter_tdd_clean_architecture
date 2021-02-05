part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {}

class GetTriviaForConcreteNumberEvent extends NumberTriviaEvent {
  final String _numberString;

  GetTriviaForConcreteNumberEvent(this._numberString);

  @override
  List<Object> get props => [_numberString];

  String get numberString => _numberString;
}

class GetTriviaForRandomNumberEvent extends NumberTriviaEvent {
  @override
  List<Object> get props => [];
}
