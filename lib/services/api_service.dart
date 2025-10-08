import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/colegio/colegio_api'; // Cambiar por tu URL del backend
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool includeAuth = true}) async {
    final headers = await getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.delete(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error del servidor');
    }
  }
}