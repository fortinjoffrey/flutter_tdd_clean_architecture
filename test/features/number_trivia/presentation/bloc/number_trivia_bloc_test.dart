import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/app/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/app/domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/app/domain/usecases/number_trivia/get_random_number_trivia.dart';
import 'package:tdd_clean_architecture/app/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_architecture/core/error/failure.dart';
import 'package:tdd_clean_architecture/core/utils/input_converter.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });
  test(
    'initialState should be empty',
    () async {
      // assert
      expect(bloc.state, equals(EmptyNumberTriviaState()));
    },
  );

  group('GetTriviaForConcreteNumberEvent', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    /* DOES NOT WORK BECAUSE OF YIELD* */
    // blocTest<NumberTriviaBloc, NumberTriviaState>(
    //   'should call the InputConverter to validate and convert the string to an unsigned integer',
    //   build: () {
    //     setUpMockInputConverterSuccess();
    //     return bloc;
    //   },
    //   act: (cubit) async {
    //     bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    //     await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
    //   },
    //   verify: (_) {
    //     verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    //   },
    // );

    void setUpMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(const Right(tNumberParsed));
    }

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [ErrorNumberTriviaState] when the input is invalid',
      build: () {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailre()));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString)),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        ErrorNumberTriviaState(message: invalidInputFailureMessage),
      ],
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));

        // assert
        verify(mockGetConcreteNumberTrivia(tNumberParsed));
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString)),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        LoadedNumberTriviaState(tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString)),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        ErrorNumberTriviaState(message: serverFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumberEvent(tNumberString)),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        ErrorNumberTriviaState(message: cacheFailureMessage),
      ],
    );
  });

  group('GetTriviaForRandomNumberEvent', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForRandomNumberEvent());
        await untilCalled(mockGetRandomNumberTrivia());

        // assert
        verify(mockGetRandomNumberTrivia());
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => const Right(tNumberTrivia));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaForRandomNumberEvent()),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        LoadedNumberTriviaState(tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaForRandomNumberEvent()),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        ErrorNumberTriviaState(message: serverFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () {
        // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaForRandomNumberEvent()),
      expect: <NumberTriviaState>[
        EmptyNumberTriviaState(),
        LoadingNumberTriviaState(),
        ErrorNumberTriviaState(message: cacheFailureMessage),
      ],
    );
  });
}
