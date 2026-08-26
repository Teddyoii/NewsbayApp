import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';


class ApiClient {
  final Dio _dio;

  String? Function()? tokenProvider;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout:
                    const Duration(milliseconds: AppConfig.connectTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConfig.receiveTimeoutMs),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      return _asMap(response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _asMap(response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Map<String, dynamic> _asMap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ParsingException();
  }


  @visibleForTesting
  Exception mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final serverMessage = (data is Map && data['message'] is String)
            ? data['message'] as String
            : 'Server error ($statusCode).';
        if (statusCode == 400 || statusCode == 401) {
          return InvalidCredentialsException(serverMessage);
        }
        return ServerException(serverMessage, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const ServerException('Request cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
      default:
        return const NetworkException();
    }
  }
}
