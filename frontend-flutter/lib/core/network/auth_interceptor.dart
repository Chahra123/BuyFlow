import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(key: 'auth_token');
    print('AuthInterceptor: token read from storage: ${token != null ? "FOUND" : "NOT FOUND"}');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('AuthInterceptor: Error on ${err.requestOptions.path}: ${err.type} - ${err.message}');
    if (err.response != null) {
      print('AuthInterceptor: Status: ${err.response?.statusCode} Content: ${err.response?.data}');
    }

    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
          final response = await dio.post(ApiConstants.refreshToken, data: {'refreshToken': refreshToken});
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];
            
            await secureStorage.write(key: 'auth_token', value: newAccessToken);
            if (newRefreshToken != null) {
              await secureStorage.write(key: 'refresh_token', value: newRefreshToken);
            }
            
            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final cloneReq = await dio.request(
              options.path,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
              data: options.data,
              queryParameters: options.queryParameters,
            );
            
            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh failed, logout
          await secureStorage.delete(key: 'auth_token');
          await secureStorage.delete(key: 'refresh_token');
          // Ideally trigger a logout event in the app
        }
      }
    }
    super.onError(err, handler);
  }
}
