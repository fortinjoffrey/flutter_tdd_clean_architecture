import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/app/data/dtos/number_trivia_dto.dart';
import 'package:tdd_clean_architecture/app/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaDto = NumberTriviaDto(number: 1, text: 'Test Text');

  test(
    'should be a subclass of NumberTrivia',
    () async {
      // assert
      expect(tNumberTriviaDto, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model when the JSON number is an integer',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia.json')) as Map<String, dynamic>;

        // act
        final result = NumberTriviaDto.fromJson(jsonMap);

        // assert
        expect(result, tNumberTriviaDto);
      },
    );

    test(
      'should return a valid model when the JSON number is regarded as a double',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia_double.json')) as Map<String, dynamic>;

        // act
        final result = NumberTriviaDto.fromJson(jsonMap);

        // assert
        expect(result, tNumberTriviaDto);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        // act
        final result = tNumberTriviaDto.toJson();
        // assert
        final expectedMap = {
          "text": "Test Text",
          "number": 1,
        };
        expect(result, expectedMap);
      },
    );
  });
}
