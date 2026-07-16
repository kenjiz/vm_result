import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

class CustomException implements Exception {
  final String message;
  CustomException(this.message);
}

void main() {
  group('Result', () {
    group('constructors', () {
      test('initial creates ResultInitial', () {
        final result = Result<String>.initial();
        expect(result, isA<ResultInitial<String>>());
      });

      test('loading creates ResultLoading', () {
        final result = Result<String>.loading();
        expect(result, isA<ResultLoading<String>>());
      });

      test('data creates ResultData with value', () {
        final result = Result.data('hello');
        expect(result, isA<ResultData<String>>());
        expect((result as ResultData<String>).value, 'hello');
      });

      test('error creates ResultError with exception', () {
        final error = Exception('oops');
        final result = Result<String>.error(error);
        expect(result, isA<ResultError<String>>());
        expect((result as ResultError<String>).error, error);
      });
    });

    group('boolean getters', () {
      test('isLoading is true only for loading state', () {
        expect(Result<int>.initial().isLoading, isFalse);
        expect(Result<int>.loading().isLoading, isTrue);
        expect(Result.data(1).isLoading, isFalse);
        expect(Result<int>.error(Exception()).isLoading, isFalse);
      });

      test('hasError is true only for error state', () {
        expect(Result<int>.initial().hasError, isFalse);
        expect(Result<int>.loading().hasError, isFalse);
        expect(Result.data(1).hasError, isFalse);
        expect(Result<int>.error(Exception()).hasError, isTrue);
      });

      test('hasValue is true only for data state', () {
        expect(Result<int>.initial().hasValue, isFalse);
        expect(Result<int>.loading().hasValue, isFalse);
        expect(Result.data(1).hasValue, isTrue);
        expect(Result<int>.error(Exception()).hasValue, isFalse);
      });
    });

    group('value getter', () {
      test('returns data when in data state', () {
        expect(Result.data(42).value, 42);
      });

      test('returns null in non-data states', () {
        expect(Result<int>.initial().value, isNull);
        expect(Result<int>.loading().value, isNull);
        expect(Result<int>.error(Exception()).value, isNull);
      });
    });

    group('errorValue getter', () {
      test('returns exception when in error state', () {
        final error = Exception('fail');
        expect(Result<int>.error(error).errorValue, error);
      });

      test('returns null in non-error states', () {
        expect(Result<int>.initial().errorValue, isNull);
        expect(Result<int>.loading().errorValue, isNull);
        expect(Result.data(1).errorValue, isNull);
      });
    });

    group('errorAs', () {
      test('returns custom exception when cast matches', () {
        final error = CustomException('fail');
        final result = Result<int>.error(error);
        expect(result.errorAs<CustomException>(), error);
      });

      test('returns null when cast does not match', () {
        final error = Exception('fail');
        final result = Result<int>.error(error);
        expect(result.errorAs<CustomException>(), isNull);
      });

      test('returns null in non-error states', () {
        expect(Result<int>.initial().errorAs<CustomException>(), isNull);
        expect(Result<int>.loading().errorAs<CustomException>(), isNull);
        expect(Result.data(1).errorAs<CustomException>(), isNull);
      });
    });

    group('cast getters', () {
      test('asData returns ResultData when in data state', () {
        final result = Result.data('x');
        expect(result.asData, isA<ResultData<String>>());
        expect(result.asData!.value, 'x');
      });

      test('asData returns null in non-data states', () {
        expect(Result<String>.initial().asData, isNull);
        expect(Result<String>.loading().asData, isNull);
        expect(Result<String>.error(Exception()).asData, isNull);
      });

      test('asError returns ResultError when in error state', () {
        final error = Exception('e');
        final result = Result<String>.error(error);
        expect(result.asError, isA<ResultError<String>>());
        expect(result.asError!.error, error);
      });

      test('asError returns null in non-error states', () {
        expect(Result<String>.initial().asError, isNull);
        expect(Result<String>.loading().asError, isNull);
        expect(Result.data('x').asError, isNull);
      });

      test('asLoading returns ResultLoading when loading', () {
        expect(Result<String>.loading().asLoading, isA<ResultLoading<String>>());
      });

      test('asLoading returns null in non-loading states', () {
        expect(Result<String>.initial().asLoading, isNull);
        expect(Result.data('x').asLoading, isNull);
        expect(Result<String>.error(Exception()).asLoading, isNull);
      });
    });

    group('pattern matching', () {
      test('when dispatches to correct branch', () {
        expect(
          Result.data(1).when(
            initial: () => 'initial',
            loading: () => 'loading',
            data: (v) => 'data:$v',
            error: (_) => 'error',
          ),
          'data:1',
        );

        expect(
          Result<int>.loading().when(
            initial: () => 'initial',
            loading: () => 'loading',
            data: (v) => 'data:$v',
            error: (_) => 'error',
          ),
          'loading',
        );

        expect(
          Result<int>.error(Exception('x')).when(
            initial: () => 'initial',
            loading: () => 'loading',
            data: (v) => 'data:$v',
            error: (_) => 'error',
          ),
          'error',
        );
      });
    });
  });

  group('ValueResult', () {
    group('constructors', () {
      test('success creates ValueResultSuccess', () {
        final r = ValueResult.success(42);
        expect(r, isA<ValueResultSuccess<int>>());
      });

      test('failure creates ValueResultFailure', () {
        final r = ValueResult<int>.failure(Exception('fail'));
        expect(r, isA<ValueResultFailure<int>>());
      });
    });

    group('boolean getters', () {
      test('isSuccess / isFailure are mutually exclusive', () {
        final ok = ValueResult.success(1);
        expect(ok.isSuccess, isTrue);
        expect(ok.isFailure, isFalse);

        final fail = ValueResult<int>.failure(Exception());
        expect(fail.isSuccess, isFalse);
        expect(fail.isFailure, isTrue);
      });
    });

    group('data getter', () {
      test('returns data on success', () {
        expect(ValueResult.success('x').data, 'x');
      });

      test('returns null on failure', () {
        expect(ValueResult<String>.failure(Exception()).data, isNull);
      });
    });

    group('failure getter', () {
      test('returns exception on failure', () {
        final error = Exception('err');
        expect(ValueResult<int>.failure(error).failure, error);
      });

      test('returns null on success', () {
        expect(ValueResult.success(1).failure, isNull);
      });
    });

    group('errorAs', () {
      test('returns custom exception when cast matches', () {
        final error = CustomException('fail');
        final r = ValueResult<int>.failure(error);
        expect(r.errorAs<CustomException>(), error);
      });

      test('returns null when cast does not match', () {
        final error = Exception('fail');
        final r = ValueResult<int>.failure(error);
        expect(r.errorAs<CustomException>(), isNull);
      });

      test('returns null on success', () {
        expect(ValueResult.success(1).errorAs<CustomException>(), isNull);
      });
    });

    group('cast getters', () {
      test('asSuccess returns ValueResultSuccess', () {
        expect(ValueResult.success(1).asSuccess, isA<ValueResultSuccess<int>>());
        expect(ValueResult<int>.failure(Exception()).asSuccess, isNull);
      });

      test('asFailure returns ValueResultFailure', () {
        expect(ValueResult<int>.failure(Exception()).asFailure, isA<ValueResultFailure<int>>());
        expect(ValueResult.success(1).asFailure, isNull);
      });
    });
  });
}
