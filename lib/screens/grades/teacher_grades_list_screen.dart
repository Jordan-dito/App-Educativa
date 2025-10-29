import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/subject_api_service.dart';
import '../../services/teacher_api_service.dart';
import '../../services/user_service.dart';
import 'teacher_students_grades_screen.dart';

class TeacherGradesListScreen extends StatefulWidget {
  const TeacherGradesListScreen({super.key});

  @override
  State<TeacherGradesListScreen> createState() => _TeacherGradesListScreenState();
}

class _TeacherGradesListScreenState extends State<TeacherGradesListScreen> {
  final SubjectApiService _subjectService = SubjectApiService();
  final TeacherApiService _teacherService = TeacherApiService();
  
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

      // Obtener todos los profesores para encontrar el que corresponde al usuario
      final allTeachers = await _teacherService.getAllTeachers();
      final userEmail = user.email.toLowerCase();
      
      final teacher = allTeachers.firstWhere(
        (t) => t.email.toLowerCase() == userEmail,
        orElse: () => throw Exception('No se encontró el profesor'),
      );

      // Cargar materias del profesor
      final subjects = await _subjectService.getSubjectsByTeacher(teacher.id.toString());
      
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR TeacherGradesListScreen._loadSubjects: $e');
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherStudentsGradesScreen(
                                subject: subject,
                                profesorId: int.tryParse(subject.teacherId ?? '0') ?? 0,
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

