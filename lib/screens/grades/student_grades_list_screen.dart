import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/student_subject_service.dart';
import '../../services/user_service.dart';
import '../../services/enrollment_api_service.dart';
import 'student_materia_grades_screen.dart';
import '../reporte/reporte_notas_screen.dart';

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

      // Cargar materias del estudiante (solo sus materias inscritas)
      final subjects = await _subjectService.getStudentSubjects(user.id!);

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR StudentGradesListScreen._loadSubjects: $e');
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

  Future<void> _verReporte() async {
    try {
      debugPrint('📊 DEBUG StudentGradesListScreen._verReporte: Iniciando...');
      
      final user = await UserService.getCurrentUser();
      if (user == null || !mounted) {
        debugPrint('❌ ERROR: No se pudo obtener la información del usuario');
        _showError('No se pudo obtener la información del usuario');
        return;
      }

      debugPrint('📊 DEBUG: Usuario obtenido - ID: ${user.id}, Email: ${user.email}, Nombre: ${user.nombre} ${user.apellido}');

      final estudianteId =
          await _enrollmentService.getStudentIdByUserId(user.id!);
      
      debugPrint('📊 DEBUG: estudiante_id obtenido: $estudianteId');
      
      if (estudianteId == null || !mounted) {
        debugPrint('❌ ERROR: No se pudo obtener el estudiante_id para el usuario ${user.id}');
        _showError('Error al obtener información del estudiante. Verifica que estés registrado como estudiante en el sistema.');
        return;
      }

      if (!mounted) return;
      
      debugPrint('📊 DEBUG: Navegando a ReporteNotasScreen con estudiante_id: $estudianteId');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReporteNotasScreen(
            estudianteId: estudianteId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR _verReporte: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        _showError('Error al abrir el reporte: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Ver Reporte de Notas',
            onPressed: _verReporte,
          ),
        ],
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
                          if (!mounted) return;
                          final user = await UserService.getCurrentUser();
                          if (user == null || !mounted) return;

                          final estudianteId = await _enrollmentService
                              .getStudentIdByUserId(user.id!);
                          if (estudianteId == null || !mounted) {
                            _showError(
                                'Error al obtener información del estudiante');
                            return;
                          }

                          if (!mounted) return;
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
