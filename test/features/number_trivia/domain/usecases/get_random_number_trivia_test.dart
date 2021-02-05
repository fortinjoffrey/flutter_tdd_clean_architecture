import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/app/domain/contracts/number_trivia/number_trivia_repository.dart';
import 'package:tdd_clean_architecture/app/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/app/domain/usecases/number_trivia/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(
        numberTriviaRepository: mockNumberTriviaRepository);
  });

  const testNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test(
    'should get trivia from the repository',
    () async {
      // arrange
      when(mockNumberTriviaRepository.getRandomNumberTrivia())
          .thenAnswer((_) async => const Right(testNumberTrivia));
      // act
      final result = await usecase();
      // assert
      expect(result, const Right<dynamic, NumberTrivia>(testNumberTrivia));
      verify(mockNumberTriviaRepository.getRandomNumberTrivia());
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
