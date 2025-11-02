import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/grade_model.dart';

class GradesApiService {
  final String _baseUrl = ApiConfig.baseUrl;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Profesor guarda/actualiza notas de un estudiante
  Future<Grade> saveGrade({
    required int estudianteId,
    required int materiaId,
    required int profesorId,
    required String anioAcademico,
    double? nota1,
    double? nota2,
    double? nota3,
    double? nota4,
  }) async {
    try {
      print('📝 DEBUG GradesApiService.saveGrade: Guardando notas...');
      print(
          '   Estudiante ID: $estudianteId, Materia ID: $materiaId, Profesor ID: $profesorId');
      print('   Notas: $nota1, $nota2, $nota3, $nota4');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/notas.php?action=guardar'),
        headers: _headers,
        body: jsonEncode({
          'estudiante_id': estudianteId,
          'materia_id': materiaId,
          'profesor_id': profesorId,
          'año_academico': anioAcademico,
          'nota_1': nota1,
          'nota_2': nota2,
          'nota_3': nota3,
          'nota_4': nota4,
        }),
      );

      print('📝 DEBUG GradesApiService.saveGrade: Request Body: ${jsonEncode({
            'estudiante_id': estudianteId,
            'materia_id': materiaId,
            'profesor_id': profesorId,
            'año_academico': anioAcademico,
            'nota_1': nota1,
            'nota_2': nota2,
            'nota_3': nota3,
            'nota_4': nota4,
          })}');
      print(
          '📝 DEBUG GradesApiService.saveGrade: Status Code: ${response.statusCode}');
      print(
          '📝 DEBUG GradesApiService.saveGrade: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          // Manejar diferentes formatos de respuesta
          Map<String, dynamic> gradeData;
          if (data is Map<String, dynamic>) {
            gradeData = data;
          } else {
            // Si data no es un Map, construir uno con los datos que tenemos
            gradeData = {
              'estudiante_id': estudianteId,
              'materia_id': materiaId,
              'profesor_id': profesorId,
              'año_academico': anioAcademico,
              'nota_1': nota1,
              'nota_2': nota2,
              'nota_3': nota3,
              'nota_4': nota4,
            };
            // Si hay un ID en la respuesta, agregarlo
            if (data != null) {
              gradeData['id'] = data;
            }
          }
          
          print(
              '✅ DEBUG GradesApiService.saveGrade: Notas guardadas exitosamente');
          print('   Datos parseados: $gradeData');
          return Grade.fromJson(gradeData);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al guardar notas');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR GradesApiService.saveGrade: $e');
      print('   Stack trace: $stackTrace');
      // Si es un error de tipo, proporcionar un mensaje más claro
      if (e.toString().contains('type') && e.toString().contains('subtype')) {
        throw Exception('Error de tipo al procesar respuesta del servidor. Intenta guardar nuevamente.');
      }
      rethrow;
    }
  }

  /// Obtener notas de un estudiante en una materia específica
  Future<Grade?> getStudentGradeInMatter({
    required int estudianteId,
    required int materiaId,
    String? anioAcademico,
  }) async {
    try {
      print(
          '📝 DEBUG GradesApiService.getStudentGradeInMatter: Obteniendo notas del estudiante...');

      String url =
          '$_baseUrl/api/notas.php?action=obtener_estudiante&estudiante_id=$estudianteId&materia_id=$materiaId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print(
          '📝 DEBUG GradesApiService.getStudentGradeInMatter: Status Code: ${response.statusCode}');
      print(
          '📝 DEBUG GradesApiService.getStudentGradeInMatter: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];

          if (data != null) {
            print(
                '✅ DEBUG GradesApiService.getStudentGradeInMatter: Notas encontradas');
            return Grade.fromJson(data);
          } else {
            print(
                '⚠️ DEBUG GradesApiService.getStudentGradeInMatter: No hay notas para este estudiante');
            return null;
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener notas');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR GradesApiService.getStudentGradeInMatter: $e');
      rethrow;
    }
  }

  /// Profesor obtiene todas las notas de sus estudiantes en una materia
  Future<List<Grade>> getMatterGrades({
    required int materiaId,
    required int profesorId,
    String? anioAcademico,
  }) async {
    try {
      print(
          '📝 DEBUG GradesApiService.getMatterGrades: Obteniendo notas de la materia...');

      String url =
          '$_baseUrl/api/notas.php?action=obtener_materia&materia_id=$materiaId&profesor_id=$profesorId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print(
          '📝 DEBUG GradesApiService.getMatterGrades: Status Code: ${response.statusCode}');
      print(
          '📝 DEBUG GradesApiService.getMatterGrades: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];

          print(
              '🔧 DEBUG GradesApiService.getMatterGrades: data type = ${data.runtimeType}');
          print(
              '🔧 DEBUG GradesApiService.getMatterGrades: data keys = ${data is Map ? data.keys.toList() : "no es Map"}');

          if (data is Map<String, dynamic> && data['notas'] != null) {
            // El endpoint retorna: { "data": { "materia_id": 3, "notas": [...] } }
            final notasList = data['notas'] as List;
            print(
                '✅ DEBUG GradesApiService.getMatterGrades: ${notasList.length} notas encontradas en data["notas"]');
            return notasList.map((json) => Grade.fromJson(json)).toList();
          } else if (data is List) {
            // Fallback: si data es directamente una lista
            print(
                '✅ DEBUG GradesApiService.getMatterGrades: ${data.length} notas encontradas (data es List)');
            return data.map((json) => Grade.fromJson(json)).toList();
          } else {
            print(
                '⚠️ DEBUG GradesApiService.getMatterGrades: No hay notas en esta materia');
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener notas de la materia');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR GradesApiService.getMatterGrades: $e');
      rethrow;
    }
  }

  /// Estudiante obtiene todas sus notas de todas sus materias
  Future<List<Grade>> getAllStudentGrades({
    required int estudianteId,
    String? anioAcademico,
  }) async {
    try {
      print(
          '📝 DEBUG GradesApiService.getAllStudentGrades: Obteniendo todas las notas del estudiante...');

      String url =
          '$_baseUrl/api/notas.php?action=obtener_todas&estudiante_id=$estudianteId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print(
          '📝 DEBUG GradesApiService.getAllStudentGrades: Status Code: ${response.statusCode}');
      print(
          '📝 DEBUG GradesApiService.getAllStudentGrades: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];

          print(
              '🔧 DEBUG GradesApiService.getAllStudentGrades: data type = ${data.runtimeType}');
          
          List<dynamic> notasList = [];
          
          if (data is List) {
            // Si data es directamente una lista
            notasList = data;
            print(
                '✅ DEBUG GradesApiService.getAllStudentGrades: ${notasList.length} notas encontradas (data es List)');
          } else if (data is Map<String, dynamic>) {
            // Si data es un objeto que contiene una lista de notas
            if (data['notas'] != null && data['notas'] is List) {
              notasList = data['notas'] as List;
              print(
                  '✅ DEBUG GradesApiService.getAllStudentGrades: ${notasList.length} notas encontradas en data["notas"]');
              print(
                  '   Estudiante ID: ${data['estudiante_id']}, Año: ${data['año_academico']}, Promedio general: ${data['promedio_general']}');
            } else {
              print(
                  '⚠️ DEBUG GradesApiService.getAllStudentGrades: data es Map pero no contiene "notas" o no es una lista');
              print('   Keys disponibles en data: ${data.keys.toList()}');
              return [];
            }
          } else {
            print(
                '⚠️ DEBUG GradesApiService.getAllStudentGrades: data tiene tipo inesperado: ${data.runtimeType}');
            return [];
          }

          if (notasList.isNotEmpty) {
            return notasList.map((json) => Grade.fromJson(json)).toList();
          } else {
            print(
                '⚠️ DEBUG GradesApiService.getAllStudentGrades: La lista de notas está vacía');
            return [];
          }
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Error al obtener todas las notas');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR GradesApiService.getAllStudentGrades: $e');
      rethrow;
    }
  }
}
