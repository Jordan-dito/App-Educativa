import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/user_service.dart';
import '../../services/subject_api_service.dart';
import '../../services/teacher_api_service.dart';
import 'teacher_estudiantes_reprobados_screen.dart';

class TeacherReforzamientoScreen extends StatefulWidget {
  const TeacherReforzamientoScreen({super.key});

  @override
  State<TeacherReforzamientoScreen> createState() =>
      _TeacherReforzamientoScreenState();
}

class _TeacherReforzamientoScreenState
    extends State<TeacherReforzamientoScreen> {
  final SubjectApiService _subjectService = SubjectApiService();
  final TeacherApiService _teacherService = TeacherApiService();

  List<Subject> _subjects = [];
  int? _currentProfesorId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = await UserService.getCurrentUser();
      if (user == null) {
        if (mounted) {
          _showError('No se pudo obtener la información del usuario');
          setState(() => _isLoading = false);
        }
        return;
      }

      // Obtener el profesor_id
      final allTeachers = await _teacherService.getAllTeachers();
      final userEmail = user.email.toLowerCase();

      final teacher = allTeachers.firstWhere(
        (t) => t.email.toLowerCase() == userEmail,
        orElse: () => throw Exception('No se encontró el profesor'),
      );

      _currentProfesorId = teacher.id;
      if (_currentProfesorId == null) {
        throw Exception('No se pudo obtener el ID del profesor');
      }

      // Cargar materias del profesor
      final subjects = await _subjectService
          .getSubjectsByTeacher(_currentProfesorId.toString());

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR TeacherReforzamientoScreen._loadData: $e');
      if (mounted) {
        _showError('Error al cargar datos: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToMateria(Subject subject) {
    if (_currentProfesorId == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherEstudiantesReprobadosScreen(
          subject: subject,
          profesorId: _currentProfesorId!,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reforzamiento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes materias asignadas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: const Icon(Icons.school, color: Colors.orange),
                        ),
                        title: Text(
                          subject.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${subject.grade} - ${subject.section} • ${subject.teacherName ?? "Sin profesor"}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _navigateToMateria(subject),
                      ),
                    );
                  },
                ),
    );
  }
}
