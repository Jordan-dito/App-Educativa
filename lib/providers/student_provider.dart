import 'package:flutter/material.dart';
import '../services/student_api_service.dart';

class StudentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final StudentApiService _studentService = StudentApiService();

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Eliminar estudiante
  Future<bool> deleteStudent(int studentId) async {
    try {
      _setLoading(true);
      clearError();

      print(
          '🎓 DEBUG StudentProvider.deleteStudent: Eliminando estudiante $studentId...');

      final success = await _studentService.deleteStudent(studentId);

      if (success) {
        print(
            '✅ DEBUG StudentProvider.deleteStudent: Estudiante eliminado exitosamente');
      } else {
        _setError('Error al eliminar el estudiante');
      }

      return success;
    } catch (e) {
      print('❌ DEBUG StudentProvider.deleteStudent: Error: $e');
      _setError('Error al eliminar el estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
