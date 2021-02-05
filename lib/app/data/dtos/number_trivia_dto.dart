import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/number_trivia.dart';

class NumberTriviaDto extends Equatable {
  final String text;
  final int number;

  const NumberTriviaDto({
    @required this.text,
    @required this.number,
  });

  @override
  List<Object> get props => [text, number];

  factory NumberTriviaDto.fromJson(Map<String, dynamic> json) =>
      NumberTriviaDto(
        text: json['text'] as String,
        number: (json['number'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'number': number,
      };
}

extension NumberTriviaDtoX on NumberTriviaDto {
  NumberTrivia toDomain() => NumberTrivia(text: text, number: number);
}
