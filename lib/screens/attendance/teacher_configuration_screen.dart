import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/subject_configuration_model.dart';
import '../../services/attendance_api_service.dart';
import '../../services/user_service.dart';

class TeacherConfigurationScreen extends StatefulWidget {
  final Subject subject;

  const TeacherConfigurationScreen({
    super.key,
    required this.subject,
  });

  @override
  State<TeacherConfigurationScreen> createState() => _TeacherConfigurationScreenState();
}

class _TeacherConfigurationScreenState extends State<TeacherConfigurationScreen> {
  final AttendanceApiService _attendanceService = AttendanceApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _academicYearController;
  late TextEditingController _classTimeController;
  late TextEditingController _attendanceGoalController;

  // Estado del formulario
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 120));
  final List<String> _selectedDays = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // Días de la semana disponibles
  final List<Map<String, dynamic>> _weekDays = [
    {'key': 'lunes', 'label': 'Lunes'},
    {'key': 'martes', 'label': 'Martes'},
    {'key': 'miercoles', 'label': 'Miércoles'},
    {'key': 'jueves', 'label': 'Jueves'},
    {'key': 'viernes', 'label': 'Viernes'},
  ];

  @override
  void initState() {
    super.initState();
    _academicYearController = TextEditingController(text: DateTime.now().year.toString());
    _classTimeController = TextEditingController();
    _attendanceGoalController = TextEditingController(text: '80');
    _loadExistingConfiguration();
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    _classTimeController.dispose();
    _attendanceGoalController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingConfiguration() async {
    setState(() => _isLoading = true);

    try {
      // Aquí podrías cargar una configuración existente si la hay
      // Por ahora empezamos con valores por defecto
    } catch (e) {
      _showErrorMessage('Error al cargar configuración: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _toggleDay(String dayKey) {
    setState(() {
      if (_selectedDays.contains(dayKey)) {
        _selectedDays.remove(dayKey);
      } else {
        _selectedDays.add(dayKey);
      }
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      _showErrorMessage('Selecciona al menos un día de clase');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = await UserService.getCurrentUser();
      if (user == null) {
        _showErrorMessage('No se pudo obtener la información del usuario');
        return;
      }

      final config = SubjectConfiguration(
        subjectId: int.parse(widget.subject.id!),
        teacherId: user.id!,
        academicYear: _academicYearController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        classDays: _selectedDays,
        classTime: _classTimeController.text.trim().isEmpty ? null : _classTimeController.text.trim(),
        attendanceGoal: int.parse(_attendanceGoalController.text.trim()),
      );

      final success = await _attendanceService.createSubjectConfiguration(config);

      if (success) {
        _showSuccessMessage('Configuración guardada exitosamente');
        Navigator.pop(context, true);
      } else {
        _showErrorMessage('Error al guardar la configuración');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Materia'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                                Icon(
                                  Icons.book,
                                  color: Colors.indigo[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
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
                                      Text(
                                        'Curso: ${widget.subject.grade} ${widget.subject.section}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Año académico
                    TextFormField(
                      controller: _academicYearController,
                      decoration: InputDecoration(
                        labelText: 'Año Académico',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el año académico';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Ingresa un año válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Fechas de inicio y fin
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Inicio',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Fin',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Días de clase
                    Text(
                      'Días de Clase',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _weekDays.map((day) {
                        final isSelected = _selectedDays.contains(day['key']);
                        return FilterChip(
                          label: Text(day['label']),
                          selected: isSelected,
                          onSelected: (_) => _toggleDay(day['key']),
                          selectedColor: Colors.indigo[100],
                          checkmarkColor: Colors.indigo[700],
                          backgroundColor: Colors.grey[100],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Hora de clase (opcional)
                    TextFormField(
                      controller: _classTimeController,
                      decoration: InputDecoration(
                        labelText: 'Hora de Clase (opcional)',
                        hintText: 'Ej: 08:00',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 16),

                    // Meta de asistencia
                    TextFormField(
                      controller: _attendanceGoalController,
                      decoration: InputDecoration(
                        labelText: 'Meta de Asistencia (%)',
                        hintText: 'Ej: 80',
                        prefixIcon: const Icon(Icons.track_changes),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la meta de asistencia';
                        }
                        final goal = int.tryParse(value.trim());
                        if (goal == null || goal < 0 || goal > 100) {
                          return 'Ingresa un porcentaje válido (0-100)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveConfiguration,
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
                        label: Text(_isSaving ? 'Guardando...' : 'Guardar Configuración'),
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
            ),
    );
  }
}
