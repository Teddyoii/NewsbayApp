import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/core/network/api_client.dart';

void main() {
  late ApiClient client;
  final requestOptions = RequestOptions(path: '/test');

  setUp(() {
    client = ApiClient();
  });

  group('mapDioException — connectivity errors', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('mapDioException_${type}_returnsNetworkException', () {
        final result = client.mapDioException(
          DioException(requestOptions: requestOptions, type: type),
        );

        expect(result, isA<NetworkException>());
      });
    }
  });

  group('mapDioException — bad response', () {
    test('mapDioException_status400_returnsInvalidCredentialsException', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 400,
            data: {'message': 'Invalid credentials'},
          ),
        ),
      );

      expect(result, isA<InvalidCredentialsException>());
      expect(
          (result as InvalidCredentialsException).message, 'Invalid credentials');
    });

    test('mapDioException_status401_returnsInvalidCredentialsException', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: requestOptions, statusCode: 401),
        ),
      );

      expect(result, isA<InvalidCredentialsException>());
    });

    test('mapDioException_status500_returnsServerExceptionWithStatusCode', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
            data: {'message': 'Internal error'},
          ),
        ),
      );

      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 500);
      expect(result.message, 'Internal error');
    });

    test('mapDioException_badResponseWithoutMessageBody_usesFallbackMessage',
        () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: requestOptions, statusCode: 503),
        ),
      );

      expect(result, isA<ServerException>());
      expect((result as ServerException).message, contains('503'));
    });
  });

  group('mapDioException — other types', () {
    test('mapDioException_cancel_returnsServerException', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.cancel,
        ),
      );

      expect(result, isA<ServerException>());
    });

    test('mapDioException_unknown_returnsNetworkException', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.unknown,
        ),
      );

      expect(result, isA<NetworkException>());
    });

    test('mapDioException_badCertificate_returnsNetworkException', () {
      final result = client.mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badCertificate,
        ),
      );

      expect(result, isA<NetworkException>());
    });
  });
}
