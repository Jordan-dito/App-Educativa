import 'package:flutter/material.dart';
import '../../models/subject_configuration_model.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_api_service.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final SubjectConfiguration configuration;

  const TakeAttendanceScreen({
    super.key,
    required this.configuration,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final AttendanceApiService _attendanceService = AttendanceApiService();

  List<Map<String, dynamic>> _students = [];
  Map<int, AttendanceStatus> _attendanceStatus = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _checkExistingAttendance();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      final students = await _attendanceService.getEnrolledStudents(widget.configuration.id!);
      setState(() {
        _students = students;
        // Inicializar todos como ausentes por defecto
        for (var student in students) {
          _attendanceStatus[student['id']] = AttendanceStatus.absent;
        }
      });
    } catch (e) {
      _showErrorMessage('Error al cargar estudiantes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkExistingAttendance() async {
    try {
      final hasAttendance = await _attendanceService.hasAttendanceForDate(
        widget.configuration.id!,
        _selectedDate,
      );

      if (hasAttendance) {
        _loadExistingAttendance();
      }
    } catch (e) {
      print('Error checking existing attendance: $e');
    }
  }

  Future<void> _loadExistingAttendance() async {
    try {
      final records = await _attendanceService.getAttendanceByDate(
        widget.configuration.id!,
        _selectedDate,
      );

      setState(() {
        for (var record in records) {
          _attendanceStatus[record.studentId] = record.status;
        }
      });
    } catch (e) {
      print('Error loading existing attendance: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.configuration.startDate,
      lastDate: widget.configuration.endDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _attendanceStatus.clear();
      });
      _checkExistingAttendance();
      _loadStudents();
    }
  }

  void _setAttendanceStatus(int studentId, AttendanceStatus status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  AttendanceStatus _getAttendanceStatus(int studentId) {
    return _attendanceStatus[studentId] ?? AttendanceStatus.absent;
  }

  int _getAttendanceCount(AttendanceStatus status) {
    return _attendanceStatus.values.where((s) => s == status).length;
  }

  double _getAttendancePercentage() {
    if (_students.isEmpty) return 0.0;
    final presentCount = _getAttendanceCount(AttendanceStatus.present);
    return (presentCount / _students.length) * 100;
  }

  bool _isValidClassDay() {
    final dayNames = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    final selectedDayName = dayNames[_selectedDate.weekday - 1];
    return widget.configuration.classDays.contains(selectedDayName);
  }

  Future<void> _saveAttendance() async {
    if (!_isValidClassDay()) {
      _showErrorMessage('No hay clases programadas para este día');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final records = _attendanceStatus.entries.map((entry) {
        return AttendanceRecord(
          subjectConfigurationId: widget.configuration.id!,
          studentId: entry.key,
          classDate: _selectedDate,
          status: entry.value,
        );
      }).toList();

      final success = await _attendanceService.createMultipleAttendanceRecords(records);

      if (success) {
        _showSuccessMessage('Asistencia guardada exitosamente');
      } else {
        _showErrorMessage('Error al guardar la asistencia');
      }
    } catch (e) {
      _showErrorMessage('Error al guardar: $e');
    } finally {
      setState(() => _isSaving = false);
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar Asistencia'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la clase
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.indigo[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color: Colors.indigo[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.configuration.subjectId.toString(), // Aquí deberías mostrar el nombre de la materia
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
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    if (widget.configuration.classTime != null) ...[
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        widget.configuration.classTime!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                if (!_isValidClassDay())
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'No hay clases programadas para este día',
                          style: TextStyle(color: Colors.orange[700], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Lista de estudiantes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay estudiantes inscritos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final studentId = student['id'];
                          final currentStatus = _getAttendanceStatus(studentId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getStatusColor(currentStatus).withOpacity(0.1),
                                    child: Icon(
                                      _getStatusIcon(currentStatus),
                                      color: _getStatusColor(currentStatus),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student['name'] ?? 'Estudiante',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${student['id']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botones de estado
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildStatusButton(
                                        AttendanceStatus.present,
                                        studentId,
                                        Colors.green,
                                        Icons.check,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusButton(
                                        AttendanceStatus.absent,
                                        studentId,
                                        Colors.red,
                                        Icons.close,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusButton(
                                        AttendanceStatus.late,
                                        studentId,
                                        Colors.orange,
                                        Icons.access_time,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Resumen y botón guardar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Resumen de asistencia
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Presentes',
                      _getAttendanceCount(AttendanceStatus.present),
                      Colors.green,
                    ),
                    _buildSummaryItem(
                      'Ausentes',
                      _getAttendanceCount(AttendanceStatus.absent),
                      Colors.red,
                    ),
                    _buildSummaryItem(
                      'Tardanzas',
                      _getAttendanceCount(AttendanceStatus.late),
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: ${_students.length} estudiantes - ${_getAttendancePercentage().toStringAsFixed(1)}% presentes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving || !_isValidClassDay() ? null : _saveAttendance,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar Asistencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(AttendanceStatus status, int studentId, Color color, IconData icon) {
    final isSelected = _getAttendanceStatus(studentId) == status;
    
    return GestureDetector(
      onTap: () => _setAttendanceStatus(studentId, status),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
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
    );
  }
}
