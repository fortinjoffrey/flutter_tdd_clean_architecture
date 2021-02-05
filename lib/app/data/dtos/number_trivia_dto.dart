import 'package:meta/meta.dart';

import '../../domain/entities/number_trivia.dart';

class NumberTriviaDto extends NumberTrivia {
  const NumberTriviaDto({
    @required String text,
    @required int number,
  }) : super(text: text, number: number);

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
