import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/student_subject_service.dart';
import '../../services/user_service.dart';
import '../../services/enrollment_api_service.dart';
import 'student_materia_grades_screen.dart';

class StudentGradesListScreen extends StatefulWidget {
  const StudentGradesListScreen({super.key});

  @override
  State<StudentGradesListScreen> createState() =>
      _StudentGradesListScreenState();
}

class _StudentGradesListScreenState extends State<StudentGradesListScreen> {
  final StudentSubjectService _subjectService = StudentSubjectService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();

  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);

    try {
      // Obtener el usuario logueado
      final user = await UserService.getCurrentUser();

      if (user == null) {
        _showError('No se pudo obtener la información del usuario');
        return;
      }

      // Cargar materias del estudiante (solo sus materias inscritas)
      final subjects = await _subjectService.getStudentSubjects(user.id!);

      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR StudentGradesListScreen._loadSubjects: $e');
      _showError('Error al cargar materias: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No estás inscrito en ninguna materia',
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
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.book, color: Colors.blue),
                        ),
                        title: Text(
                          subject.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${subject.grade} - ${subject.section} • ${subject.teacherName ?? "Sin profesor"}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final user = await UserService.getCurrentUser();
                          if (user == null) return;

                          final estudianteId = await _enrollmentService
                              .getStudentIdByUserId(user.id!);
                          if (estudianteId == null) {
                            _showError(
                                'Error al obtener información del estudiante');
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentMateriaGradesScreen(
                                subject: subject,
                                estudianteId: estudianteId,
                              ),
                            ),
                          ).then((_) => _loadSubjects()); // Recargar al volver
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
