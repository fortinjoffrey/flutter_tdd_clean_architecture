import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/app/data/dtos/number_trivia_dto.dart';
import 'package:tdd_clean_architecture/app/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture/app/data/sources/local/contracts/number_trivia_local_source.dart';
import 'package:tdd_clean_architecture/app/data/sources/remote/contracts/number_trivia_remote_source.dart';
import 'package:tdd_clean_architecture/app/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/core/error/failure.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';

class MockRemoteSource extends Mock implements NumberTriviaRemoteSource {}

class MockLocalSource extends Mock implements NumberTriviaLocalSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repositoryImpl;
  MockRemoteSource mockRemoteSource;
  MockLocalSource mockLocalSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteSource = MockRemoteSource();
    mockLocalSource = MockLocalSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
      remoteSource: mockRemoteSource,
      localSource: mockLocalSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaDto =
        NumberTriviaDto(text: 'Test Trivia', number: tNumber);
    const tNumberTrivia = tNumberTriviaDto;
    test(
      'should check if the device is online',
      () async {
        // arrange
        // isConnected now returns true
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repositoryImpl.getConcreteNumberTrivia(tNumber);
        // assert
        // verify if isConnected has been called
        verify(mockNetworkInfo.isConnected);
      },
    );
    runTestsOnline(() {
      test(
        'should return remote data when the call to remote source is successful',
        () async {
          // arrange
          when(mockRemoteSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaDto);
          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          // assert
          // we verify that the mockRemoteSource.getConcreteNumberTrivia
          // has been called with tNumber and not something else
          verify(mockRemoteSource.getConcreteNumberTrivia(tNumber));
          expect(result,
              equals(const Right<dynamic, NumberTrivia>(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote source is successful',
        () async {
          // arrange
          when(mockRemoteSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaDto);
          // act
          await repositoryImpl.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockRemoteSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalSource.cacheNumberTrivia(tNumberTriviaDto));
        },
      );

      test(
        'should return server failure when the call to remote source is unsuccessful',
        () async {
          // arrange
          when(mockRemoteSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockRemoteSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalSource);
          expect(result, equals(Left<ServerFailure, dynamic>(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockLocalSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaDto);

          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockLocalSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteSource);
          expect(result,
              equals(const Right<dynamic, NumberTrivia>(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          when(mockLocalSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockLocalSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteSource);
          expect(result, equals(Left<CacheFailure, dynamic>(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaDto = NumberTriviaDto(text: 'Test Trivia', number: 123);
    const tNumberTrivia = tNumberTriviaDto;
    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repositoryImpl.getRandomNumberTrivia();
        // assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote source is successful',
        () async {
          // arrange
          when(mockRemoteSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaDto);
          // act
          final result = await repositoryImpl.getRandomNumberTrivia();

          // assert
          // we verify that the mockRemoteSource.getConcreteNumberTrivia
          // has been called with tNumber and not something else
          verify(mockRemoteSource.getRandomNumberTrivia());
          expect(result,
              equals(const Right<dynamic, NumberTrivia>(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote source is successful',
        () async {
          // arrange
          when(mockRemoteSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaDto);
          // act
          await repositoryImpl.getRandomNumberTrivia();

          // assert
          verify(mockRemoteSource.getRandomNumberTrivia());
          verify(mockLocalSource.cacheNumberTrivia(tNumberTriviaDto));
        },
      );

      test(
        'should return server failure when the call to remote source is unsuccessful',
        () async {
          // arrange
          when(mockRemoteSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final result = await repositoryImpl.getRandomNumberTrivia();

          // assert
          verify(mockRemoteSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalSource);
          expect(result, equals(Left<ServerFailure, dynamic>(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockLocalSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaDto);

          // act
          final result = await repositoryImpl.getRandomNumberTrivia();

          // assert
          verify(mockLocalSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteSource);
          expect(result,
              equals(const Right<dynamic, NumberTrivia>(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          when(mockLocalSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          // act
          final result = await repositoryImpl.getRandomNumberTrivia();

          // assert
          verify(mockLocalSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteSource);
          expect(result, equals(Left<CacheFailure, dynamic>(CacheFailure())));
        },
      );
    });
  });
}
