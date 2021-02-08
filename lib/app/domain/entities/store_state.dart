import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_state.freezed.dart';

@freezed
abstract class StoreState<T> with _$StoreState<T> {
  const factory StoreState.initial() = _Initial<T>;
  const factory StoreState.pending() = _Pending<T>;
  const factory StoreState.complete(T data) = _Complete<T>;
  const factory StoreState.failure(String msg) = _Failure<T>;
}
