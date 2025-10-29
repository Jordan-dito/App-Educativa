import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/grade_model.dart';
import '../../services/grades_api_service.dart';
import '../../services/attendance_api_service.dart';
import 'teacher_grades_form_screen.dart';

class TeacherStudentsGradesScreen extends StatefulWidget {
  final Subject subject;
  final int profesorId;

  const TeacherStudentsGradesScreen({
    super.key,
    required this.subject,
    required this.profesorId,
  });

  @override
  State<TeacherStudentsGradesScreen> createState() =>
      _TeacherStudentsGradesScreenState();
}

class _TeacherStudentsGradesScreenState
    extends State<TeacherStudentsGradesScreen> {
  final GradesApiService _gradesService = GradesApiService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

  List<Map<String, dynamic>> _students = [];
  Map<int, Grade?> _grades = {}; // Map<estudianteId, Grade>
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentsAndGrades();
  }

  Future<void> _loadStudentsAndGrades() async {
    setState(() => _isLoading = true);

    try {
      // Cargar estudiantes inscritos en la materia
      final students = await _attendanceService
          .getInscribedStudents(int.parse(widget.subject.id!));

      // Cargar notas de todos los estudiantes
      final grades = await _gradesService.getMatterGrades(
        materiaId: int.parse(widget.subject.id!),
        profesorId: widget.profesorId,
        anioAcademico: DateTime.now().year.toString(),
      );

      // Crear mapa de notas por estudiante
      final Map<int, Grade?> gradesMap = {};
      for (var grade in grades) {
        gradesMap[grade.estudianteId] = grade;
      }

      setState(() {
        _students = students;
        _grades = gradesMap;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR TeacherStudentsGradesScreen._loadStudentsAndGrades: $e');
      _showError('Error al cargar datos: $e');
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

  Future<void> _navigateToGradesForm(
      Map<String, dynamic> studentData, Grade? existingGrade) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherGradesFormScreen(
          studentId: studentData['estudiante_id'] ?? 0,
          studentName: studentData['nombre_estudiante'] ?? 'Estudiante',
          subject: widget.subject,
          profesorId: widget.profesorId,
          existingGrade: existingGrade,
        ),
      ),
    );

    if (result == true) {
      // Recargar datos después de guardar
      await _loadStudentsAndGrades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar: ${widget.subject.name}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estudiantes inscritos en esta materia',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final studentData = _students[index];
                    final studentId = studentData['estudiante_id'] ?? 0;
                    final grade = _grades[studentId];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: Text(
                            (studentData['nombre_estudiante'] ?? 'E')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        title: Text(
                          studentData['nombre_estudiante'] ?? 'Estudiante',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: grade?.promedio != null
                            ? Row(
                                children: [
                                  Icon(
                                    grade!.aprobado
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 16,
                                    color: grade.aprobado
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Promedio: ${grade.promedio!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            : const Text('Sin calificar'),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _navigateToGradesForm(studentData, grade),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                grade == null ? Colors.purple : Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(grade == null ? 'Calificar' : 'Editar'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
