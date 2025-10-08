import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class AuthService {
  // Login
  static Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Registro
  static Future<ApiResponse<User>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      );

      final data = json.decode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Obtener perfil
  static Future<ApiResponse<User>> getProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}&email=$email'),
        headers: ApiConfig.defaultHeaders,
      );

      final data = json.decode(response.body);
      final apiResponse = ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Probar conexión
  static Future<ApiResponse<Map<String, dynamic>>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.testEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      final data = json.decode(response.body);
      return ApiResponse.fromJson(data, (json) => json as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }
}