import '../models/teacher.dart' as api_teacher;
import 'auth_service.dart';

class TeacherApiService {
  static final TeacherApiService _instance = TeacherApiService._internal();
  factory TeacherApiService() => _instance;
  TeacherApiService._internal();

  // Obtener todos los profesores desde la API
  Future<List<api_teacher.Teacher>> getAllTeachers() async {
    try {
      print('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: Obteniendo profesores desde API...');
      
      final response = await AuthService.getTeachers();
      
      if (response.success && response.data != null) {
        final teachers = response.data!
            .map((json) => api_teacher.Teacher.fromJson(json))
            .toList();
        
        print('👨‍🏫 DEBUG TeacherApiService.getAllTeachers: ${teachers.length} profesores obtenidos');
        return teachers;
      } else {
        print('❌ DEBUG TeacherApiService.getAllTeachers: Error: ${response.message}');
        return [];
      }
    } catch (e) {
      print('❌ DEBUG TeacherApiService.getAllTeachers: Error: $e');
      return [];
    }
  }

  // Eliminar profesor (por ahora solo retorna true para compatibilidad)
  Future<bool> deleteTeacher(int teacherId) async {
    try {
      print('👨‍🏫 DEBUG TeacherApiService.deleteTeacher: Eliminando profesor $teacherId...');
      // TODO: Implementar endpoint de eliminación cuando esté disponible
      print('⚠️ DEBUG TeacherApiService.deleteTeacher: Endpoint de eliminación no implementado aún');
      return true;
    } catch (e) {
      print('❌ DEBUG TeacherApiService.deleteTeacher: Error: $e');
      return false;
    }
  }
}
