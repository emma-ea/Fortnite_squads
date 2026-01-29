import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../config/api_config.dart';
import 'interceptors/auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // [cite: 223]
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('network: $obj'), // Simple logger for dev
      ),
    ]); // [cite: 224]

    return dio;
  }
}