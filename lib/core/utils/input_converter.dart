import 'package:dartz/dartz.dart';

import '../error/failure.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    final int integer = int.tryParse(str);

    return (integer == null || integer.isNegative)
        ? Left(InvalidInputFailre())
        : Right(int.parse(str));
  }
}

class InvalidInputFailre extends Failure {
  @override
  List<Object> get props => [];
}
