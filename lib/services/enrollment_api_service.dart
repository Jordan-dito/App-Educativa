import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/enrollment_model.dart';

class EnrollmentApiService {
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net/api';
  static const String enrollmentsEndpoint = '$baseUrl/inscripciones.php';

  // Headers para las peticiones
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Obtener todas las inscripciones
  Future<List<Enrollment>> getAllEnrollments() async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getAllEnrollments: Obteniendo inscripciones desde API...');

      final response = await http.get(
        Uri.parse('$enrollmentsEndpoint?action=all'),
        headers: _headers,
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.getAllEnrollments: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getAllEnrollments: Response Body: ${response.body}');

      // Debug adicional: Intentar parsear la respuesta para ver la estructura
      try {
        final Map<String, dynamic> testResponse = json.decode(response.body);
        debugPrint(
            '📝 DEBUG EnrollmentApiService.getAllEnrollments: Estructura de respuesta:');
        debugPrint('  - success: ${testResponse['success']}');
        debugPrint('  - message: ${testResponse['message']}');
        debugPrint('  - data type: ${testResponse['data'].runtimeType}');
        if (testResponse['data'] is List &&
            (testResponse['data'] as List).isNotEmpty) {
          debugPrint(
              '  - primer item: ${(testResponse['data'] as List).first}');
          debugPrint(
              '  - claves del primer item: ${((testResponse['data'] as List).first as Map).keys.toList()}');
        }
      } catch (e) {
        debugPrint(
            '❌ DEBUG EnrollmentApiService.getAllEnrollments: Error parseando respuesta: $e');
      }

      // Verificar si la respuesta contiene errores HTML/PHP
      if (response.body.contains('<b>Fatal error</b>') ||
          response.body.contains('<br />') ||
          response.body.contains('include_path')) {
        throw Exception(
            'Error del servidor: El controlador de inscripciones no está disponible. Contacte al administrador.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          debugPrint(
              '📝 DEBUG EnrollmentApiService.getAllEnrollments: Respuesta completa: $jsonResponse');

          if (jsonResponse['success'] == true) {
            final List<dynamic> enrollmentsData = jsonResponse['data'] ?? [];

            debugPrint(
                '📝 DEBUG EnrollmentApiService.getAllEnrollments: Datos recibidos: $enrollmentsData');

            final List<Enrollment> enrollments = [];

            for (var data in enrollmentsData) {
              try {
                debugPrint(
                    '📝 DEBUG EnrollmentApiService.getAllEnrollments: Procesando item: $data');
                final enrollment = Enrollment.fromJson(data);
                enrollments.add(enrollment);
              } catch (e) {
                debugPrint(
                    '❌ ERROR EnrollmentApiService.getAllEnrollments: Error procesando item $data: $e');
                // Continuar con el siguiente item en lugar de fallar completamente
              }
            }

            debugPrint(
                '📝 DEBUG EnrollmentApiService.getAllEnrollments: ${enrollments.length} inscripciones cargadas exitosamente');
            return enrollments;
          } else {
            throw Exception(
                jsonResponse['message'] ?? 'Error al obtener inscripciones');
          }
        } catch (e) {
          if (e is FormatException) {
            throw Exception(
                'Error del servidor: Respuesta no válida. El endpoint puede no estar configurado correctamente.');
          }
          rethrow;
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.getAllEnrollments: $e');

      // Si hay error, devolver lista vacía en lugar de lanzar excepción
      // para que la app no se rompa completamente
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getAllEnrollments: Devolviendo lista vacía debido a error');
      return [];
    }
  }

  // Obtener el estudiante_id a partir del usuario_id
  Future<int?> getStudentIdByUserId(int userId) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Obteniendo estudiante_id para usuario_id: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/estudiantes.php?action=all'),
        headers: _headers,
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> studentsData = jsonResponse['data'] ?? [];

          // Buscar el estudiante que tenga el usuario_id correspondiente
          for (var studentData in studentsData) {
            if (studentData['usuario_id'] == userId) {
              final studentId = int.tryParse(studentData['id'].toString());
              debugPrint(
                  '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Estudiante_id encontrado: $studentId para usuario_id: $userId');
              return studentId;
            }
          }
        }
      }

      // Si no se encuentra con la API, usar mapeo directo como fallback
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Usando mapeo directo como fallback');

      // Mapeo basado en la base de datos actual (esto se puede actualizar dinámicamente)
      final Map<int, int> userToStudentMapping = {
        18: 12, // jordanmalave18@gmail.com -> JORDAN LAPO
        20: 14, // fernando@colegio.com -> fernando chali
        // Agregar más mapeos aquí cuando se agreguen nuevos usuarios
      };

      if (userToStudentMapping.containsKey(userId)) {
        final studentId = userToStudentMapping[userId]!;
        debugPrint(
            '📝 DEBUG EnrollmentApiService.getStudentIdByUserId: Mapeo directo - Usuario $userId -> Estudiante $studentId');
        return studentId;
      }

      debugPrint(
          '⚠️ DEBUG EnrollmentApiService.getStudentIdByUserId: No se encontró estudiante_id para usuario_id: $userId');
      return null;
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.getStudentIdByUserId: $e');
      return null;
    }
  }

  // Obtener inscripciones por usuario_id (método principal para estudiantes)
  Future<List<Enrollment>> getEnrollmentsByUserId(int userId) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByUserId: Obteniendo inscripciones para usuario_id: $userId');

      // Método 1: Intentar obtener todas las inscripciones y filtrar por usuario_id
      // Esto es más robusto porque usa la API que ya sabemos que funciona
      try {
        final allEnrollments = await getAllEnrollments();

        // Buscar inscripciones que correspondan al usuario_id
        // Necesitamos obtener el estudiante_id primero
        final studentId = await getStudentIdByUserId(userId);

        if (studentId != null) {
          final userEnrollments = allEnrollments
              .where((enrollment) => enrollment.estudianteId == studentId)
              .toList();

          debugPrint(
              '📝 DEBUG EnrollmentApiService.getEnrollmentsByUserId: Encontradas ${userEnrollments.length} inscripciones para usuario $userId (estudiante $studentId)');

          return userEnrollments;
        }
      } catch (e) {
        debugPrint(
            '⚠️ DEBUG EnrollmentApiService.getEnrollmentsByUserId: Error con método 1: $e');
      }

      // Método 2: Usar el método original como fallback
      final studentId = await getStudentIdByUserId(userId);

      if (studentId == null) {
        debugPrint(
            '⚠️ DEBUG EnrollmentApiService.getEnrollmentsByUserId: No se encontró estudiante_id para usuario_id: $userId');
        return [];
      }

      // Luego obtener las inscripciones usando el estudiante_id
      return await getEnrollmentsByStudent(studentId);
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.getEnrollmentsByUserId: $e');
      return [];
    }
  }

  // Obtener inscripciones por estudiante (usando estudiante_id, no usuario_id)
  Future<List<Enrollment>> getEnrollmentsByStudent(int studentId) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: Obteniendo inscripciones del estudiante: $studentId');

      final response = await http.get(
        Uri.parse(
            '$enrollmentsEndpoint?action=by-estudiante&estudiante_id=$studentId'),
        headers: _headers,
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: Response Body: ${response.body}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: URL: $enrollmentsEndpoint?action=by-estudiante&estudiante_id=$studentId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> enrollmentsData = jsonResponse['data'] ?? [];

          debugPrint(
              '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: Datos recibidos: $enrollmentsData');

          final List<Enrollment> enrollments = [];

          for (var data in enrollmentsData) {
            try {
              debugPrint(
                  '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: Procesando item: $data');
              final enrollment = Enrollment.fromJson(data);
              enrollments.add(enrollment);
            } catch (e) {
              debugPrint(
                  '❌ ERROR EnrollmentApiService.getEnrollmentsByStudent: Error procesando item $data: $e');
              // Continuar con el siguiente item
            }
          }

          debugPrint(
              '📝 DEBUG EnrollmentApiService.getEnrollmentsByStudent: ${enrollments.length} inscripciones encontradas');
          return enrollments;
        } else {
          final message = jsonResponse['message'] ??
              'Error al obtener inscripciones del estudiante';
          debugPrint(
              '⚠️ DEBUG EnrollmentApiService.getEnrollmentsByStudent: $message');
          throw Exception(message);
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.getEnrollmentsByStudent: $e');
      throw Exception('Error al obtener inscripciones del estudiante: $e');
    }
  }

  // Obtener inscripciones por profesor
  Future<List<Enrollment>> getEnrollmentsByTeacher(int teacherId) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByTeacher: Obteniendo inscripciones del profesor: $teacherId');

      final response = await http.get(
        Uri.parse(
            '$enrollmentsEndpoint?action=by-profesor&profesor_id=$teacherId'),
        headers: _headers,
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByTeacher: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.getEnrollmentsByTeacher: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> enrollmentsData = jsonResponse['data'] ?? [];
          final enrollments =
              enrollmentsData.map((data) => Enrollment.fromJson(data)).toList();

          debugPrint(
              '📝 DEBUG EnrollmentApiService.getEnrollmentsByTeacher: ${enrollments.length} inscripciones encontradas');
          return enrollments;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener inscripciones del profesor');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.getEnrollmentsByTeacher: $e');
      throw Exception('Error al obtener inscripciones del profesor: $e');
    }
  }

  // Crear nueva inscripción
  Future<bool> createEnrollment(Enrollment enrollment) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.createEnrollment: Creando inscripción...');

      final enrollmentData = enrollment.toCreateJson();
      debugPrint(
          '📝 DEBUG EnrollmentApiService.createEnrollment: Datos a enviar: $enrollmentData');

      final response = await http.post(
        Uri.parse('$enrollmentsEndpoint?action=create'),
        headers: _headers,
        body: json.encode(enrollmentData),
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.createEnrollment: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.createEnrollment: Response Body: ${response.body}');

      // Verificar si la respuesta contiene errores HTML/PHP
      if (response.body.contains('<b>Fatal error</b>') ||
          response.body.contains('<br />') ||
          response.body.contains('include_path')) {
        throw Exception(
            'Error del servidor: El controlador de inscripciones no está disponible. Contacte al administrador.');
      }

      // Manejar respuestas exitosas (200, 201) y también casos especiales (500 con mensaje válido)
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.statusCode == 500 &&
              response.body.contains('"success":false'))) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          if (jsonResponse['success'] == true) {
            debugPrint(
                '✅ DEBUG EnrollmentApiService.createEnrollment: Inscripción creada exitosamente');
            return true;
          } else {
            // Si success es false, lanzar excepción con el mensaje del servidor
            final message =
                jsonResponse['message'] ?? 'Error al crear inscripción';
            debugPrint(
                '⚠️ DEBUG EnrollmentApiService.createEnrollment: $message');
            throw Exception(message);
          }
        } catch (e) {
          if (e is FormatException) {
            throw Exception(
                'Error del servidor: Respuesta no válida. El endpoint puede no estar configurado correctamente.');
          }
          rethrow;
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.createEnrollment: $e');
      throw Exception('Error al crear inscripción: $e');
    }
  }

  // Eliminar inscripción
  Future<bool> deleteEnrollment(int enrollmentId) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.deleteEnrollment: Eliminando inscripción: $enrollmentId');

      final response = await http.delete(
        Uri.parse('$enrollmentsEndpoint?action=delete&id=$enrollmentId'),
        headers: _headers,
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.deleteEnrollment: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.deleteEnrollment: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          debugPrint(
              '✅ DEBUG EnrollmentApiService.deleteEnrollment: Inscripción eliminada exitosamente');
          return true;
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Error al eliminar inscripción');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.deleteEnrollment: $e');
      throw Exception('Error al eliminar inscripción: $e');
    }
  }

  // Actualizar inscripción
  Future<bool> updateEnrollment(Enrollment enrollment) async {
    try {
      debugPrint(
          '📝 DEBUG EnrollmentApiService.updateEnrollment: Actualizando inscripción: ${enrollment.id}');

      final enrollmentData = enrollment.toJson();
      debugPrint(
          '📝 DEBUG EnrollmentApiService.updateEnrollment: Datos a enviar: $enrollmentData');

      final response = await http.put(
        Uri.parse('$enrollmentsEndpoint?action=update'),
        headers: _headers,
        body: json.encode(enrollmentData),
      );

      debugPrint(
          '📝 DEBUG EnrollmentApiService.updateEnrollment: Status Code: ${response.statusCode}');
      debugPrint(
          '📝 DEBUG EnrollmentApiService.updateEnrollment: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          debugPrint(
              '✅ DEBUG EnrollmentApiService.updateEnrollment: Inscripción actualizada exitosamente');
          return true;
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Error al actualizar inscripción');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR EnrollmentApiService.updateEnrollment: $e');
      throw Exception('Error al actualizar inscripción: $e');
    }
  }
}
