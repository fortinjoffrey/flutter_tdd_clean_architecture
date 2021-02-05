import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  NetworkInfoImpl networkInfoImpl;
  MockDataConnectionChecker mockDataConnecitonChecker;

  setUp(() {
    mockDataConnecitonChecker = MockDataConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockDataConnecitonChecker);
  });

  group('isConnected', () {
    test(
      'should forward the call to DataConnectionChecker.hasConnection',
      () async {
        // arrange
        final tHasConnectionFuture = Future.value(true);

        when(mockDataConnecitonChecker.hasConnection)
            .thenAnswer((_) => tHasConnectionFuture);
        // act
        final result = networkInfoImpl.isConnected;

        // assert
        verify(mockDataConnecitonChecker.hasConnection);
        expect(result, tHasConnectionFuture);
      },
    );
  });
}
