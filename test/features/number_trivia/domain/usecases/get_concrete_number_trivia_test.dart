import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/app/domain/contracts/number_trivia/number_trivia_repository.dart';
import 'package:tdd_clean_architecture/app/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/app/domain/usecases/number_trivia/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetConcreteNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(
        numberTriviaRepository: mockNumberTriviaRepository);
  });

  const testNumber = 1;
  const testNumberTrivia = NumberTrivia(text: 'test', number: testNumber);

  test(
    'should get trivia for the number from the repository',
    () async {
      // arrange
      when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(testNumberTrivia));
      // act
      final result = await usecase(testNumber);
      // assert
      expect(result, const Right<dynamic, NumberTrivia>(testNumberTrivia));
      verify(mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
