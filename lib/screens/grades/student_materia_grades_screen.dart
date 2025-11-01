import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/grade_model.dart';
import '../../services/grades_api_service.dart';

class StudentMateriaGradesScreen extends StatefulWidget {
  final Subject subject;
  final int estudianteId;

  const StudentMateriaGradesScreen({
    super.key,
    required this.subject,
    required this.estudianteId,
  });

  @override
  State<StudentMateriaGradesScreen> createState() =>
      _StudentMateriaGradesScreenState();
}

class _StudentMateriaGradesScreenState
    extends State<StudentMateriaGradesScreen> {
  final GradesApiService _gradesService = GradesApiService();

  Grade? _grade;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);

    try {
      final grade = await _gradesService.getStudentGradeInMatter(
        estudianteId: widget.estudianteId,
        materiaId: int.parse(widget.subject.id!),
        anioAcademico: DateTime.now().year.toString(),
      );

      setState(() {
        _grade = grade;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR StudentMateriaGradesScreen._loadGrades: $e');
      _showError('Error al cargar notas: $e');
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

  Color _getNoteColor(double? nota) {
    if (nota == null) return Colors.grey;
    if (nota >= 90) return Colors.green;
    if (nota >= 80) return Colors.lightGreen;
    if (nota >= 70) return Colors.yellow;
    if (nota >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grade == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grade, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay notas registradas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Las notas aparecerán cuando tu profesor las califique',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Información de la materia
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subject.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.subject.grade} - ${widget.subject.section}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (widget.subject.teacherName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Profesor: ${widget.subject.teacherName}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notas individuales
                      const Text(
                        'Notas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildNoteCard('Nota 1 - Unidad 1', _grade!.nota1, 1),
                      const SizedBox(height: 12),
                      _buildNoteCard('Nota 2 - Unidad 2', _grade!.nota2, 2),
                      const SizedBox(height: 12),
                      _buildNoteCard('Nota 3 - Unidad 3', _grade!.nota3, 3),
                      const SizedBox(height: 12),
                      _buildNoteCard('Nota 4 - Unidad 4', _grade!.nota4, 4),
                      const SizedBox(height: 24),

                      // Promedio y estado
                      Card(
                        color: _grade!.aprobado
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'Promedio Final',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _grade!.promedio != null
                                    ? _grade!.promedio!.toStringAsFixed(2)
                                    : 'N/A',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _grade!.aprobado
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Chip(
                                avatar: Icon(
                                  _grade!.aprobado
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: Text(
                                  _grade!.estadoTextoCompleto,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                backgroundColor: _grade!.aprobado
                                    ? Colors.green
                                    : Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoteCard(String label, double? nota, int index) {
    final color = _getNoteColor(nota);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            '$index',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          nota != null ? nota.toStringAsFixed(2) : 'N/A',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: nota != null ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}
