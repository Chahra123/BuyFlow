class AppConfig {
  /// For Android emulator use: http://10.0.2.2:9091
  /// For iOS simulator use: http://localhost:9091
  /// For a real device, replace with your PC IP: http://192.168.x.x:9091
  static const String baseUrl = String.fromEnvironment(
    'BUYFLOW_API_BASE_URL',
    defaultValue: 'http://192.168.0.139:9091',
  );
}
