import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:tdd_clean_architecture/app/data/dtos/number_trivia_dto.dart';
import 'package:tdd_clean_architecture/app/data/sources/remote/number_trivia_remote_source_impl.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';

import '../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteSourceImpl remoteSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteSource = NumberTriviaRemoteSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaDto = NumberTriviaDto.fromJson(
        json.decode(fixture('trivia.json')) as Map<String, dynamic>);
    test(
      '''
      should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        remoteSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/$tNumber',
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();

        // act
        final result = await remoteSource.getConcreteNumberTrivia(tNumber);

        // assert
        expect(result, equals(tNumberTriviaDto));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteSource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaDto = NumberTriviaDto.fromJson(
        json.decode(fixture('trivia.json')) as Map<String, dynamic>);
    test(
      '''
      should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        remoteSource.getRandomNumberTrivia();
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/random',
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();

        // act
        final result = await remoteSource.getRandomNumberTrivia();

        // assert
        expect(result, equals(tNumberTriviaDto));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
