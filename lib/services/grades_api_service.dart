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
      print('   Estudiante ID: $estudianteId, Materia ID: $materiaId');
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

      print('📝 DEBUG GradesApiService.saveGrade: Status Code: ${response.statusCode}');
      print('📝 DEBUG GradesApiService.saveGrade: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          print('✅ DEBUG GradesApiService.saveGrade: Notas guardadas exitosamente');
          return Grade.fromJson(data);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al guardar notas');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR GradesApiService.saveGrade: $e');
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
      print('📝 DEBUG GradesApiService.getStudentGradeInMatter: Obteniendo notas del estudiante...');
      
      String url = '$_baseUrl/api/notas.php?action=obtener_estudiante&estudiante_id=$estudianteId&materia_id=$materiaId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📝 DEBUG GradesApiService.getStudentGradeInMatter: Status Code: ${response.statusCode}');
      print('📝 DEBUG GradesApiService.getStudentGradeInMatter: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          if (data != null) {
            print('✅ DEBUG GradesApiService.getStudentGradeInMatter: Notas encontradas');
            return Grade.fromJson(data);
          } else {
            print('⚠️ DEBUG GradesApiService.getStudentGradeInMatter: No hay notas para este estudiante');
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
      print('📝 DEBUG GradesApiService.getMatterGrades: Obteniendo notas de la materia...');
      
      String url = '$_baseUrl/api/notas.php?action=obtener_materia&materia_id=$materiaId&profesor_id=$profesorId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📝 DEBUG GradesApiService.getMatterGrades: Status Code: ${response.statusCode}');
      print('📝 DEBUG GradesApiService.getMatterGrades: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          if (data is List) {
            print('✅ DEBUG GradesApiService.getMatterGrades: ${data.length} notas encontradas');
            return data.map((json) => Grade.fromJson(json)).toList();
          } else {
            print('⚠️ DEBUG GradesApiService.getMatterGrades: No hay notas en esta materia');
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener notas de la materia');
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
      print('📝 DEBUG GradesApiService.getAllStudentGrades: Obteniendo todas las notas del estudiante...');
      
      String url = '$_baseUrl/api/notas.php?action=obtener_todas&estudiante_id=$estudianteId';
      if (anioAcademico != null) {
        url += '&año_academico=$anioAcademico';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📝 DEBUG GradesApiService.getAllStudentGrades: Status Code: ${response.statusCode}');
      print('📝 DEBUG GradesApiService.getAllStudentGrades: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          if (data is List) {
            print('✅ DEBUG GradesApiService.getAllStudentGrades: ${data.length} notas encontradas');
            return data.map((json) => Grade.fromJson(json)).toList();
          } else {
            print('⚠️ DEBUG GradesApiService.getAllStudentGrades: No hay notas');
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener todas las notas');
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

