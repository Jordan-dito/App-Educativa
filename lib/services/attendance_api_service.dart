import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/subject_configuration_model.dart';
import '../models/attendance_model.dart';

class AttendanceApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ===== CONFIGURACIÓN DE MATERIAS =====

  /// Crear configuración de materia para un profesor
  Future<bool> createSubjectConfiguration(SubjectConfiguration config) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subject-configurations'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(config.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating subject configuration: $e');
      return false;
    }
  }

  /// Obtener configuración de materia por ID
  Future<SubjectConfiguration?> getSubjectConfiguration(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subject-configurations/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubjectConfiguration.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting subject configuration: $e');
      return null;
    }
  }

  /// Obtener todas las configuraciones de un profesor
  Future<List<SubjectConfiguration>> getTeacherConfigurations(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subject-configurations/teacher/$teacherId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SubjectConfiguration.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting teacher configurations: $e');
      return [];
    }
  }

  /// Actualizar configuración de materia
  Future<bool> updateSubjectConfiguration(SubjectConfiguration config) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/subject-configurations/${config.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(config.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating subject configuration: $e');
      return false;
    }
  }

  // ===== REGISTROS DE ASISTENCIA =====

  /// Crear registro de asistencia
  Future<bool> createAttendanceRecord(AttendanceRecord record) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance-records'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(record.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating attendance record: $e');
      return false;
    }
  }

  /// Crear múltiples registros de asistencia (para una clase completa)
  Future<bool> createMultipleAttendanceRecords(List<AttendanceRecord> records) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance-records/batch'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'records': records.map((r) => r.toJson()).toList(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating multiple attendance records: $e');
      return false;
    }
  }

  /// Obtener registros de asistencia de una materia en una fecha específica
  Future<List<AttendanceRecord>> getAttendanceByDate(int subjectConfigId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$_baseUrl/attendance-records/subject/$subjectConfigId/date/$dateStr'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting attendance by date: $e');
      return [];
    }
  }

  /// Obtener resumen de asistencia de un estudiante en una materia
  Future<StudentAttendanceSummary?> getStudentAttendanceSummary(int studentId, int subjectConfigId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/attendance-records/student/$studentId/subject/$subjectConfigId/summary'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StudentAttendanceSummary.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting student attendance summary: $e');
      return null;
    }
  }

  /// Obtener historial de asistencia de un estudiante
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(int studentId, int subjectConfigId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/attendance-records/student/$studentId/subject/$subjectConfigId/history'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting student attendance history: $e');
      return [];
    }
  }

  /// Obtener estudiantes inscritos en una materia
  Future<List<Map<String, dynamic>>> getEnrolledStudents(int subjectConfigId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subject-configurations/$subjectConfigId/students'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting enrolled students: $e');
      return [];
    }
  }

  /// Verificar si ya se tomó asistencia en una fecha específica
  Future<bool> hasAttendanceForDate(int subjectConfigId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$_baseUrl/attendance-records/subject/$subjectConfigId/date/$dateStr/exists'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking attendance for date: $e');
      return false;
    }
  }
}
