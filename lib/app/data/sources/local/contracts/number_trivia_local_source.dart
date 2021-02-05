import '../../../../../core/error/exceptions.dart';
import '../../../dtos/number_trivia_dto.dart';

abstract class NumberTriviaLocalSource {
  /// Gets the cached [NumberTriviaDto] which was gotten the last time
  /// the user had an internet connection
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaDto> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaDto triviaToCache);
}
