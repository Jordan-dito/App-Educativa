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

  // Obtener profesores
  static Future<ApiResponse<List<Map<String, dynamic>>>> getTeachers() async {
    try {
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: Iniciando obtención de profesores...');
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: URL: ${ApiConfig.baseUrl}${ApiConfig.teachersEndpoint}');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: Status code: ${response.statusCode}');
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: Response headers: ${response.headers}');
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.getTeachers: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('👨‍🏫 DEBUG AuthService.getTeachers: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.getTeachers: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<List<Map<String, dynamic>>>.fromJson(data, (json) {
        if (json is List) {
          return json.cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      });

      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: ApiResponse success: ${apiResponse.success}');
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: ApiResponse message: ${apiResponse.message}');
      print(
          '👨‍🏫 DEBUG AuthService.getTeachers: ApiResponse data length: ${apiResponse.data?.length ?? 0}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.getTeachers: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Obtener estudiantes
  static Future<ApiResponse<List<Map<String, dynamic>>>> getStudents() async {
    try {
      print(
          '🎓 DEBUG AuthService.getStudents: Iniciando obtención de estudiantes...');
      print(
          '🎓 DEBUG AuthService.getStudents: URL: ${ApiConfig.baseUrl}${ApiConfig.studentsEndpoint}');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.studentsEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      );

      print(
          '🎓 DEBUG AuthService.getStudents: Status code: ${response.statusCode}');
      print(
          '🎓 DEBUG AuthService.getStudents: Response headers: ${response.headers}');
      print(
          '🎓 DEBUG AuthService.getStudents: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.getStudents: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('🎓 DEBUG AuthService.getStudents: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.getStudents: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<List<Map<String, dynamic>>>.fromJson(data, (json) {
        if (json is List) {
          return json.cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      });

      print(
          '🎓 DEBUG AuthService.getStudents: ApiResponse success: ${apiResponse.success}');
      print(
          '🎓 DEBUG AuthService.getStudents: ApiResponse message: ${apiResponse.message}');
      print(
          '🎓 DEBUG AuthService.getStudents: ApiResponse data length: ${apiResponse.data?.length ?? 0}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.getStudents: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Editar estudiante
  static Future<ApiResponse<User>> editStudent(
      Map<String, dynamic> studentData) async {
    try {
      print(
          '✏️ DEBUG AuthService.editStudent: Iniciando edición de estudiante...');
      print('✏️ DEBUG AuthService.editStudent: Student data: $studentData');

      const url = '${ApiConfig.baseUrl}/api/auth.php?action=edit-student';
      print('✏️ DEBUG AuthService.editStudent: URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(studentData),
      );

      print(
          '✏️ DEBUG AuthService.editStudent: Status code: ${response.statusCode}');
      print(
          '✏️ DEBUG AuthService.editStudent: Response headers: ${response.headers}');
      print(
          '✏️ DEBUG AuthService.editStudent: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.editStudent: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('✏️ DEBUG AuthService.editStudent: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.editStudent: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse =
          ApiResponse<User>.fromJson(data, (json) => User.fromJson(json));

      print(
          '✏️ DEBUG AuthService.editStudent: ApiResponse success: ${apiResponse.success}');
      print(
          '✏️ DEBUG AuthService.editStudent: ApiResponse message: ${apiResponse.message}');
      print(
          '✏️ DEBUG AuthService.editStudent: ApiResponse data: ${apiResponse.data?.toJson()}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.editStudent: Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Eliminar estudiante
  static Future<ApiResponse<Map<String, dynamic>>> deleteStudent(
      int studentId) async {
    try {
      print(
          '🗑️ DEBUG AuthService.deleteStudent: Iniciando eliminación de estudiante...');
      print('🗑️ DEBUG AuthService.deleteStudent: Student ID: $studentId');

      const url = '${ApiConfig.baseUrl}/api/auth.php?action=delete-student';
      print('🗑️ DEBUG AuthService.deleteStudent: URL: $url');

      final requestBody = {
        'estudiante_id': studentId,
      };
      print('🗑️ DEBUG AuthService.deleteStudent: Request body: $requestBody');

      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(requestBody),
      );

      print(
          '🗑️ DEBUG AuthService.deleteStudent: Status code: ${response.statusCode}');
      print(
          '🗑️ DEBUG AuthService.deleteStudent: Response headers: ${response.headers}');
      print(
          '🗑️ DEBUG AuthService.deleteStudent: Response body: ${response.body}');

      if ((response.statusCode != 200 && response.statusCode != 201)) {
        print(
            '❌ DEBUG AuthService.deleteStudent: Error HTTP - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Error del servidor: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      print('🗑️ DEBUG AuthService.deleteStudent: Decoded data: $data');

      // Validar estructura de respuesta
      if (!data.containsKey('success')) {
        print(
            '❌ DEBUG AuthService.deleteStudent: Respuesta no contiene campo "success"');
        return ApiResponse(
          success: false,
          message: 'Formato de respuesta inválido: falta campo "success"',
        );
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          data, (json) => json as Map<String, dynamic>);

      print(
          '🗑️ DEBUG AuthService.deleteStudent: ApiResponse success: ${apiResponse.success}');
      print(
          '🗑️ DEBUG AuthService.deleteStudent: ApiResponse message: ${apiResponse.message}');
      print(
          '🗑️ DEBUG AuthService.deleteStudent: ApiResponse data: ${apiResponse.data}');

      return apiResponse;
    } catch (e) {
      print('❌ DEBUG AuthService.deleteStudent: Error: $e');
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
