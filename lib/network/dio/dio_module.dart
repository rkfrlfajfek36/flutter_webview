import 'package:dio/dio.dart';
import 'package:flutter_webview/network/interceptor/common_interceptor.dart';

class DioModule {
  DioModule._();

  static Dio getDio({BaseOptions? options}) {
    Dio dio;
    if (options == null) {
      dio = Dio(_getBaseOptions());
    } else {
      dio = Dio(options);
    }
    dio.interceptors.add(CommonInterceptor());
    return dio;
  }

  static BaseOptions _getBaseOptions() {
    return BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      // headers: // default header
    );
  }

  static BaseOptions getLongTimeoutOptions() {
    return BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      // headers: // default header
    );
  }
}
