import '../models/student.dart';
import 'auth_service.dart';

class StudentApiService {
  static final StudentApiService _instance = StudentApiService._internal();
  factory StudentApiService() => _instance;
  StudentApiService._internal();

  // Obtener todos los estudiantes desde la API
  Future<List<Student>> getAllStudents() async {
    try {
      print(
          '🎓 DEBUG StudentApiService.getAllStudents: Obteniendo estudiantes desde API...');

      final response = await AuthService.getStudents();

      if (response.success && response.data != null) {
        final students =
            response.data!.map((json) => Student.fromJson(json)).toList();

        print(
            '🎓 DEBUG StudentApiService.getAllStudents: ${students.length} estudiantes obtenidos');
        return students;
      } else {
        print(
            '❌ DEBUG StudentApiService.getAllStudents: Error: ${response.message}');
        return [];
      }
    } catch (e) {
      print('❌ DEBUG StudentApiService.getAllStudents: Error: $e');
      return [];
    }
  }

  // Eliminar estudiante
  Future<bool> deleteStudent(int studentId) async {
    try {
      print(
          '🎓 DEBUG StudentApiService.deleteStudent: Eliminando estudiante $studentId...');

      final response = await AuthService.deleteStudent(studentId);

      if (response.success) {
        print(
            '✅ DEBUG StudentApiService.deleteStudent: Estudiante eliminado exitosamente');
        return true;
      } else {
        print(
            '❌ DEBUG StudentApiService.deleteStudent: Error: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ DEBUG StudentApiService.deleteStudent: Error: $e');
      return false;
    }
  }
}
