import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../dtos/number_trivia_dto.dart';
import 'contracts/number_trivia_local_source.dart';

const String cachedNumberTrivia = 'CACHED_NUMBER_TRIVIA';

class SharedPreferencesNumberTriviaLocalSource
    implements NumberTriviaLocalSource {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesNumberTriviaLocalSource({
    @required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<NumberTriviaDto> getLastNumberTrivia() {
    final jsonString = _sharedPreferences.getString(cachedNumberTrivia);

    if (jsonString != null) {
      return Future.value(NumberTriviaDto.fromJson(
          json.decode(jsonString) as Map<String, dynamic>));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaDto triviaToCache) {
    _sharedPreferences.setString(
        cachedNumberTrivia, json.encode(triviaToCache.toJson()));
    return Future.value();
  }
}
