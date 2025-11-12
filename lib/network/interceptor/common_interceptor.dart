import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class CommonInterceptor extends Interceptor {
  final Logger _logger = Logger();

  CommonInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logger.d('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    _logger.d('Data: ${options.data}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    _logger.e('Message: ${err.message}');
    _logger.e('Error: ${err.error}');

    // 네트워크 에러 처리
    if (_isNetworkError(err)) {
      _logger.w('⚠️ Network connection error detected');
    }

    handler.next(err);
  }

  bool _isNetworkError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    final error = err.error;
    if (error is SocketException) {
      return true;
    }

    final message = err.message?.toLowerCase() ?? '';
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket') ||
        message.contains('host lookup failed') ||
        message.contains('no address associated with hostname')) {
      return true;
    }

    return false;
  }
}
