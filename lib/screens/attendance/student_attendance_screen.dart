import 'package:flutter/material.dart';
import '../../models/subject_configuration_model.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_api_service.dart';
import '../../services/user_service.dart';
import '../../services/enrollment_api_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final SubjectConfiguration configuration;

  const StudentAttendanceScreen({
    super.key,
    required this.configuration,
  });

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final AttendanceApiService _attendanceService = AttendanceApiService();

  StudentAttendanceSummary? _summary;
  List<AttendanceRecord> _recentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await UserService.getCurrentUser();
      if (user == null) {
        _showErrorMessage('No se pudo obtener la información del usuario');
        return;
      }

      print('🎓 DEBUG StudentAttendanceScreen: Usuario actual:');
      print('   ID: ${user.id}, Email: ${user.email}');

      // Obtener el estudiante_id del usuario_id
      // Necesitamos usar EnrollmentApiService para obtener el estudiante_id real
      final enrollmentService = EnrollmentApiService();
      final estudianteId = await enrollmentService.getStudentIdByUserId(user.id!);

      if (estudianteId == null) {
        _showErrorMessage('No se encontró el estudiante asociado a este usuario');
        return;
      }

      print('🎓 DEBUG StudentAttendanceScreen: estudiante_id encontrado: $estudianteId');
      print('🎓 DEBUG StudentAttendanceScreen: materia_id: ${widget.configuration.subjectId}');

      // Cargar resumen de asistencia usando estudiante_id real y materia_id
      final summary = await _attendanceService.getStudentAttendanceSummary(
        estudianteId,
        widget.configuration.subjectId, // Usar materia_id en lugar de config.id
      );

      // Cargar historial reciente
      final history = await _attendanceService.getStudentAttendanceHistory(
        estudianteId,
        widget.configuration.subjectId, // Usar materia_id en lugar de config.id
      );

      print('🎓 DEBUG StudentAttendanceScreen:');
      print('   Resumen: ${summary != null ? "OK" : "null"}');
      print('   Historial: ${history.length} registros');

      setState(() {
        _summary = summary;
        _recentHistory = history.take(10).toList(); // Solo los últimos 10 registros
      });
    } catch (e) {
      print('❌ ERROR StudentAttendanceScreen._loadData: $e');
      _showErrorMessage('Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.justified:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.justified:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Asistencia'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron datos de asistencia',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información de la materia
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.book, color: Colors.indigo[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Materia - ${widget.configuration.subjectId}', // Aquí deberías mostrar el nombre real
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Período: ${_formatDate(widget.configuration.startDate)} - ${_formatDate(widget.configuration.endDate)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Estadísticas principales
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estadísticas de Asistencia',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Presentes',
                                      _summary!.presentCount.toString(),
                                      Colors.green,
                                      Icons.check_circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Ausentes',
                                      _summary!.absentCount.toString(),
                                      Colors.red,
                                      Icons.cancel,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Tardanzas',
                                      _summary!.lateCount.toString(),
                                      Colors.orange,
                                      Icons.access_time,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Justificados',
                                      _summary!.justifiedCount.toString(),
                                      Colors.blue,
                                      Icons.info,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Porcentaje y meta
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Porcentaje de Asistencia',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${_summary!.attendancePercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _summary!.meetsGoal ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Meta: ${_summary!.goalPercentage}%',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        _summary!.meetsGoal ? Icons.check_circle : Icons.warning,
                                        color: _summary!.meetsGoal ? Colors.green : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _summary!.meetsGoal ? 'Cumple meta' : 'No cumple meta',
                                        style: TextStyle(
                                          color: _summary!.meetsGoal ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Barra de progreso
                              LinearProgressIndicator(
                                value: _summary!.attendancePercentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _summary!.meetsGoal ? Colors.green : Colors.red,
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Historial reciente
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Últimas Clases',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_recentHistory.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(Icons.history, size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No hay historial disponible',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ..._recentHistory.map((record) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(record.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              _getStatusIcon(record.status),
                                              color: _getStatusColor(record.status),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatDate(record.classDate),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  record.status.value.toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getStatusColor(record.status),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
