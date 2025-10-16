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
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Obteniendo profesores desde API...');

      final response = await http.get(
        Uri.parse('$teachersEndpoint?action=teachers'),
        headers: _headers,
      );

      debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Status Code: ${response.statusCode}');
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Response Body: ${response.body}');
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: URL: ${Uri.parse('$teachersEndpoint?action=teachers')}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Respuesta completa: $jsonResponse');

        if (jsonResponse['success'] == true) {
          final List<dynamic> teachersData = jsonResponse['data'] ?? [];
          final teachers = teachersData.map((data) => Teacher.fromJson(data)).toList();

          debugPrint('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: ${teachers.length} profesores cargados');
          return teachers;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Error al obtener profesores');
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
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getTeacherById: Obteniendo profesor con ID: $id');

      final response = await http.get(
        Uri.parse('$teachersEndpoint?action=teachers&id=$id'),
        headers: _headers,
      );

      debugPrint('👨‍🏫 DEBUG TeacherApiService.getTeacherById: Status Code: ${response.statusCode}');
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getTeacherById: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
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
      debugPrint('👨‍🏫 DEBUG TeacherApiService.getActiveTeachers: Obteniendo profesores activos...');

      final teachers = await getAllTeachers();
      final activeTeachers = teachers.where((teacher) => teacher.isActive).toList();

      debugPrint('👨‍🏫 DEBUG TeacherApiService.getActiveTeachers: ${activeTeachers.length} profesores activos encontrados');
      return activeTeachers;
    } catch (e) {
      debugPrint('❌ ERROR TeacherApiService.getActiveTeachers: $e');
      rethrow;
    }
  }
}