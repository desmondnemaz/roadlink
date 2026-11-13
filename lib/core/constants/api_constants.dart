/// Centralised API configuration constants for the Roadlink Spring Boot backend.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the Roadlink REST API (override via `--dart-define=API_BASE_URL=...`).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// Default connection timeout duration.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Default send timeout duration.
  static const Duration sendTimeout = Duration(seconds: 15);
}

