import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_model.dart';
import 'teacher_api_service.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  static const String _teachersKey = 'teachers_data';
  final TeacherApiService _apiService = TeacherApiService();

  // Métodos estáticos para compatibilidad con providers
  static Future<List<Teacher>> getTeachers() async {
    final service = TeacherService();
    return await service.getAllTeachers();
  }

  static Future<Teacher?> getTeacher(int id) async {
    final service = TeacherService();
    return await service.getTeacherById(id);
  }

  static Future<Teacher> createTeacher(Map<String, dynamic> teacherData) async {
    try {
      final teacher = Teacher.fromMap(teacherData);
      final service = TeacherService();

      // Obtener profesores existentes
      List<Teacher> teachers = await service.getAllTeachers();

      // Asignar ID único
      int newId = teachers.isEmpty
          ? 1
          : teachers.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      teacher.id = newId;

      // Agregar nuevo profesor
      teachers.add(teacher);

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = teachers.map((t) => t.toMap()).toList();
      await prefs.setString(_teachersKey, jsonEncode(teachersJson));

      return teacher;
    } catch (e) {
      debugPrint('Error creando profesor: $e');
      throw Exception('Error al crear profesor: $e');
    }
  }

  static Future<Teacher> updateTeacher(
      int id, Map<String, dynamic> teacherData) async {
    try {
      final service = TeacherService();

      // Preparar datos para la API directamente
      final apiData = {
        'nombre': teacherData['firstName'] ?? '',
        'apellido': teacherData['lastName'] ?? '',
        'telefono': teacherData['phone'] ?? '',
        'direccion': teacherData['address'] ?? '',
        'fecha_contratacion': teacherData['hireDate'] != null
            ? (teacherData['hireDate'] is DateTime
                ? (teacherData['hireDate'] as DateTime)
                    .toIso8601String()
                    .split('T')[0]
                : teacherData['hireDate'].toString())
            : '',
      };

      // Actualizar usando la API
      final success = await service._apiService.updateTeacher(id, apiData);
      if (!success) {
        throw Exception('Error al actualizar profesor en la API');
      }

      // Intentar obtener el profesor actualizado desde la API
      Teacher? updatedTeacher;
      try {
        updatedTeacher = await service.getTeacherById(id);
      } catch (e) {
        debugPrint(
            'No se pudo obtener el profesor actualizado desde la API: $e');
      }

      // Si no se pudo obtener desde la API, crear uno con los datos proporcionados
      updatedTeacher ??= Teacher(
          id: id,
          firstName: teacherData['firstName'] ?? '',
          lastName: teacherData['lastName'] ?? '',
          email: teacherData['email'] ?? '',
          phone: teacherData['phone'] ?? '',
          address: teacherData['address'] ?? '',
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
          specialization: teacherData['specialization'] ?? 'General',
          department: teacherData['department'] ?? 'General',
          hireDate: teacherData['hireDate'] ?? DateTime.now(),
          salary: teacherData['salary'] ?? 0.0,
          isActive: teacherData['isActive'] ?? true,
        );

      // Actualizar también en caché local si es posible
      try {
        await service._updateTeacherInstance(updatedTeacher);
      } catch (e) {
        debugPrint('No se pudo actualizar el caché local: $e');
      }

      return updatedTeacher;
    } catch (e) {
      debugPrint('Error actualizando profesor: $e');
      throw Exception('Error al actualizar profesor: $e');
    }
  }

  static Future<bool> deleteTeacher(int id) async {
    final service = TeacherService();
    return await service._deleteTeacherInstance(id);
  }

  static Future<List<Teacher>> searchTeachers(String query) async {
    final service = TeacherService();
    return await service._searchTeachersInstance(query);
  }

  static Future<List<Teacher>> getTeachersBySubject(String subject) async {
    final service = TeacherService();
    return await service.getTeachersBySpecialization(subject);
  }

  // Obtener todos los profesores
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersData = prefs.getString(_teachersKey);

      if (teachersData == null) {
        return [];
      }

      final List<dynamic> teachersJson = jsonDecode(teachersData);
      return teachersJson.map((json) => Teacher.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error obteniendo profesores: $e');
      return [];
    }
  }

  // Insertar un nuevo profesor
  Future<int> insertTeacher(Teacher teacher) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener profesores existentes
      List<Teacher> teachers = await getAllTeachers();

      // Asignar ID único
      int newId = teachers.isEmpty
          ? 1
          : teachers.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      teacher.id = newId;

      // Agregar nuevo profesor
      teachers.add(teacher);

      // Guardar en SharedPreferences
      final teachersJson = teachers.map((t) => t.toMap()).toList();
      await prefs.setString(_teachersKey, jsonEncode(teachersJson));

      return newId;
    } catch (e) {
      debugPrint('Error insertando profesor: $e');
      return -1;
    }
  }

  // Obtener profesor por ID
  Future<Teacher?> getTeacherById(int id) async {
    try {
      // Intentar obtener desde la API primero
      try {
        final teacher = await _apiService.getTeacherById(id.toString());
        if (teacher != null) {
          return teacher;
        }
      } catch (e) {
        debugPrint('Error obteniendo profesor desde API: $e');
      }

      // Fallback a caché local
      final teachers = await getAllTeachers();
      for (Teacher teacher in teachers) {
        if (teacher.id == id) {
          return teacher;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo profesor por ID: $e');
      return null;
    }
  }

  // Actualizar profesor
  Future<bool> _updateTeacherInstance(Teacher teacher) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Teacher> teachers = await getAllTeachers();

      // Encontrar y actualizar profesor
      for (int i = 0; i < teachers.length; i++) {
        if (teachers[i].id == teacher.id) {
          teachers[i] = teacher;
          break;
        }
      }

      // Guardar cambios
      final teachersJson = teachers.map((t) => t.toMap()).toList();
      await prefs.setString(_teachersKey, jsonEncode(teachersJson));

      return true;
    } catch (e) {
      debugPrint('Error actualizando profesor: $e');
      return false;
    }
  }

  // Eliminar profesor
  Future<bool> _deleteTeacherInstance(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Teacher> teachers = await getAllTeachers();

      // Filtrar profesor a eliminar
      teachers.removeWhere((teacher) => teacher.id == id);

      // Guardar cambios
      final teachersJson = teachers.map((t) => t.toMap()).toList();
      await prefs.setString(_teachersKey, jsonEncode(teachersJson));

      return true;
    } catch (e) {
      debugPrint('Error eliminando profesor: $e');
      return false;
    }
  }

  // Buscar profesores por nombre o especialización
  Future<List<Teacher>> _searchTeachersInstance(String query) async {
    try {
      final teachers = await getAllTeachers();
      final lowercaseQuery = query.toLowerCase();

      return teachers.where((teacher) {
        return teacher.firstName.toLowerCase().contains(lowercaseQuery) ||
            teacher.lastName.toLowerCase().contains(lowercaseQuery) ||
            teacher.email.toLowerCase().contains(lowercaseQuery) ||
            teacher.specialization.toLowerCase().contains(lowercaseQuery) ||
            teacher.department.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error buscando profesores: $e');
      return [];
    }
  }

  // Obtener profesores por departamento
  Future<List<Teacher>> getTeachersByDepartment(String department) async {
    try {
      final teachers = await getAllTeachers();
      return teachers
          .where((teacher) => teacher.department == department)
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo profesores por departamento: $e');
      return [];
    }
  }

  // Obtener profesores activos
  Future<List<Teacher>> getActiveTeachers() async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG TeacherService.getActiveTeachers: Intentando obtener profesores activos desde API...');

      // Intentar obtener desde API primero
      final teachers = await _apiService.getActiveTeachers();

      // Guardar en caché local
      await _saveTeachersToCache(teachers);

      debugPrint(
          '👨‍🏫 DEBUG TeacherService.getActiveTeachers: ${teachers.length} profesores activos obtenidos desde API');
      return teachers;
    } catch (e) {
      debugPrint('❌ ERROR TeacherService.getActiveTeachers: Error en API: $e');
      debugPrint(
          '👨‍🏫 DEBUG TeacherService.getActiveTeachers: Intentando obtener desde caché local...');

      // Fallback a caché local
      try {
        final teachers = await getAllTeachers();
        final activeTeachers =
            teachers.where((teacher) => teacher.isActive).toList();

        // Si no hay profesores en caché, crear algunos de prueba
        if (activeTeachers.isEmpty) {
          debugPrint(
              '👨‍🏫 DEBUG TeacherService.getActiveTeachers: No hay profesores en caché, creando profesores de prueba...');
          final testTeachers = _createTestTeachers();
          await _saveTeachersToCache(testTeachers);
          debugPrint(
              '👨‍🏫 DEBUG TeacherService.getActiveTeachers: ${testTeachers.length} profesores de prueba creados');
          return testTeachers;
        }

        debugPrint(
            '👨‍🏫 DEBUG TeacherService.getActiveTeachers: ${activeTeachers.length} profesores activos obtenidos desde caché');
        return activeTeachers;
      } catch (cacheError) {
        debugPrint(
            '❌ ERROR TeacherService.getActiveTeachers: Error en caché: $cacheError');
        return [];
      }
    }
  }

  // Obtener profesores por especialización
  Future<List<Teacher>> getTeachersBySpecialization(
      String specialization) async {
    try {
      final teachers = await getAllTeachers();
      return teachers
          .where((teacher) => teacher.specialization == specialization)
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo profesores por especialización: $e');
      return [];
    }
  }

  // Contar profesores por departamento
  Future<Map<String, int>> getTeacherCountByDepartment() async {
    try {
      final teachers = await getAllTeachers();
      Map<String, int> departmentCount = {};

      for (Teacher teacher in teachers) {
        if (teacher.isActive) {
          departmentCount[teacher.department] =
              (departmentCount[teacher.department] ?? 0) + 1;
        }
      }

      return departmentCount;
    } catch (e) {
      debugPrint('Error contando profesores por departamento: $e');
      return {};
    }
  }

  // Crear profesores de prueba
  List<Teacher> _createTestTeachers() {
    return [
      Teacher(
        id: 1,
        firstName: 'Miguel',
        lastName: 'Torres',
        email: 'miguel.torres@colegio.com',
        phone: '0987654321',
        address: 'Av. Principal 123',
        birthDate: DateTime(1985, 5, 15),
        specialization: 'Historia',
        department: 'Ciencias Sociales',
        hireDate: DateTime(2020, 1, 15),
        salary: 2500.0,
        isActive: true,
      ),
      Teacher(
        id: 2,
        firstName: 'Laura',
        lastName: 'Jiménez',
        email: 'laura.jimenez@colegio.com',
        phone: '0998765432',
        address: 'Calle Secundaria 456',
        birthDate: DateTime(1988, 8, 22),
        specialization: 'Matemáticas',
        department: 'Ciencias Exactas',
        hireDate: DateTime(2019, 3, 1),
        salary: 2800.0,
        isActive: true,
      ),
      Teacher(
        id: 3,
        firstName: 'Carlos',
        lastName: 'Mendoza',
        email: 'carlos.mendoza@colegio.com',
        phone: '0976543210',
        address: 'Plaza Central 789',
        birthDate: DateTime(1982, 12, 10),
        specialization: 'Ciencias Naturales',
        department: 'Ciencias Naturales',
        hireDate: DateTime(2018, 8, 20),
        salary: 2700.0,
        isActive: true,
      ),
    ];
  }

  // Guardar lista de profesores en caché local (SharedPreferences)
  Future<bool> _saveTeachersToCache(List<Teacher> teachers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersJson =
          teachers.map((teacher) => jsonEncode(teacher.toMap())).toList();
      return await prefs.setStringList(_teachersKey, teachersJson);
    } catch (e) {
      debugPrint('❌ ERROR TeacherService._saveTeachersToCache: $e');
      return false;
    }
  }

  // Obtener estadísticas de salarios
  Future<Map<String, double>> getSalaryStatistics() async {
    try {
      final teachers = await getActiveTeachers();

      if (teachers.isEmpty) {
        return {
          'average': 0.0,
          'minimum': 0.0,
          'maximum': 0.0,
          'total': 0.0,
        };
      }

      final salaries = teachers.map((t) => t.salary).toList();

      return {
        'average': salaries.reduce((a, b) => a + b) / salaries.length,
        'minimum': salaries.reduce((a, b) => a < b ? a : b),
        'maximum': salaries.reduce((a, b) => a > b ? a : b),
        'total': salaries.reduce((a, b) => a + b),
      };
    } catch (e) {
      debugPrint('Error obteniendo estadísticas de salarios: $e');
      return {};
    }
  }

  // Limpiar todos los datos de profesores
  Future<void> clearAllTeachers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_teachersKey);
    } catch (e) {
      debugPrint('Error limpiando datos de profesores: $e');
    }
  }
}
