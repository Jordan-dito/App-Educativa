import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';

class SubjectApiService {
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net/api';
  static const String subjectsEndpoint = '$baseUrl/materias.php';

  // Headers para las peticiones
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Obtener todas las materias
  Future<List<Subject>> getAllSubjects() async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.getAllSubjects: Obteniendo materias desde API...');
      
      final response = await http.get(
        Uri.parse('$subjectsEndpoint?action=all'),
        headers: _headers,
      );

      debugPrint('📚 DEBUG SubjectApiService.getAllSubjects: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.getAllSubjects: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        debugPrint('📚 DEBUG SubjectApiService.getAllSubjects: Respuesta completa: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> subjectsData = jsonResponse['data'] ?? [];
          final subjects = subjectsData.map((data) => Subject.fromJson(data)).toList();
          
          debugPrint('📚 DEBUG SubjectApiService.getAllSubjects: ${subjects.length} materias cargadas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener materias');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.getAllSubjects: $e');
      rethrow;
    }
  }

  // Obtener materia por ID
  Future<Subject?> getSubjectById(String id) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.getSubjectById: Obteniendo materia con ID: $id');
      
      final response = await http.get(
        Uri.parse('$subjectsEndpoint?action=all&id=$id'),
        headers: _headers,
      );

      debugPrint('📚 DEBUG SubjectApiService.getSubjectById: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.getSubjectById: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Subject.fromJson(jsonResponse['data']);
        } else {
          return null;
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.getSubjectById: $e');
      rethrow;
    }
  }

  // Crear nueva materia
  Future<Subject> createSubject(Subject subject) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.createSubject: Creando materia: ${subject.name}');
      
      final subjectData = {
        'nombre': subject.name,
        'grado': subject.grade,
        'seccion': subject.section,
        'profesor_id': subject.teacherId != null ? int.parse(subject.teacherId!) : null,
        'año_academico': subject.academicYear,
      };

      debugPrint('📚 DEBUG SubjectApiService.createSubject: Datos a enviar: $subjectData');

      final response = await http.post(
        Uri.parse('$subjectsEndpoint?action=create'),
        headers: _headers,
        body: json.encode(subjectData),
      );

      debugPrint('📚 DEBUG SubjectApiService.createSubject: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.createSubject: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final createdSubjectData = jsonResponse['data'];
          debugPrint('📚 DEBUG SubjectApiService.createSubject: Materia creada exitosamente');
          return Subject.fromJson(createdSubjectData);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al crear materia');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.createSubject: $e');
      rethrow;
    }
  }

  // Actualizar materia existente
  Future<Subject> updateSubject(Subject subject) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.updateSubject: Actualizando materia ID: ${subject.id}');
      
      final subjectData = {
        'materia_id': subject.id,
        'nombre': subject.name,
        'grado': subject.grade,
        'seccion': subject.section,
        'profesor_id': subject.teacherId != null ? int.parse(subject.teacherId!) : null,
        'año_academico': subject.academicYear,
      };

      debugPrint('📚 DEBUG SubjectApiService.updateSubject: Datos a enviar: $subjectData');

      final response = await http.put(
        Uri.parse('$subjectsEndpoint?action=update'),
        headers: _headers,
        body: json.encode(subjectData),
      );

      debugPrint('📚 DEBUG SubjectApiService.updateSubject: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.updateSubject: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final updatedSubjectData = jsonResponse['data'];
          debugPrint('📚 DEBUG SubjectApiService.updateSubject: Materia actualizada exitosamente');
          return Subject.fromJson(updatedSubjectData);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al actualizar materia');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.updateSubject: $e');
      rethrow;
    }
  }

  // Eliminar materia
  Future<bool> deleteSubject(String id) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.deleteSubject: Eliminando materia ID: $id');
      
      final requestData = {'materia_id': int.parse(id)};
      debugPrint('📚 DEBUG SubjectApiService.deleteSubject: Datos a enviar: $requestData');
      
      final response = await http.delete(
        Uri.parse('$subjectsEndpoint?action=delete'),
        headers: _headers,
        body: json.encode(requestData),
      );

      debugPrint('📚 DEBUG SubjectApiService.deleteSubject: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.deleteSubject: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          debugPrint('📚 DEBUG SubjectApiService.deleteSubject: Materia eliminada exitosamente');
          return true;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al eliminar materia');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.deleteSubject: $e');
      rethrow;
    }
  }

  // Obtener materias por profesor
  Future<List<Subject>> getSubjectsByTeacher(String teacherId) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByTeacher: Obteniendo materias del profesor: $teacherId');
      
      final response = await http.get(
        Uri.parse('$subjectsEndpoint?action=all&profesor_id=$teacherId'),
        headers: _headers,
      );

      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByTeacher: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByTeacher: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> subjectsData = jsonResponse['data'] ?? [];
          final subjects = subjectsData.map((data) => Subject.fromJson(data)).toList();
          
          debugPrint('📚 DEBUG SubjectApiService.getSubjectsByTeacher: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener materias del profesor');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.getSubjectsByTeacher: $e');
      rethrow;
    }
  }

  // Obtener materias por grado y nivel
  Future<List<Subject>> getSubjectsByGradeAndLevel(String grade, String level) async {
    try {
      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByGradeAndLevel: Grado: $grade, Nivel: $level');
      
      final response = await http.get(
        Uri.parse('$subjectsEndpoint?action=all&grado=$grade&nivel=$level'),
        headers: _headers,
      );

      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByGradeAndLevel: Status Code: ${response.statusCode}');
      debugPrint('📚 DEBUG SubjectApiService.getSubjectsByGradeAndLevel: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> subjectsData = jsonResponse['data'] ?? [];
          final subjects = subjectsData.map((data) => Subject.fromJson(data)).toList();
          
          debugPrint('📚 DEBUG SubjectApiService.getSubjectsByGradeAndLevel: ${subjects.length} materias encontradas');
          return subjects;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener materias por grado y nivel');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR SubjectApiService.getSubjectsByGradeAndLevel: $e');
      rethrow;
    }
  }
}
