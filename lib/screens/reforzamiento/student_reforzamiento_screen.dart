import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/material_reforzamiento_model.dart';
import '../../services/user_service.dart';
import '../../services/student_subject_service.dart';
import '../../services/enrollment_api_service.dart';
import '../../services/reforzamiento_api_service.dart';
import '../../services/grades_api_service.dart';
import '../../services/attendance_api_service.dart';
import 'student_material_detail_screen.dart';

class StudentReforzamientoScreen extends StatefulWidget {
  const StudentReforzamientoScreen({super.key});

  @override
  State<StudentReforzamientoScreen> createState() =>
      _StudentReforzamientoScreenState();
}

class _StudentReforzamientoScreenState extends State<StudentReforzamientoScreen>
    with SingleTickerProviderStateMixin {
  final StudentSubjectService _subjectService = StudentSubjectService();
  final ReforzamientoApiService _reforzamientoService =
      ReforzamientoApiService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();
  final GradesApiService _gradesService = GradesApiService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

  List<Subject> _subjects = [];
  Map<int, List<MaterialReforzamiento>> _materialesPorMateria = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      // Obtener estudiante_id
      final estudianteId = await _enrollmentService.getStudentIdByUserId(user.id!);
      if (estudianteId == null) {
        if (mounted) {
          _showError('No se encontró información del estudiante');
          setState(() => _isLoading = false);
        }
        return;
      }

      // Cargar materias inscritas
      final allSubjects = await _subjectService.getStudentSubjects(user.id!);

      // Obtener todas las notas del estudiante para calcular promedios
      final allGrades = await _gradesService.getAllStudentGrades(
        estudianteId: estudianteId,
      );

      // Filtrar solo materias donde el estudiante está REPROBADO (promedio < 60)
      // Y donde el ciclo académico ya terminó (fecha_fin ya pasó)
      final reprobadosMap = <int, double>{}; // materiaId -> promedio
      final fechaActual = DateTime.now();

      for (var grade in allGrades) {
        if (grade.promedio != null && grade.promedio! < 60.0) {
          // Verificar que el ciclo académico ya terminó
          try {
            final materiaId = grade.materiaId;
            final anioAcademico = int.tryParse(grade.anioAcademico) ?? DateTime.now().year;
            
            // Obtener configuración de la materia para verificar fecha de fin
            final config = await _attendanceService.getSubjectConfiguration(
              materiaId,
              anioAcademico,
            );

            // Solo incluir si el ciclo ya terminó (fecha actual >= fecha fin)
            if (config != null) {
              // Comparar solo las fechas (sin hora)
              final fechaActualSinHora = DateTime(fechaActual.year, fechaActual.month, fechaActual.day);
              final fechaFinSinHora = DateTime(config.endDate.year, config.endDate.month, config.endDate.day);
              final cicloTerminado = fechaActualSinHora.isAfter(fechaFinSinHora) || fechaActualSinHora.isAtSameMomentAs(fechaFinSinHora);
              
              if (cicloTerminado) {
                reprobadosMap[materiaId] = grade.promedio!;
              }
            } else {
              // Si no hay configuración, por seguridad NO mostrar (ciclo podría estar en curso)
              print('⚠️ No se encontró configuración para materia $materiaId, año $anioAcademico');
            }
          } catch (e) {
            print('❌ Error validando fecha fin para materia ${grade.materiaId}: $e');
            // Por seguridad, no incluir materias con error
          }
        }
      }

      // Filtrar materias: solo las reprobadas Y con ciclo terminado
      final subjects = allSubjects.where((subject) {
        final materiaId = int.parse(subject.id!);
        return reprobadosMap.containsKey(materiaId);
      }).toList();

      // Cargar materiales para cada materia reprobada
      final Map<int, List<MaterialReforzamiento>> materialesMap = {};
      for (var subject in subjects) {
        try {
          final materiales = await _reforzamientoService.obtenerMaterialEstudiante(
            estudianteId: estudianteId,
            materiaId: int.parse(subject.id!),
          );
          if (materiales.isNotEmpty) {
            materialesMap[int.parse(subject.id!)] = materiales;
          }
        } catch (e) {
          print('Error cargando materiales para ${subject.name}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _materialesPorMateria = materialesMap;
          _isLoading = false;
        });

        // Inicializar TabController después de cargar las materias
        if (_subjects.isNotEmpty) {
          _tabController = TabController(
            length: _subjects.length,
            vsync: this,
          );
        }
      }
    } catch (e) {
      print('❌ ERROR StudentReforzamientoScreen._loadData: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material de Reforzamiento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: _isLoading || _subjects.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _subjects.map((subject) {
                  final tieneMaterial = _materialesPorMateria
                          .containsKey(int.parse(subject.id!)) &&
                      _materialesPorMateria[int.parse(subject.id!)]!.isNotEmpty;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(subject.name),
                        if (tieneMaterial) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(
                        '¡Felicitaciones!',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes materias reprobadas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(Solo se muestran materias con promedio < 60)',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _subjects.map((subject) {
                    final materiales = _materialesPorMateria[
                            int.parse(subject.id!)] ??
                        [];

                    return _buildMateriaTab(subject, materiales);
                  }).toList(),
                ),
    );
  }

  Widget _buildMateriaTab(Subject subject, List<MaterialReforzamiento> materiales) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de materia
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'REPROBADO',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.grade} - ${subject.section}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (subject.teacherName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Profesor: ${subject.teacherName}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de materiales
          if (materiales.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay material de reforzamiento disponible',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu profesor subirá material cuando sea necesario',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...materiales.map((material) => _buildMaterialCard(material)),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialReforzamiento material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StudentMaterialDetailScreen(material: material),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[100],
                radius: 28,
                child: Text(
                  material.tipoIcono,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (material.esNuevo)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NUEVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (material.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        material.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          material.fechaPublicacion != null
                              ? '${material.fechaPublicacion!.toString().split(' ')[0]}'
                              : 'Sin fecha',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (material.fechaVencimiento != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.event, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Vence: ${material.fechaVencimiento!.toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: material.estaVencido
                                  ? Colors.red
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

