import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../network/auth_interceptor.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._dio, this._secureStorage) {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.responseType = ResponseType.json
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    
    _dio.interceptors.add(AuthInterceptor(_secureStorage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
