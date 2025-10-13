import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  static const String _studentsKey = 'students_data';

  // Obtener todos los estudiantes (usando modelo viejo para compatibilidad)
  Future<List<Student>> getAllStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsData = prefs.getString(_studentsKey);

      if (studentsData == null) {
        return [];
      }

      final List<dynamic> studentsJson = jsonDecode(studentsData);
      return studentsJson.map((json) => Student.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error obteniendo estudiantes: $e');
      return [];
    }
  }

  // Crear un nuevo estudiante desde Map
  static Future<Student> createStudent(Map<String, dynamic> studentData) async {
    try {
      final student = Student.fromMap(studentData);
      final service = StudentService();

      // Obtener estudiantes existentes
      List<Student> students = await service.getAllStudents();

      // Asignar ID único
      int newId = students.isEmpty
          ? 1
          : students.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      student.id = newId;

      // Agregar nuevo estudiante
      students.add(student);

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = students.map((s) => s.toMap()).toList();
      await prefs.setString(_studentsKey, jsonEncode(studentsJson));

      return student;
    } catch (e) {
      debugPrint('Error creando estudiante: $e');
      throw Exception('Error al crear estudiante: $e');
    }
  }

  // Insertar un nuevo estudiante
  Future<int> insertStudent(Student student) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener estudiantes existentes
      List<Student> students = await getAllStudents();

      // Asignar ID único
      int newId = students.isEmpty
          ? 1
          : students.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      student.id = newId;

      // Agregar nuevo estudiante
      students.add(student);

      // Guardar en SharedPreferences
      final studentsJson = students.map((s) => s.toMap()).toList();
      await prefs.setString(_studentsKey, jsonEncode(studentsJson));

      return newId;
    } catch (e) {
      debugPrint('Error insertando estudiante: $e');
      return -1;
    }
  }

  // Obtener estudiante por ID
  Future<Student?> getStudentById(int id) async {
    try {
      final students = await getAllStudents();
      for (Student student in students) {
        if (student.id == id) {
          return student;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo estudiante por ID: $e');
      return null;
    }
  }

  // Actualizar estudiante
  Future<bool> updateStudent(Student student) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Student> students = await getAllStudents();

      // Encontrar y actualizar estudiante
      for (int i = 0; i < students.length; i++) {
        if (students[i].id == student.id) {
          students[i] = student;
          break;
        }
      }

      // Guardar cambios
      final studentsJson = students.map((s) => s.toMap()).toList();
      await prefs.setString(_studentsKey, jsonEncode(studentsJson));

      return true;
    } catch (e) {
      debugPrint('Error actualizando estudiante: $e');
      return false;
    }
  }

  // Eliminar estudiante
  Future<bool> deleteStudent(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Student> students = await getAllStudents();

      // Filtrar estudiante a eliminar
      students.removeWhere((student) => student.id == id);

      // Guardar cambios
      final studentsJson = students.map((s) => s.toMap()).toList();
      await prefs.setString(_studentsKey, jsonEncode(studentsJson));

      return true;
    } catch (e) {
      debugPrint('Error eliminando estudiante: $e');
      return false;
    }
  }

  // Buscar estudiantes por nombre
  Future<List<Student>> searchStudents(String query) async {
    try {
      final students = await getAllStudents();
      final lowercaseQuery = query.toLowerCase();

      return students.where((student) {
        return student.firstName.toLowerCase().contains(lowercaseQuery) ||
            student.lastName.toLowerCase().contains(lowercaseQuery) ||
            student.email.toLowerCase().contains(lowercaseQuery) ||
            student.grade.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error buscando estudiantes: $e');
      return [];
    }
  }

  // Obtener estudiantes por grado
  Future<List<Student>> getStudentsByGrade(String grade) async {
    try {
      final students = await getAllStudents();
      return students.where((student) => student.grade == grade).toList();
    } catch (e) {
      debugPrint('Error obteniendo estudiantes por grado: $e');
      return [];
    }
  }

  // Obtener estudiantes activos
  Future<List<Student>> getActiveStudents() async {
    try {
      final students = await getAllStudents();
      return students.where((student) => student.isActive).toList();
    } catch (e) {
      debugPrint('Error obteniendo estudiantes activos: $e');
      return [];
    }
  }

  // Contar estudiantes por grado
  Future<Map<String, int>> getStudentCountByGrade() async {
    try {
      final students = await getAllStudents();
      Map<String, int> gradeCount = {};

      for (Student student in students) {
        if (student.isActive) {
          gradeCount[student.grade] = (gradeCount[student.grade] ?? 0) + 1;
        }
      }

      return gradeCount;
    } catch (e) {
      debugPrint('Error contando estudiantes por grado: $e');
      return {};
    }
  }

  // Limpiar todos los datos de estudiantes
  Future<void> clearAllStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_studentsKey);
    } catch (e) {
      debugPrint('Error limpiando datos de estudiantes: $e');
    }
  }

  // Obtener estudiantes desde la API (para futuras implementaciones)
  Future<List<Student>?> getStudentsFromAPI() async {
    try {
      // Este método se puede implementar cuando el backend tenga un endpoint específico para estudiantes
      // Por ahora retornamos null para usar solo datos locales
      return null;
    } catch (e) {
      debugPrint('Error obteniendo estudiantes de la API: $e');
      return null;
    }
  }

  // Sincronizar estudiantes locales con la API (para futuras implementaciones)
  Future<bool> syncStudentsWithAPI() async {
    try {
      // Este método se puede implementar para sincronizar datos locales con el servidor
      // Por ahora retornamos true para indicar que no hay necesidad de sincronización
      return true;
    } catch (e) {
      debugPrint('Error sincronizando estudiantes: $e');
      return false;
    }
  }
}
