import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/estudiante_reprobado_model.dart';
import '../../services/reforzamiento_api_service.dart';
import '../../services/attendance_api_service.dart';
import 'teacher_subir_material_screen.dart';
// Removido: teacher_material_estudiante_screen.dart - El estudiante ya puede ver su material

class TeacherEstudiantesReprobadosScreen extends StatefulWidget {
  final Subject subject;
  final int profesorId;

  const TeacherEstudiantesReprobadosScreen({
    super.key,
    required this.subject,
    required this.profesorId,
  });

  @override
  State<TeacherEstudiantesReprobadosScreen> createState() =>
      _TeacherEstudiantesReprobadosScreenState();
}

class _TeacherEstudiantesReprobadosScreenState
    extends State<TeacherEstudiantesReprobadosScreen> {
  final ReforzamientoApiService _reforzamientoService =
      ReforzamientoApiService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

  List<EstudianteReprobado> _estudiantesReprobados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstudiantesReprobados();
  }

  Future<void> _loadEstudiantesReprobados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Validar que el ciclo académico ya terminó
      final anioAcademico = int.tryParse(widget.subject.academicYear) ?? DateTime.now().year;
      final config = await _attendanceService.getSubjectConfiguration(
        int.parse(widget.subject.id!),
        anioAcademico,
      );

      if (config == null) {
        // No hay configuración, mostrar advertencia pero permitir continuar
        print('⚠️ No se encontró configuración para la materia, validación de fecha no aplica');
      } else {
        // Validar que el ciclo académico ya terminó
        final fechaActual = DateTime.now();
        // Comparar solo las fechas (sin hora) para determinar si el ciclo terminó
        final fechaActualSinHora = DateTime(fechaActual.year, fechaActual.month, fechaActual.day);
        final fechaFinSinHora = DateTime(config.endDate.year, config.endDate.month, config.endDate.day);
        final cicloTerminado = fechaActualSinHora.isAfter(fechaFinSinHora) || fechaActualSinHora.isAtSameMomentAs(fechaFinSinHora);

        if (!cicloTerminado) {
          // El ciclo aún no termina
          if (mounted) {
            _showError('El ciclo académico aún no ha terminado. La fecha de fin es: ${config.endDate.toString().split(' ')[0]}');
            setState(() {
              _estudiantesReprobados = [];
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Obtener estudiantes reprobados
      final estudiantes = await _reforzamientoService
          .obtenerEstudiantesReprobados(
        materiaId: int.parse(widget.subject.id!),
        profesorId: widget.profesorId,
      );

      if (mounted) {
        setState(() {
          _estudiantesReprobados = estudiantes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR TeacherEstudiantesReprobadosScreen._loadEstudiantesReprobados: $e');
      if (mounted) {
        _showError('Error al cargar estudiantes reprobados: $e');
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

  void _navigateToSubirMaterial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherSubirMaterialScreen(
          subject: widget.subject,
          profesorId: widget.profesorId,
          estudiantesReprobados: _estudiantesReprobados,
        ),
      ),
    ).then((_) => _loadEstudiantesReprobados());
  }

  // Removido: _navigateToMaterialEstudiante
  // El estudiante ya puede ver su material desde su pantalla, no es necesario que el profesor lo vea también

  Color _getPromedioColor(double promedio) {
    if (promedio < 40) return Colors.red;
    if (promedio < 50) return Colors.deepOrange;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes Reprobados - ${widget.subject.name}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _estudiantesReprobados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estudiantes reprobados en esta materia',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Info de la materia
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.subject.grade} - ${widget.subject.section}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total de reprobados: ${_estudiantesReprobados.length}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lista de estudiantes
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _estudiantesReprobados.length,
                        itemBuilder: (context, index) {
                          final estudiante =
                              _estudiantesReprobados[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getPromedioColor(estudiante.promedio)
                                        .withOpacity(0.2),
                                child: Text(
                                  estudiante.nombreEstudiante[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _getPromedioColor(estudiante.promedio),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                estudiante.nombreEstudiante,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      'Promedio: ${estudiante.promedio.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    backgroundColor:
                                        _getPromedioColor(estudiante.promedio),
                                    padding: EdgeInsets.zero,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                  ),
                                ],
                              ),
                              // Removido onTap - El estudiante ya puede ver su material desde su pantalla
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSubirMaterial,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Subir Material'),
      ),
    );
  }
}

