class ApiConfig {
  // URL del servidor real
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net';

  // Endpoints
  static const String loginEndpoint = '/api/auth.php?action=login';
  static const String registerEndpoint = '/api/auth.php?action=register';
  static const String profileEndpoint = '/api/auth.php?action=profile';
  static const String testEndpoint = '/api/test.php';

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
