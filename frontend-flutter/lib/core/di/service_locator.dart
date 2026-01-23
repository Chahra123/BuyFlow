import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => secureStorage);
  
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl(), sl()));

  // Core
  // sl.registerLazySingleton(() => NetworkInfo(sl()));

  // Features - Auth
  // Bloc/Provider
  // UseCases
  // Repository
  // Data Sources
}
