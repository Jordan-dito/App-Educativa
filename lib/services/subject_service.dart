import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';
import 'subject_api_service.dart';

class SubjectService {
  static const String _subjectsKey = 'subjects';
  final SubjectApiService _apiService = SubjectApiService();

  // Obtener todas las materias
  Future<List<Subject>> getAllSubjects() async {
    try {
      debugPrint('📚 DEBUG SubjectService.getAllSubjects: Intentando obtener desde API...');
      
      // Intentar obtener desde API primero
      final subjects = await _apiService.getAllSubjects();
      
      // Guardar en caché local
      await _saveSubjectsToCache(subjects);
      
      debugPrint('📚 DEBUG SubjectService.getAllSubjects: ${subjects.length} materias obtenidas desde API');
      return subjects;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.getAllSubjects: Error en API: $e');
      debugPrint('📚 DEBUG SubjectService.getAllSubjects: Intentando obtener desde caché local...');
      
      // Fallback a caché local
      try {
        final prefs = await SharedPreferences.getInstance();
        final subjectsJson = prefs.getStringList(_subjectsKey) ?? [];
        
        final subjects = subjectsJson.map((json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          return Subject.fromMap(map);
        }).toList();
        
        debugPrint('📚 DEBUG SubjectService.getAllSubjects: ${subjects.length} materias obtenidas desde caché');
        return subjects;
      } catch (cacheError) {
        debugPrint('❌ ERROR SubjectService.getAllSubjects: Error en caché: $cacheError');
        return [];
      }
    }
  }

  // Obtener materia por ID
  Future<Subject?> getSubjectById(String id) async {
    try {
      debugPrint('📚 DEBUG SubjectService.getSubjectById: Obteniendo materia ID: $id');
      
      // Intentar obtener desde API primero
      final subject = await _apiService.getSubjectById(id);
      
      if (subject != null) {
        debugPrint('📚 DEBUG SubjectService.getSubjectById: Materia encontrada en API');
        return subject;
      }
      
      // Fallback a búsqueda local
      final subjects = await getAllSubjects();
      final localSubject = subjects.where((s) => s.id == id).firstOrNull;
      
      debugPrint('📚 DEBUG SubjectService.getSubjectById: Materia ${localSubject != null ? 'encontrada' : 'no encontrada'} en caché local');
      return localSubject;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.getSubjectById: $e');
      return null;
    }
  }

  // Insertar nueva materia
  Future<bool> insertSubject(Subject subject) async {
    try {
      debugPrint('📚 DEBUG SubjectService.insertSubject: Creando materia: ${subject.name}');
      
      // Crear en API
      final createdSubject = await _apiService.createSubject(subject);
      
      // Actualizar caché local
      final subjects = await getAllSubjects();
      subjects.add(createdSubject);
      await _saveSubjectsToCache(subjects);
      
      debugPrint('📚 DEBUG SubjectService.insertSubject: Materia creada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.insertSubject: $e');
      
      // Fallback a creación local
      try {
        final subjects = await getAllSubjects();
        
        // Verificar si ya existe una materia con el mismo nombre, grado y sección
        final existingSubject = subjects.where((s) => 
          s.name == subject.name && 
          s.grade == subject.grade && 
          s.section == subject.section
        ).firstOrNull;
        if (existingSubject != null) {
          throw Exception('Ya existe una materia con el nombre ${subject.name} en ${subject.grade} ${subject.section}');
        }
        
        // Generar ID único
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        final newSubject = subject.copyWith(id: newId);
        
        subjects.add(newSubject);
        await _saveSubjectsToCache(subjects);
        
        debugPrint('📚 DEBUG SubjectService.insertSubject: Materia creada localmente');
        return true;
      } catch (localError) {
        debugPrint('❌ ERROR SubjectService.insertSubject: Error local: $localError');
        rethrow;
      }
    }
  }

  // Actualizar materia
  Future<bool> updateSubject(Subject subject) async {
    try {
      debugPrint('📚 DEBUG SubjectService.updateSubject: Actualizando materia ID: ${subject.id}');
      
      // Actualizar en API
      final updatedSubject = await _apiService.updateSubject(subject);
      
      // Actualizar caché local
      final subjects = await getAllSubjects();
      final index = subjects.indexWhere((s) => s.id == subject.id);
      if (index != -1) {
        subjects[index] = updatedSubject;
        await _saveSubjectsToCache(subjects);
      }
      
      debugPrint('📚 DEBUG SubjectService.updateSubject: Materia actualizada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.updateSubject: $e');
      
      // Fallback a actualización local
      try {
        final subjects = await getAllSubjects();
        final index = subjects.indexWhere((s) => s.id == subject.id);
        
        if (index == -1) {
          throw Exception('Materia no encontrada');
        }

        // Verificar si ya existe otra materia con el mismo nombre, grado y sección
        final existingSubject = subjects.where((s) => 
          s.name == subject.name && 
          s.grade == subject.grade && 
          s.section == subject.section &&
          s.id != subject.id
        ).firstOrNull;
        if (existingSubject != null) {
          throw Exception('Ya existe otra materia con el nombre ${subject.name} en ${subject.grade} ${subject.section}');
        }
        
        subjects[index] = subject;
        await _saveSubjectsToCache(subjects);
        
        debugPrint('📚 DEBUG SubjectService.updateSubject: Materia actualizada localmente');
        return true;
      } catch (localError) {
        debugPrint('❌ ERROR SubjectService.updateSubject: Error local: $localError');
        rethrow;
      }
    }
  }

  // Eliminar materia
  Future<bool> deleteSubject(String id) async {
    try {
      debugPrint('📚 DEBUG SubjectService.deleteSubject: Eliminando materia ID: $id');
      
      // Eliminar en API
      final success = await _apiService.deleteSubject(id);
      
      if (success) {
        // Actualizar caché local
        final subjects = await getAllSubjects();
        subjects.removeWhere((subject) => subject.id == id);
        await _saveSubjectsToCache(subjects);
        
        debugPrint('📚 DEBUG SubjectService.deleteSubject: Materia eliminada exitosamente');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.deleteSubject: $e');
      
      // Fallback a eliminación local
      try {
        final subjects = await getAllSubjects();
        subjects.removeWhere((subject) => subject.id == id);
        await _saveSubjectsToCache(subjects);
        
        debugPrint('📚 DEBUG SubjectService.deleteSubject: Materia eliminada localmente');
        return true;
      } catch (localError) {
        debugPrint('❌ ERROR SubjectService.deleteSubject: Error local: $localError');
        return false;
      }
    }
  }

  // Buscar materias
  Future<List<Subject>> searchSubjects(String query) async {
    try {
      final subjects = await getAllSubjects();
      final lowercaseQuery = query.toLowerCase();
      
      return subjects.where((subject) {
        return subject.name.toLowerCase().contains(lowercaseQuery) ||
               subject.grade.toLowerCase().contains(lowercaseQuery) ||
               subject.section.toLowerCase().contains(lowercaseQuery) ||
               subject.academicYear.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error al buscar materias: $e');
      return [];
    }
  }

  // Filtrar materias por sección
  Future<List<Subject>> getSubjectsBySection(String section) async {
    try {
      final subjects = await getAllSubjects();
      return subjects.where((subject) => subject.section == section).toList();
    } catch (e) {
      debugPrint('Error al filtrar materias por sección: $e');
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
      debugPrint('📚 DEBUG SubjectService.getSubjectsByTeacher: Obteniendo materias del profesor: $teacherId');
      
      // Intentar obtener desde API primero
      final subjects = await _apiService.getSubjectsByTeacher(teacherId);
      
      debugPrint('📚 DEBUG SubjectService.getSubjectsByTeacher: ${subjects.length} materias encontradas');
      return subjects;
    } catch (e) {
      debugPrint('❌ ERROR SubjectService.getSubjectsByTeacher: $e');
      
      // Fallback a búsqueda local
      try {
        final allSubjects = await getAllSubjects();
        final filteredSubjects = allSubjects.where((subject) => subject.teacherId == teacherId).toList();
        
        debugPrint('📚 DEBUG SubjectService.getSubjectsByTeacher: ${filteredSubjects.length} materias encontradas en caché');
        return filteredSubjects;
      } catch (cacheError) {
        debugPrint('❌ ERROR SubjectService.getSubjectsByTeacher: Error en caché: $cacheError');
        return [];
      }
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
      
      // Estadísticas por grado
      final subjectsByGrade = <String, int>{};
      for (final subject in subjects) {
        subjectsByGrade[subject.grade] = 
            (subjectsByGrade[subject.grade] ?? 0) + 1;
      }
      
      // Estadísticas por sección
      final subjectsBySection = <String, int>{};
      for (final subject in subjects) {
        subjectsBySection[subject.section] = 
            (subjectsBySection[subject.section] ?? 0) + 1;
      }
      
      return {
        'totalSubjects': totalSubjects,
        'activeSubjects': activeSubjects,
        'inactiveSubjects': inactiveSubjects,
        'subjectsWithTeacher': subjectsWithTeacher,
        'subjectsWithoutTeacher': subjectsWithoutTeacher,
        'subjectsByGrade': subjectsByGrade,
        'subjectsBySection': subjectsBySection,
      };
    } catch (e) {
      debugPrint('Error al obtener estadísticas de materias: $e');
      return {};
    }
  }

  // Guardar lista de materias en caché local (SharedPreferences)
  Future<bool> _saveSubjectsToCache(List<Subject> subjects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = subjects.map((subject) => jsonEncode(subject.toMap())).toList();
      return await prefs.setStringList(_subjectsKey, subjectsJson);
    } catch (e) {
      debugPrint('❌ ERROR SubjectService._saveSubjectsToCache: $e');
      return false;
    }
  }

  // Método legacy para compatibilidad
  Future<bool> _saveSubjects(List<Subject> subjects) async {
    return await _saveSubjectsToCache(subjects);
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