import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';
import 'enrollment_api_service.dart';

class StudentSubjectService {
  static const String _baseUrl = 'https://hermanosfrios.alwaysdata.net/api';

  // Headers para las peticiones
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Obtener materias inscritas de un estudiante
  Future<List<Subject>> getStudentSubjects(int userId) async {
    try {
      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjects: Obteniendo materias del estudiante: $userId');

      // Usar vista_estudiantes_materias.php y filtrar por estudiante
      final response = await http.get(
        Uri.parse('$_baseUrl/vista_estudiantes_materias.php'),
        headers: _headers,
      );

      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjects: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjects: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // La estructura es: data: { materias: [...] }
          final Map<String, dynamic>? data = jsonResponse['data'];
          final List<dynamic> allMateriasData = data?['materias'] ?? [];

          // Obtener el estudiante_id del usuario_id
          final enrollmentService = EnrollmentApiService();
          final studentId =
              await enrollmentService.getStudentIdByUserId(userId);

          if (studentId == null) {
            debugPrint(
                '⚠️ DEBUG StudentSubjectService.getStudentSubjects: No se encontró estudiante_id para usuario_id: $userId');
            return [];
          }

          debugPrint(
              '📚 DEBUG StudentSubjectService.getStudentSubjects: Estudiante_id encontrado: $studentId');

          // Filtrar materias que contengan este estudiante_id en su lista de estudiantes
          final List<Subject> subjects = [];

          for (var materiaData in allMateriasData) {
            // Verificar si esta materia tiene estudiantes inscritos
            if (materiaData['estudiantes'] != null) {
              final List<dynamic> estudiantes = materiaData['estudiantes'];
              // Buscar si este estudiante está en la lista
              final hasStudent = estudiantes.any((est) =>
                  (est['estudiante_id'] == studentId ||
                      est['usuario_id'] == userId) &&
                  est['estado_inscripcion'] == 'activo');

              if (hasStudent) {
                try {
                  final subject = Subject.fromJson(materiaData);
                  subjects.add(subject);
                } catch (e) {
                  debugPrint(
                      '⚠️ DEBUG StudentSubjectService.getStudentSubjects: Error parseando materia ${materiaData['materia_id']}: $e');
                }
              }
            }
          }

          debugPrint(
              '📚 DEBUG StudentSubjectService.getStudentSubjects: ${subjects.length} materias encontradas para el estudiante');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener materias del estudiante');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR StudentSubjectService.getStudentSubjects: $e');
      rethrow;
    }
  }

  // Obtener materias inscritas usando la vista de la base de datos
  Future<List<Subject>> getStudentSubjectsFromView(int userId) async {
    try {
      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjectsFromView: Obteniendo materias del estudiante: $userId');

      // Usar el endpoint correcto sin parámetros de acción
      final response = await http.get(
        Uri.parse('$_baseUrl/vista_estudiantes_materias.php'),
        headers: _headers,
      );

      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjectsFromView: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG StudentSubjectService.getStudentSubjectsFromView: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // La estructura es: data: { materias: [...] }
          final Map<String, dynamic>? data = jsonResponse['data'];
          final List<dynamic> subjectsData = data?['materias'] ?? [];

          final subjects =
              subjectsData.map((data) => Subject.fromJson(data)).toList();

          debugPrint(
              '📚 DEBUG StudentSubjectService.getStudentSubjectsFromView: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener materias del estudiante');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(
          '❌ ERROR StudentSubjectService.getStudentSubjectsFromView: $e');
      rethrow;
    }
  }

  // Obtener materias por materia específica
  Future<List<Subject>> getSubjectsByMateria(int materiaId) async {
    try {
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByMateria: Obteniendo materias por materia ID: $materiaId');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/vista_estudiantes_materias.php?materia_id=$materiaId'),
        headers: _headers,
      );

      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByMateria: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByMateria: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // La estructura es: data: { materias: [...] }
          final Map<String, dynamic>? data = jsonResponse['data'];
          final List<dynamic> subjectsData = data?['materias'] ?? [];

          final subjects =
              subjectsData.map((data) => Subject.fromJson(data)).toList();

          debugPrint(
              '📚 DEBUG StudentSubjectService.getSubjectsByMateria: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener materias por materia');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR StudentSubjectService.getSubjectsByMateria: $e');
      rethrow;
    }
  }

  // Obtener materias por profesor específico
  Future<List<Subject>> getSubjectsByProfesor(int profesorId) async {
    try {
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByProfesor: Obteniendo materias por profesor ID: $profesorId');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/vista_estudiantes_materias.php?profesor_id=$profesorId'),
        headers: _headers,
      );

      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByProfesor: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsByProfesor: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // La estructura es: data: { materias: [...] }
          final Map<String, dynamic>? data = jsonResponse['data'];
          final List<dynamic> subjectsData = data?['materias'] ?? [];

          final subjects =
              subjectsData.map((data) => Subject.fromJson(data)).toList();

          debugPrint(
              '📚 DEBUG StudentSubjectService.getSubjectsByProfesor: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener materias por profesor');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR StudentSubjectService.getSubjectsByProfesor: $e');
      rethrow;
    }
  }

  // Obtener materias con filtros combinados
  Future<List<Subject>> getSubjectsWithFilters({
    int? materiaId,
    int? profesorId,
  }) async {
    try {
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsWithFilters: Obteniendo materias con filtros - materiaId: $materiaId, profesorId: $profesorId');

      String url = '$_baseUrl/vista_estudiantes_materias.php';
      List<String> params = [];

      if (materiaId != null) {
        params.add('materia_id=$materiaId');
      }
      if (profesorId != null) {
        params.add('profesor_id=$profesorId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsWithFilters: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG StudentSubjectService.getSubjectsWithFilters: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // La estructura es: data: { materias: [...] }
          final Map<String, dynamic>? data = jsonResponse['data'];
          final List<dynamic> subjectsData = data?['materias'] ?? [];

          final subjects =
              subjectsData.map((data) => Subject.fromJson(data)).toList();

          debugPrint(
              '📚 DEBUG StudentSubjectService.getSubjectsWithFilters: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener materias con filtros');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR StudentSubjectService.getSubjectsWithFilters: $e');
      rethrow;
    }
  }
}
