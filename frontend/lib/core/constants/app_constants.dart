class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const int timeoutSeconds = 30;
  
  // Theme Constants
  static const double borderRadius = 12.0;
  static const double defaultPadding = 16.0;
}
