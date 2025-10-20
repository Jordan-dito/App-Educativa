import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/teacher_model.dart';

class TeacherApiService {
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net/api';
  static const String teachersEndpoint = '$baseUrl/auth.php';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Obtener todos los profesores
  Future<List<Teacher>> getAllTeachers() async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Obteniendo profesores desde API...');

      final response = await http.get(
        Uri.parse('$teachersEndpoint?action=teachers'),
        headers: _headers,
      );

      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Status Code: ${response.statusCode}');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Response Body: ${response.body}');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: URL: ${Uri.parse('$teachersEndpoint?action=teachers')}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        debugPrint(
            '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Respuesta completa: $jsonResponse');

        if (jsonResponse['success'] == true) {
          final List<dynamic> teachersData = jsonResponse['data'] ?? [];
          final teachers =
              teachersData.map((data) => Teacher.fromJson(data)).toList();

          debugPrint(
              '👨‍🏫 DEBUG TeacherApiService.getAllTeachers: ${teachers.length} profesores cargados');
          return teachers;
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Error al obtener profesores');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.getAllTeachers: $e');
      rethrow;
    }
  }

  // Obtener profesor por ID
  Future<Teacher?> getTeacherById(String id) async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getTeacherById: Obteniendo profesor con ID: $id');

      final response = await http.get(
        Uri.parse('$teachersEndpoint?action=teachers&id=$id'),
        headers: _headers,
      );

      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getTeacherById: Status Code: ${response.statusCode}');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getTeacherById: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data'].isNotEmpty) {
          return Teacher.fromJson(jsonResponse['data'][0]);
        } else {
          return null;
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.getTeacherById: $e');
      rethrow;
    }
  }

  // Obtener profesores activos
  Future<List<Teacher>> getActiveTeachers() async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getActiveTeachers: Obteniendo profesores activos...');

      final teachers = await getAllTeachers();
      final activeTeachers =
          teachers.where((teacher) => teacher.isActive).toList();

      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.getActiveTeachers: ${activeTeachers.length} profesores activos encontrados');
      return activeTeachers;
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.getActiveTeachers: $e');
      rethrow;
    }
  }

  // Actualizar profesor existente
  Future<bool> updateTeacher(
      int profesorId, Map<String, dynamic> teacherData) async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.updateTeacher: Actualizando profesor con ID: $profesorId');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.updateTeacher: Datos a enviar: $teacherData');

      final response = await http.put(
        Uri.parse('$teachersEndpoint?action=edit-teacher'),
        headers: _headers,
        body: json.encode({
          'profesor_id': profesorId,
          'nombre': teacherData['nombre'] ?? '',
          'apellido': teacherData['apellido'] ?? '',
          'telefono': teacherData['telefono'] ?? '',
          'direccion': teacherData['direccion'] ?? '',
          'fecha_contratacion': teacherData['fecha_contratacion'] ?? '',
        }),
      );

      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.updateTeacher: Status Code: ${response.statusCode}');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.updateTeacher: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          debugPrint(
              '👨‍🏫 DEBUG TeacherApiService.updateTeacher: Profesor actualizado exitosamente');
          return true;
        } else {
          debugPrint(
              '❌ ERROR TeacherApiService.updateTeacher: ${jsonResponse['message']}');
          throw Exception(
              jsonResponse['message'] ?? 'Error al actualizar profesor');
        }
      } else {
        debugPrint(
            '❌ ERROR TeacherApiService.updateTeacher: Error HTTP ${response.statusCode}');
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.updateTeacher: $e');
      rethrow;
    }
  }

  // Eliminar profesor
  Future<bool> deleteTeacher(int profesorId) async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.deleteTeacher: Eliminando profesor con ID: $profesorId');

      final response = await http.delete(
        Uri.parse(
            '$teachersEndpoint?action=delete-teacher&profesor_id=$profesorId'),
        headers: _headers,
      );

      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.deleteTeacher: Status Code: ${response.statusCode}');
      debugPrint(
          '👨‍🏫 DEBUG TeacherApiService.deleteTeacher: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          debugPrint(
              '👨‍🏫 DEBUG TeacherApiService.deleteTeacher: Profesor eliminado exitosamente');
          return true;
        } else {
          debugPrint(
              '❌ ERROR TeacherApiService.deleteTeacher: ${jsonResponse['message']}');
          throw Exception(
              jsonResponse['message'] ?? 'Error al eliminar profesor');
        }
      } else {
        debugPrint(
            '❌ ERROR TeacherApiService.deleteTeacher: Error HTTP ${response.statusCode}');
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.deleteTeacher: $e');
      rethrow;
    }
  }
}
