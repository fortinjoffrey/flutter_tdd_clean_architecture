import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/number_trivia.dart';

part 'number_trivia_dto.freezed.dart';
part 'number_trivia_dto.g.dart';

@freezed
abstract class NumberTriviaDto with _$NumberTriviaDto {
  const factory NumberTriviaDto({
    @required String text,
    @required int number,
  }) = _NumberTriviaDto;

  factory NumberTriviaDto.fromJson(Map<String, dynamic> json) =>
      _$NumberTriviaDtoFromJson(json);
}

extension NumberTriviaDtoX on NumberTriviaDto {
  NumberTrivia toDomain() => NumberTrivia(text: text, number: number);
}
