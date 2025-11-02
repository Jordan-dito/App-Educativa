import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/subject_api_service.dart';
import '../../services/teacher_api_service.dart';
import '../../services/user_service.dart';
import 'teacher_students_grades_screen.dart';

class TeacherGradesListScreen extends StatefulWidget {
  const TeacherGradesListScreen({super.key});

  @override
  State<TeacherGradesListScreen> createState() =>
      _TeacherGradesListScreenState();
}

class _TeacherGradesListScreenState extends State<TeacherGradesListScreen> {
  final SubjectApiService _subjectService = SubjectApiService();
  final TeacherApiService _teacherService = TeacherApiService();

  List<Subject> _subjects = [];
  int? _currentProfesorId; // Guardar el profesor_id del usuario actual
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Obtener el usuario logueado
      final user = await UserService.getCurrentUser();

      if (user == null) {
        if (mounted) {
          _showError('No se pudo obtener la información del usuario');
          setState(() => _isLoading = false);
        }
        return;
      }

      // Obtener el profesor_id del usuario (viene del login en user_data.id)
      int profesorId;

      if (user.profesorId != null) {
        // Si ya tiene el profesor_id guardado, usarlo directamente
        profesorId = user.profesorId!;
        print(
            '✅ DEBUG TeacherGradesListScreen: Usando profesor_id del usuario: $profesorId');
      } else {
        // Si no tiene profesor_id, buscarlo por email (fallback)
        print(
            '⚠️ DEBUG TeacherGradesListScreen: No hay profesor_id, buscando por email...');
        final allTeachers = await _teacherService.getAllTeachers();
        final userEmail = user.email.toLowerCase();

        final teacher = allTeachers.firstWhere(
          (t) => t.email.toLowerCase() == userEmail,
          orElse: () => throw Exception('No se encontró el profesor'),
        );

        profesorId = teacher.id!;
        print(
            '✅ DEBUG TeacherGradesListScreen: Profesor encontrado por email, ID: $profesorId');
      }

      // Cargar materias del profesor usando el profesor_id
      final subjects =
          await _subjectService.getSubjectsByTeacher(profesorId.toString());

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _currentProfesorId =
              profesorId; // Guardar el profesor_id para usar en navegación
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR TeacherGradesListScreen._loadSubjects: $e');
      if (mounted) {
        _showError('Error al cargar materias: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Notas'),
        backgroundColor: Colors.purple,
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: const Icon(Icons.book, color: Colors.purple),
                        ),
                        title: Text(
                          subject.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${subject.grade} - ${subject.section}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Usar el profesor_id del usuario actual, no el de la materia
                          if (_currentProfesorId != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TeacherStudentsGradesScreen(
                                  subject: subject,
                                  profesorId: _currentProfesorId!,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) {
                                _loadSubjects(); // Recargar al volver
                              }
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
