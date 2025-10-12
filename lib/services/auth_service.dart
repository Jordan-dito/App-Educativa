import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class AuthService {
  // Login
  static Future<ApiResponse<User>> login(String email, String password) async {
    try {
      print('🔐 DEBUG AuthService.login: Iniciando login...');
      print('🔐 DEBUG AuthService.login: Email: $email');
      print(
          '🔐 DEBUG AuthService.login: URL: ${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

      final requestBody = {
        'email': email,
        'password': password,
      };
      print('🔐 DEBUG AuthService.login: Request body: $requestBody');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(requestBody),
      );

      print('🔐 DEBUG AuthService.login: Status code: ${response.statusCode}');
      print(
          '🔐 DEBUG AuthService.login: Response headers: ${response.headers}');
      print('🔐 DEBUG AuthService.login: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201) &&
          response.statusCode != 201) {
        print(
            '❌ DEBUG AuthService.login: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('🔐 DEBUG AuthService.login: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.login: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '🔐 DEBUG AuthService.login: ApiResponse success: ${apiResponse.success}');
      print(
          '🔐 DEBUG AuthService.login: ApiResponse message: ${apiResponse.message}');
      print(
          '🔐 DEBUG AuthService.login: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.login: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Registro
  static Future<ApiResponse<User>> register(
      Map<String, dynamic> userData) async {
    try {
      print('📝 DEBUG AuthService.register: Iniciando registro...');
      print(
          '📝 DEBUG AuthService.register: URL: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      print('📝 DEBUG AuthService.register: Request body: $userData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      );

      print(
          '📝 DEBUG AuthService.register: Status code: ${response.statusCode}');
      print(
          '📝 DEBUG AuthService.register: Response headers: ${response.headers}');
      print('📝 DEBUG AuthService.register: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.register: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('📝 DEBUG AuthService.register: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.register: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '📝 DEBUG AuthService.register: ApiResponse success: ${apiResponse.success}');
      print(
          '📝 DEBUG AuthService.register: ApiResponse message: ${apiResponse.message}');
      print(
          '📝 DEBUG AuthService.register: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.register: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Obtener perfil
  static Future<ApiResponse<User>> getProfile(String email) async {
    try {
      print(
          '👤 DEBUG AuthService.getProfile: Iniciando obtención de perfil...');
      print('👤 DEBUG AuthService.getProfile: Email: $email');
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}&email=$email';
      print('👤 DEBUG AuthService.getProfile: URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
      );

      print(
          '👤 DEBUG AuthService.getProfile: Status code: ${response.statusCode}');
      print(
          '👤 DEBUG AuthService.getProfile: Response headers: ${response.headers}');
      print('👤 DEBUG AuthService.getProfile: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.getProfile: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('👤 DEBUG AuthService.getProfile: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.getProfile: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '👤 DEBUG AuthService.getProfile: ApiResponse success: ${apiResponse.success}');
      print(
          '👤 DEBUG AuthService.getProfile: ApiResponse message: ${apiResponse.message}');
      print(
          '👤 DEBUG AuthService.getProfile: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.getProfile: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Registro de estudiante
  static Future<ApiResponse<User>> registerStudent(
      Map<String, dynamic> studentData) async {
    try {
      print(
          '🎓 DEBUG AuthService.registerStudent: Iniciando registro de estudiante...');
      print(
          '🎓 DEBUG AuthService.registerStudent: URL: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      print('🎓 DEBUG AuthService.registerStudent: Request body: $studentData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(studentData),
      );

      print(
          '🎓 DEBUG AuthService.registerStudent: Status code: ${response.statusCode}');
      print(
          '🎓 DEBUG AuthService.registerStudent: Response headers: ${response.headers}');
      print(
          '🎓 DEBUG AuthService.registerStudent: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.registerStudent: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('🎓 DEBUG AuthService.registerStudent: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.registerStudent: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '🎓 DEBUG AuthService.registerStudent: ApiResponse success: ${apiResponse.success}');
      print(
          '🎓 DEBUG AuthService.registerStudent: ApiResponse message: ${apiResponse.message}');
      print(
          '🎓 DEBUG AuthService.registerStudent: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.registerStudent: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Registro de profesor
  static Future<ApiResponse<User>> registerTeacher(
      Map<String, dynamic> teacherData) async {
    try {
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: Iniciando registro de profesor...');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: URL: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: Request body: $teacherData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(teacherData),
      );

      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: Status code: ${response.statusCode}');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: Response headers: ${response.headers}');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.registerTeacher: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('👨‍🏫 DEBUG AuthService.registerTeacher: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.registerTeacher: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: ApiResponse success: ${apiResponse.success}');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: ApiResponse message: ${apiResponse.message}');
      print(
          '👨‍🏫 DEBUG AuthService.registerTeacher: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.registerTeacher: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Probar conexión
  static Future<ApiResponse<Map<String, dynamic>>> testConnection() async {
    try {
      print(
          '🔗 DEBUG AuthService.testConnection: Iniciando prueba de conexión...');
      print(
          '🔗 DEBUG AuthService.testConnection: URL: ${ApiConfig.baseUrl}${ApiConfig.testEndpoint}');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.testEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      print(
          '🔗 DEBUG AuthService.testConnection: Status code: ${response.statusCode}');
      print(
          '🔗 DEBUG AuthService.testConnection: Response headers: ${response.headers}');
      print(
          '🔗 DEBUG AuthService.testConnection: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.testConnection: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('🔗 DEBUG AuthService.testConnection: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.testConnection: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse.fromJson(data, (json) => json as Map<String, dynamic>);

      print(
          '🔗 DEBUG AuthService.testConnection: ApiResponse success: ${apiResponse.success}');
      print(
          '🔗 DEBUG AuthService.testConnection: ApiResponse message: ${apiResponse.message}');
      print(
          '🔗 DEBUG AuthService.testConnection: ApiResponse data: ${apiResponse.data}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.testConnection: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }
}
