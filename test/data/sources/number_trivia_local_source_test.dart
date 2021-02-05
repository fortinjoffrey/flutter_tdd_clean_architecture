import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/app/data/dtos/number_trivia_dto.dart';
import 'package:tdd_clean_architecture/app/data/sources/local/shared_preferences_number_trivia_local_source.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';

import '../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  SharedPreferencesNumberTriviaLocalSource dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = SharedPreferencesNumberTriviaLocalSource(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaDto = NumberTriviaDto.fromJson(
        json.decode(fixture('trivia_cached.json')) as Map<String, dynamic>);
    test(
      'should return NumberTriviaDto from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));

        // act
        final result = await dataSource.getLastNumberTrivia();

        // assert
        verify(mockSharedPreferences.getString(cachedNumberTrivia));
        expect(result, equals(tNumberTriviaDto));
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);

        // act
        final call = dataSource.getLastNumberTrivia;

        // assert
        expect(() => call(), throwsA(isA<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaDto = NumberTriviaDto(text: 'Test trivia', number: 1);
    test(
      'should call SharedPreferences to cache the data',
      () async {
        // arrange

        // act
        dataSource.cacheNumberTrivia(tNumberTriviaDto);
        // assert
        final expectedJsonString = json.encode(tNumberTriviaDto.toJson());
        verify(mockSharedPreferences.setString(
            cachedNumberTrivia, expectedJsonString));
      },
    );
  });
}
