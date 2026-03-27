class AppConfig {
  // Override using:
  // flutter run --dart-define=BACKEND_BASE_URL=http://192.168.x.x:5000/api --dart-define=BACKEND_SOCKET_URL=http://192.168.x.x:5000
  // 10.0.2.2 works only for Android emulator, not physical phone.
  static const String baseUrl =
      String.fromEnvironment('BACKEND_BASE_URL', defaultValue: 'http://10.0.2.2:5000/api');
  static const String socketUrl =
      String.fromEnvironment('BACKEND_SOCKET_URL', defaultValue: 'http://10.0.2.2:5000');
}
