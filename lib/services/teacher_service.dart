import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_model.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  static const String _teachersKey = 'teachers_data';

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
      int newId = teachers.isEmpty ? 1 : teachers.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
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

  static Future<Teacher> updateTeacher(int id, Map<String, dynamic> teacherData) async {
    try {
      final service = TeacherService();
      
      // Obtener profesor existente
      final existingTeacher = await service.getTeacherById(id);
      if (existingTeacher == null) {
        throw Exception('Profesor no encontrado');
      }
      
      // Crear profesor actualizado con los nuevos datos
      final updatedTeacher = Teacher.fromMap({
        ...existingTeacher.toMap(),
        ...teacherData,
        'id': id, // Mantener el ID original
      });
      
      // Actualizar usando el método existente
      final success = await service._updateTeacherInstance(updatedTeacher);
      if (!success) {
        throw Exception('Error al actualizar profesor');
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
      int newId = teachers.isEmpty ? 1 : teachers.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
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
      return teachers.where((teacher) => teacher.department == department).toList();
    } catch (e) {
      debugPrint('Error obteniendo profesores por departamento: $e');
      return [];
    }
  }

  // Obtener profesores activos
  Future<List<Teacher>> getActiveTeachers() async {
    try {
      final teachers = await getAllTeachers();
      return teachers.where((teacher) => teacher.isActive).toList();
    } catch (e) {
      debugPrint('Error obteniendo profesores activos: $e');
      return [];
    }
  }

  // Obtener profesores por especialización
  Future<List<Teacher>> getTeachersBySpecialization(String specialization) async {
    try {
      final teachers = await getAllTeachers();
      return teachers.where((teacher) => teacher.specialization == specialization).toList();
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
          departmentCount[teacher.department] = (departmentCount[teacher.department] ?? 0) + 1;
        }
      }
      
      return departmentCount;
    } catch (e) {
      debugPrint('Error contando profesores por departamento: $e');
      return {};
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