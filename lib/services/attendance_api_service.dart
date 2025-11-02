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
      // Adaptar los datos al formato esperado por el endpoint
      final requestData = {
        'materia_id': config.subjectId,
        'año_academico': int.parse(config.academicYear),
        'fecha_inicio': config.startDate.toIso8601String().split('T')[0],
        'fecha_fin': config.endDate.toIso8601String().split('T')[0],
        'dias_clase': config.classDays.join(','),
        'hora_clase': config.classTime ?? '',
        'meta_asistencia': config.attendanceGoal.toDouble(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/configuracion.php?action=guardar'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('🔧 DEBUG AttendanceApiService.createSubjectConfiguration:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error creating subject configuration: $e');
      return false;
    }
  }

  /// Obtener configuración de materia por ID y año académico
  Future<SubjectConfiguration?> getSubjectConfiguration(int materiaId, int year,
      {int? fallbackTeacherId}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/configuracion.php?action=obtener&materia_id=$materiaId&año_academico=$year'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.getSubjectConfiguration:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Si no viene profesor_id y tenemos un fallback, inyectarlo
          if ((data['profesor_id'] == null || data['profesor_id'] == 0) &&
              fallbackTeacherId != null) {
            data['profesor_id'] = fallbackTeacherId;
            print(
                '🔧 DEBUG AttendanceApiService.getSubjectConfiguration: Inyectando profesor_id = $fallbackTeacherId');
          }

          return SubjectConfiguration.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ ERROR AttendanceApiService.getSubjectConfiguration: $e');
      return null;
    }
  }

  /// Obtener todas las configuraciones de un profesor
  Future<List<SubjectConfiguration>> getTeacherConfigurations(
      int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/configuracion.php?action=profesor&profesor_id=$teacherId&año_academico=${DateTime.now().year}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.getTeacherConfigurations:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data
              .map((json) => SubjectConfiguration.fromJson(json))
              .toList();
        }
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

  /// Verificar si un día es de clase para una materia
  Future<bool> verifyClassDay(int materiaId, DateTime fecha) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/configuracion.php?action=verificar_dia&materia_id=$materiaId&fecha=$fechaStr'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.verifyClassDay:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true &&
            responseData['es_dia_clase'] == true;
      }
      return false;
    } catch (e) {
      print('Error verifying class day: $e');
      return false;
    }
  }

  /// Eliminar configuración de materia
  Future<bool> deleteSubjectConfiguration(int configId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$_baseUrl/api/configuracion.php?action=eliminar&id=$configId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.deleteSubjectConfiguration:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting subject configuration: $e');
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
  Future<bool> createMultipleAttendanceRecords(
      List<AttendanceRecord> records) async {
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
  Future<List<AttendanceRecord>> getAttendanceByDate(
      int materiaId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      // Usar endpoint PHP para obtener asistencia
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/asistencia.php?action=listar&materia_id=$materiaId&fecha_clase=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.getAttendanceByDate:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final data = responseData['data'];

          print(
              '🔧 DEBUG AttendanceApiService.getAttendanceByDate: data type = ${data.runtimeType}');

          // El endpoint puede retornar:
          // Opción 1: data es directamente una lista: { "data": [...] }
          // Opción 2: data es un objeto con "asistencias": { "data": { "asistencias": [...] } }

          List<dynamic> asistenciasList = [];

          if (data is List) {
            // Opción 1: data es directamente una lista
            asistenciasList = data;
            print(
                '🔧 DEBUG AttendanceApiService.getAttendanceByDate: data es List, ${asistenciasList.length} items');
          } else if (data is Map<String, dynamic>) {
            // Opción 2: data es un objeto, buscar la lista en "asistencias"
            if (data['asistencias'] != null && data['asistencias'] is List) {
              asistenciasList = data['asistencias'] as List;
              print(
                  '🔧 DEBUG AttendanceApiService.getAttendanceByDate: encontrado data["asistencias"], ${asistenciasList.length} items');
            } else {
              print(
                  '⚠️ DEBUG AttendanceApiService.getAttendanceByDate: data es Map pero no tiene "asistencias" o no es List');
              print('   data keys: ${data.keys.toList()}');
            }
          }

          if (asistenciasList.isNotEmpty) {
            // Convertir los datos del formato PHP al formato AttendanceRecord
            return asistenciasList.map((json) {
              // Convertir el formato PHP al formato esperado por AttendanceRecord
              return AttendanceRecord(
                subjectConfigurationId: materiaId,
                studentId: json['estudiante_id'] ?? json['estudianteId'] ?? 0,
                classDate: DateTime.parse(
                    json['fecha_clase'] ?? json['fechaClase'] ?? dateStr),
                status: _parseAttendanceStatus(
                    json['estado'] ?? json['status'] ?? 'ausente'),
              );
            }).toList();
          } else {
            print(
                '⚠️ DEBUG AttendanceApiService.getAttendanceByDate: asistenciasList está vacío');
          }
        }
      }
      return [];
    } catch (e) {
      print('❌ ERROR AttendanceApiService.getAttendanceByDate: $e');
      return [];
    }
  }

  /// Convertir string de estado PHP al enum AttendanceStatus
  AttendanceStatus _parseAttendanceStatus(String estado) {
    switch (estado.toLowerCase()) {
      case 'presente':
        return AttendanceStatus.present;
      case 'ausente':
        return AttendanceStatus.absent;
      case 'tardanza':
        return AttendanceStatus.late;
      case 'justificado':
        return AttendanceStatus.justified;
      default:
        return AttendanceStatus.absent;
    }
  }

  /// Obtener resumen de asistencia de un estudiante en una materia
  /// Intenta usar el resumen del endpoint, si no está disponible calcula desde los registros
  Future<StudentAttendanceSummary?> getStudentAttendanceSummary(
      int estudianteId, int materiaId) async {
    try {
      print('🔧 DEBUG AttendanceApiService.getStudentAttendanceSummary:');
      print('   estudiante_id: $estudianteId, materia_id: $materiaId');

      // Intentar obtener el resumen directamente del endpoint
      try {
        final response = await http.get(
          Uri.parse(
              '$_baseUrl/api/asistencia.php?action=listar_estudiante&estudiante_id=$estudianteId&materia_id=$materiaId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData['success'] == true) {
            final data = responseData['data'];

            // Si el endpoint retorna un resumen, usarlo directamente
            if (data is Map<String, dynamic> && data['resumen'] != null) {
              final resumen = data['resumen'] as Map<String, dynamic>;

              print(
                  '✅ DEBUG AttendanceApiService.getStudentAttendanceSummary: Usando resumen del endpoint');

              final total = resumen['total'] ?? 0;
              final presentes = resumen['presentes'] ?? 0;
              final ausentes = resumen['ausentes'] ?? 0;
              final tardanzas = resumen['tardanzas'] ?? 0;
              final porcentaje =
                  (resumen['porcentaje_asistencia'] ?? 0.0).toDouble();
              const meta = 80; // Meta por defecto

              // Obtener nombre del estudiante desde data si está disponible
              final studentName =
                  data['nombre_estudiante'] ?? 'Estudiante $estudianteId';

              return StudentAttendanceSummary(
                studentId: estudianteId,
                studentName: studentName.toString(),
                totalClasses:
                    total is int ? total : int.tryParse(total.toString()) ?? 0,
                presentCount: presentes is int
                    ? presentes
                    : int.tryParse(presentes.toString()) ?? 0,
                absentCount: ausentes is int
                    ? ausentes
                    : int.tryParse(ausentes.toString()) ?? 0,
                lateCount: tardanzas is int
                    ? tardanzas
                    : int.tryParse(tardanzas.toString()) ?? 0,
                justifiedCount:
                    0, // Por ahora no hay justificados en el resumen
                attendancePercentage: porcentaje,
                goalPercentage: meta,
                meetsGoal: porcentaje >= meta,
              );
            }
          }
        }
      } catch (e) {
        print(
            '⚠️ DEBUG AttendanceApiService.getStudentAttendanceSummary: No se pudo obtener resumen del endpoint, calculando desde registros: $e');
      }

      // Fallback: Calcular desde los registros obtenidos
      final allAttendance =
          await _getStudentAttendanceByMatter(estudianteId, materiaId);

      if (allAttendance.isEmpty) {
        print(
            '⚠️ DEBUG AttendanceApiService.getStudentAttendanceSummary: No hay asistencias');
        return null;
      }

      // Calcular estadísticas desde los registros
      final total = allAttendance.length;
      final presentes = allAttendance
          .where((a) => a.status == AttendanceStatus.present)
          .length;
      final ausentes = allAttendance
          .where((a) => a.status == AttendanceStatus.absent)
          .length;
      final tardanzas =
          allAttendance.where((a) => a.status == AttendanceStatus.late).length;
      final justificados = allAttendance
          .where((a) => a.status == AttendanceStatus.justified)
          .length;
      final porcentaje = total > 0 ? (presentes / total) * 100 : 0.0;
      const meta = 80;

      print(
          '🔧 DEBUG AttendanceApiService.getStudentAttendanceSummary (calculado):');
      print(
          '   Total: $total, Presentes: $presentes, Ausentes: $ausentes, Tardanzas: $tardanzas');
      print('   Porcentaje: $porcentaje%');

      return StudentAttendanceSummary(
        studentId: estudianteId,
        studentName: 'Estudiante $estudianteId',
        totalClasses: total,
        presentCount: presentes,
        absentCount: ausentes,
        lateCount: tardanzas,
        justifiedCount: justificados,
        attendancePercentage: porcentaje,
        goalPercentage: meta,
        meetsGoal: porcentaje >= meta,
      );
    } catch (e) {
      print('❌ ERROR AttendanceApiService.getStudentAttendanceSummary: $e');
      return null;
    }
  }

  /// Obtener todas las asistencias de un estudiante en una materia
  Future<List<AttendanceRecord>> _getStudentAttendanceByMatter(
      int estudianteId, int materiaId) async {
    try {
      // El endpoint listar puede recibir estudiante_id como parámetro opcional
      // Si no, obtenemos todas y filtramos
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/asistencia.php?action=listar_estudiante&estudiante_id=$estudianteId&materia_id=$materiaId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService._getStudentAttendanceByMatter:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final data = responseData['data'];
          List<dynamic> asistenciasList = [];

          print(
              '🔧 DEBUG AttendanceApiService._getStudentAttendanceByMatter: data type = ${data.runtimeType}');

          // El endpoint retorna: { "data": { "resumen": {...}, "asistencias": [...] } }
          if (data is Map<String, dynamic>) {
            if (data['asistencias'] != null && data['asistencias'] is List) {
              asistenciasList = data['asistencias'] as List;
              print(
                  '🔧 DEBUG AttendanceApiService._getStudentAttendanceByMatter: Encontrado ${asistenciasList.length} asistencias en data["asistencias"]');
            } else {
              print(
                  '⚠️ DEBUG AttendanceApiService._getStudentAttendanceByMatter: data es Map pero no tiene "asistencias"');
              print('   data keys: ${data.keys.toList()}');
              // Intentar usar resumen si existe
              if (data['resumen'] != null) {
                print('   ✅ Encontrado resumen en data');
              }
            }
          } else if (data is List) {
            // Por si acaso retorna directamente una lista
            asistenciasList = data;
            print(
                '🔧 DEBUG AttendanceApiService._getStudentAttendanceByMatter: data es List directo con ${asistenciasList.length} items');
          }

          if (asistenciasList.isNotEmpty) {
            print(
                '✅ DEBUG AttendanceApiService._getStudentAttendanceByMatter: ${asistenciasList.length} asistencias encontradas');
            return asistenciasList.map((json) {
              return AttendanceRecord(
                subjectConfigurationId: materiaId,
                studentId: json['estudiante_id'] ?? estudianteId,
                classDate: DateTime.parse(json['fecha_clase'] ??
                    DateTime.now().toIso8601String().split('T')[0]),
                status: _parseAttendanceStatus(json['estado'] ?? 'ausente'),
              );
            }).toList();
          } else {
            print(
                '⚠️ DEBUG AttendanceApiService._getStudentAttendanceByMatter: asistenciasList está vacío');
          }
        } else {
          print(
              '⚠️ DEBUG AttendanceApiService._getStudentAttendanceByMatter: success no es true o responseData no es Map');
          print(
              '   responseData keys: ${responseData is Map ? responseData.keys.toList() : "no es Map"}');
        }
      } else {
        print(
            '❌ DEBUG AttendanceApiService._getStudentAttendanceByMatter: Status code ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('❌ ERROR AttendanceApiService._getStudentAttendanceByMatter: $e');
      return [];
    }
  }

  /// Obtener historial de asistencia de un estudiante
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(
      int estudianteId, int materiaId) async {
    try {
      print('🔧 DEBUG AttendanceApiService.getStudentAttendanceHistory:');
      print('   estudiante_id: $estudianteId, materia_id: $materiaId');

      // Usar el mismo método que obtiene todas las asistencias
      final allAttendance =
          await _getStudentAttendanceByMatter(estudianteId, materiaId);

      // Ordenar por fecha descendente (más recientes primero)
      allAttendance.sort((a, b) => b.classDate.compareTo(a.classDate));

      return allAttendance;
    } catch (e) {
      print('❌ ERROR AttendanceApiService.getStudentAttendanceHistory: $e');
      return [];
    }
  }

  /// Verificar si ya se tomó asistencia en una fecha específica
  Future<bool> hasAttendanceForDate(int materiaId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      // Usar endpoint PHP para verificar asistencia
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/asistencia.php?action=verificar&materia_id=$materiaId&fecha_clase=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.hasAttendanceForDate:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic>) {
            // El endpoint puede retornar:
            // { "success": true, "existe": true/false } (directo)
            // O { "success": true, "data": { "existe": true/false } } (anidado)
            final existe = responseData['existe'] ??
                (responseData['data'] != null && responseData['data'] is Map
                    ? responseData['data']['existe']
                    : null);

            final count = responseData['count'] ??
                (responseData['data'] != null && responseData['data'] is Map
                    ? responseData['data']['total_registros']
                    : null);

            print('🔧 DEBUG AttendanceApiService.hasAttendanceForDate parsed:');
            print('   existe = $existe');
            print('   count = $count');

            return existe == true ||
                (responseData['success'] == true && count != null && count > 0);
          }
          return false;
        } catch (e) {
          // Si no se puede parsear, verificar si hay datos
          return response.body.isNotEmpty &&
              !response.body.contains('"data":[]');
        }
      }
      return false;
    } catch (e) {
      print('❌ ERROR AttendanceApiService.hasAttendanceForDate: $e');
      // Si el endpoint no existe, intentar consultar directamente la lista
      return await _hasAttendanceFallback(materiaId, date);
    }
  }

  /// Método de respaldo para verificar asistencia consultando la lista
  Future<bool> _hasAttendanceFallback(int materiaId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/asistencia.php?action=listar&materia_id=$materiaId&fecha_clase=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final data = responseData['data'];
          if (data is List) {
            return data.isNotEmpty;
          }
        }
      }
      return false;
    } catch (e) {
      print('❌ ERROR AttendanceApiService._hasAttendanceFallback: $e');
      return false;
    }
  }

  // ===== NUEVOS MÉTODOS PARA ASISTENCIA =====

  /// Tomar asistencia para múltiples estudiantes
  Future<bool> takeAttendance({
    required int materiaId,
    required DateTime fechaClase,
    required int profesorId,
    required List<Map<String, dynamic>> asistencias,
  }) async {
    try {
      final requestData = {
        'materia_id': materiaId,
        'fecha_clase': fechaClase.toIso8601String().split('T')[0],
        'profesor_id': profesorId,
        'asistencias': asistencias,
      };

      const url = '$_baseUrl/api/asistencia.php?action=tomar';

      print('🔧 DEBUG AttendanceApiService.takeAttendance:');
      print('   URL: $url');
      print('   Request Data: ${jsonEncode(requestData)}');
      print('   Asistencias count: ${asistencias.length}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('🔧 DEBUG AttendanceApiService.takeAttendance Response:');
      print('   Status code: ${response.statusCode}');
      print('   Response headers: ${response.headers}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          print('   ✅ Parsed response: $responseData');

          // Verificar si la respuesta indica éxito
          if (responseData is Map<String, dynamic>) {
            final success = responseData['success'] == true ||
                responseData['success'] == 1 ||
                responseData['status'] == 'success';

            if (success) {
              print('   ✅ Asistencia guardada exitosamente');
              return true;
            } else {
              print(
                  '   ⚠️ El servidor reportó error: ${responseData['message'] ?? 'Unknown error'}');
              return false;
            }
          }

          // Si la respuesta no es un mapa, considerarla como éxito si el código es 200/201
          return response.statusCode == 200 || response.statusCode == 201;
        } catch (parseError) {
          print('   ❌ Error parseando respuesta: $parseError');
          print('   Response body (raw): ${response.body}');
          // Si el código es 200 pero no podemos parsear, asumimos éxito
          return response.statusCode == 200 || response.statusCode == 201;
        }
      } else {
        print('   ❌ Error HTTP: ${response.statusCode}');
        print('   Response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR AttendanceApiService.takeAttendance:');
      print('   Exception: $e');
      print('   Stack trace: $stackTrace');
      return false;
    }
  }

  /// Obtener estudiantes inscritos en una materia
  Future<List<Map<String, dynamic>>> getInscribedStudents(int materiaId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/asistencia.php?action=estudiantes_inscritos&materia_id=$materiaId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔧 DEBUG AttendanceApiService.getInscribedStudents:');
      print('   URL: ${response.request?.url}');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Error getting inscribed students: $e');
      return [];
    }
  }
}
