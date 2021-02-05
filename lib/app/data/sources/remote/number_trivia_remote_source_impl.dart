import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../core/error/exceptions.dart';
import '../../dtos/number_trivia_dto.dart';
import 'contracts/number_trivia_remote_source.dart';

class NumberTriviaRemoteSourceImpl implements NumberTriviaRemoteSource {
  final http.Client _client;

  NumberTriviaRemoteSourceImpl({@required http.Client client})
      : _client = client;
  @override
  Future<NumberTriviaDto> getConcreteNumberTrivia(int number) async {
    final response = await _client.get(
      'http://numbersapi.com/$number',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return NumberTriviaDto.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<NumberTriviaDto> getRandomNumberTrivia() async {
    final response = await _client.get(
      'http://numbersapi.com/random',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return NumberTriviaDto.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw ServerException();
    }
  }
}
