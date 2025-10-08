import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';

class SubjectService {
  static const String _subjectsKey = 'subjects';

  // Obtener todas las materias
  Future<List<Subject>> getAllSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = prefs.getStringList(_subjectsKey) ?? [];
      
      return subjectsJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return Subject.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener materias: $e');
      return [];
    }
  }

  // Obtener materia por ID
  Future<Subject?> getSubjectById(String id) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.firstWhere(
        (subject) => subject.id == id,
        orElse: () => throw Exception('Materia no encontrada'),
      );
    } catch (e) {
      debugPrint('Error al obtener materia por ID: $e');
      return null;
    }
  }

  // Insertar nueva materia
  Future<bool> insertSubject(Subject subject) async {
    try {
      final subjects = await getAllSubjects();
      
      // Verificar si el código ya existe
      final existingSubject = subjects.where((s) => s.code == subject.code).firstOrNull;
      if (existingSubject != null) {
        throw Exception('Ya existe una materia con el código ${subject.code}');
      }
      
      // Generar ID único
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final newSubject = subject.copyWith(id: newId);
      
      subjects.add(newSubject);
      return await _saveSubjects(subjects);
    } catch (e) {
      debugPrint('Error al insertar materia: $e');
      rethrow;
    }
  }

  // Actualizar materia
  Future<bool> updateSubject(Subject subject) async {
    try {
      final subjects = await getAllSubjects();
      final index = subjects.indexWhere((s) => s.id == subject.id);
      
      if (index == -1) {
        throw Exception('Materia no encontrada');
      }

      // Verificar si el código ya existe en otra materia
      final existingSubject = subjects.where((s) => s.code == subject.code && s.id != subject.id).firstOrNull;
      if (existingSubject != null) {
        throw Exception('Ya existe otra materia con el código ${subject.code}');
      }
      
      subjects[index] = subject.copyWith(updatedAt: DateTime.now());
      return await _saveSubjects(subjects);
    } catch (e) {
      debugPrint('Error al actualizar materia: $e');
      rethrow;
    }
  }

  // Eliminar materia
  Future<bool> deleteSubject(String id) async {
    try {
      final subjects = await getAllSubjects();
      subjects.removeWhere((subject) => subject.id == id);
      return await _saveSubjects(subjects);
    } catch (e) {
      debugPrint('Error al eliminar materia: $e');
      return false;
    }
  }

  // Buscar materias
  Future<List<Subject>> searchSubjects(String query) async {
    try {
      final subjects = await getAllSubjects();
      final lowercaseQuery = query.toLowerCase();
      
      return subjects.where((subject) {
        return subject.name.toLowerCase().contains(lowercaseQuery) ||
               subject.code.toLowerCase().contains(lowercaseQuery) ||
               subject.description.toLowerCase().contains(lowercaseQuery) ||
               subject.department.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error al buscar materias: $e');
      return [];
    }
  }

  // Filtrar materias por departamento
  Future<List<Subject>> getSubjectsByDepartment(String department) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.department == department).toList();
    } catch (e) {
      debugPrint('Error al filtrar materias por departamento: $e');
      return [];
    }
  }

  // Filtrar materias por nivel
  Future<List<Subject>> getSubjectsByLevel(String level) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.level == level).toList();
    } catch (e) {
      debugPrint('Error al filtrar materias por nivel: $e');
      return [];
    }
  }

  // Filtrar materias por grado
  Future<List<Subject>> getSubjectsByGrade(String grade) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.grade == grade).toList();
    } catch (e) {
      debugPrint('Error al filtrar materias por grado: $e');
      return [];
    }
  }

  // Obtener materias activas
  Future<List<Subject>> getActiveSubjects() async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.isActive).toList();
    } catch (e) {
      debugPrint('Error al obtener materias activas: $e');
      return [];
    }
  }

  // Obtener materias por profesor
  Future<List<Subject>> getSubjectsByTeacher(String teacherId) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.teacherId == teacherId).toList();
    } catch (e) {
      debugPrint('Error al obtener materias por profesor: $e');
      return [];
    }
  }

  // Asignar profesor a materia
  Future<bool> assignTeacherToSubject(String subjectId, String teacherId, String teacherName) async {
    try {
      final subject = await getSubjectById(subjectId);
      if (subject == null) {
        throw Exception('Materia no encontrada');
      }

      final updatedSubject = subject.copyWith(
        teacherId: teacherId,
        teacherName: teacherName,
        updatedAt: DateTime.now(),
      );

      return await updateSubject(updatedSubject);
    } catch (e) {
      debugPrint('Error al asignar profesor a materia: $e');
      return false;
    }
  }

  // Remover profesor de materia
  Future<bool> removeTeacherFromSubject(String subjectId) async {
    try {
      final subject = await getSubjectById(subjectId);
      if (subject == null) {
        throw Exception('Materia no encontrada');
      }

      final updatedSubject = subject.copyWith(
        teacherId: null,
        teacherName: null,
        updatedAt: DateTime.now(),
      );

      return await updateSubject(updatedSubject);
    } catch (e) {
      debugPrint('Error al remover profesor de materia: $e');
      return false;
    }
  }

  // Obtener estadísticas de materias
  Future<Map<String, dynamic>> getSubjectStatistics() async {
    try {
      final subjects = await getAllSubjects();
      
      final totalSubjects = subjects.length;
      final activeSubjects = subjects.where((s) => s.isActive).length;
      final inactiveSubjects = totalSubjects - activeSubjects;
      final subjectsWithTeacher = subjects.where((s) => s.teacherId != null).length;
      final subjectsWithoutTeacher = totalSubjects - subjectsWithTeacher;
      
      // Estadísticas por departamento
      final subjectsByDepartment = <String, int>{};
      for (final subject in subjects) {
        subjectsByDepartment[subject.department] = 
            (subjectsByDepartment[subject.department] ?? 0) + 1;
      }
      
      // Estadísticas por nivel
      final subjectsByLevel = <String, int>{};
      for (final subject in subjects) {
        subjectsByLevel[subject.level] = 
            (subjectsByLevel[subject.level] ?? 0) + 1;
      }
      
      // Total de créditos y horas
      final totalCredits = subjects.fold<int>(0, (sum, subject) => sum + subject.credits);
      final totalHours = subjects.fold<int>(0, (sum, subject) => sum + subject.hoursPerWeek);
      
      return {
        'totalSubjects': totalSubjects,
        'activeSubjects': activeSubjects,
        'inactiveSubjects': inactiveSubjects,
        'subjectsWithTeacher': subjectsWithTeacher,
        'subjectsWithoutTeacher': subjectsWithoutTeacher,
        'subjectsByDepartment': subjectsByDepartment,
        'subjectsByLevel': subjectsByLevel,
        'totalCredits': totalCredits,
        'totalHours': totalHours,
        'averageCredits': totalSubjects > 0 ? (totalCredits / totalSubjects).toStringAsFixed(1) : '0',
        'averageHours': totalSubjects > 0 ? (totalHours / totalSubjects).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      debugPrint('Error al obtener estadísticas de materias: $e');
      return {};
    }
  }

  // Guardar lista de materias en SharedPreferences
  Future<bool> _saveSubjects(List<Subject> subjects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = subjects.map((subject) => jsonEncode(subject.toMap())).toList();
      return await prefs.setStringList(_subjectsKey, subjectsJson);
    } catch (e) {
      debugPrint('Error al guardar materias: $e');
      return false;
    }
  }

  // Limpiar todas las materias (para testing)
  Future<bool> clearAllSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_subjectsKey);
    } catch (e) {
      debugPrint('Error al limpiar materias: $e');
      return false;
    }
  }

  // Importar materias desde JSON
  Future<bool> importSubjectsFromJson(List<Map<String, dynamic>> subjectsData) async {
    try {
      final subjects = subjectsData.map((data) => Subject.fromMap(data)).toList();
      return await _saveSubjects(subjects);
    } catch (e) {
      debugPrint('Error al importar materias: $e');
      return false;
    }
  }

  // Exportar materias a JSON
  Future<List<Map<String, dynamic>>> exportSubjectsToJson() async {
    try {
      final subjects = await getAllSubjects();
      return subjects.map((subject) => subject.toMap()).toList();
    } catch (e) {
      debugPrint('Error al exportar materias: $e');
      return [];
    }
  }
}