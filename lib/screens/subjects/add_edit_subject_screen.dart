import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/subject_api_service.dart';
import '../../services/teacher_service.dart';
import '../../models/teacher_model.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final SubjectApiService _subjectApiService = SubjectApiService();
  final TeacherService _teacherService = TeacherService();

  late TextEditingController _nameController;

  String _selectedGrade = '1°';
  String _selectedSection = 'A';
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  String _academicYear = DateTime.now().year.toString();
  bool _isActive = true;
  bool _isLoading = false;

  List<Teacher> _availableTeachers = [];
  final List<String> _grades = [
    '1°',
    '2°',
    '3°',
    '4°',
    '5°',
    '6°',
    '7°',
    '8°',
    '9°',
    '10°',
    '11°'
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTeachers();
  }

  void _initializeControllers() {
    final subject = widget.subject;

    _nameController = TextEditingController(text: subject?.name ?? '');

    if (subject != null) {
      _selectedGrade = subject.grade;
      _selectedSection = subject.section;
      // No establecer _selectedTeacherId hasta que los profesores estén cargados
      _selectedTeacherName = subject.teacherName;
      _academicYear = subject.academicYear;
      _isActive = subject.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      debugPrint(
          '👨‍🏫 DEBUG AddEditSubjectScreen._loadTeachers: Cargando profesores...');
      final teachers = await _teacherService.getActiveTeachers();
      debugPrint(
          '👨‍🏫 DEBUG AddEditSubjectScreen._loadTeachers: ${teachers.length} profesores cargados');

      // Debug: imprimir los profesores cargados
      for (final teacher in teachers) {
        debugPrint(
            '👨‍🏫 DEBUG AddEditSubjectScreen._loadTeachers: Profesor - ID: ${teacher.id}, Nombre: ${teacher.fullName}');
      }

      setState(() {
        _availableTeachers = teachers;

        // Si estamos editando una materia, establecer el profesor seleccionado
        if (widget.subject != null && widget.subject!.teacherId != null) {
          _selectedTeacherId = widget.subject!.teacherId;
        }
      });
    } catch (e) {
      debugPrint('❌ ERROR AddEditSubjectScreen._loadTeachers: $e');
      _showErrorMessage('Error al cargar profesores: $e');
    }
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subject = Subject(
        id: widget.subject?.id,
        name: _nameController.text.trim(),
        grade: _selectedGrade,
        section: _selectedSection,
        teacherId: _selectedTeacherId,
        teacherName: _selectedTeacherName,
        academicYear: _academicYear,
        isActive: _isActive,
        createdAt: widget.subject?.createdAt,
      );

      if (widget.subject == null) {
        // Crear nueva materia
        debugPrint(
            '📚 DEBUG AddEditSubjectScreen._saveSubject: Creando nueva materia...');
        await _subjectApiService.createSubject(subject);
        _showSuccessMessage('Materia creada exitosamente');
      } else {
        // Actualizar materia existente
        debugPrint(
            '📚 DEBUG AddEditSubjectScreen._saveSubject: Actualizando materia ID: ${widget.subject!.id}');
        await _subjectApiService.updateSubject(subject);
        _showSuccessMessage('Materia actualizada exitosamente');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorMessage('Error al guardar materia: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Materia' : 'Nueva Materia'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información básica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Básica',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Materia *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGrade,
                              decoration: const InputDecoration(
                                labelText: 'Grado *',
                                border: OutlineInputBorder(),
                              ),
                              items: _grades.map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedGrade = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSection,
                              decoration: const InputDecoration(
                                labelText: 'Sección *',
                                border: OutlineInputBorder(),
                              ),
                              items: _sections.map((section) {
                                return DropdownMenuItem(
                                  value: section,
                                  child: Text(section),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedSection = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _academicYear,
                        decoration: const InputDecoration(
                          labelText: 'Año Académico *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _academicYear = value;
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El año académico es requerido';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un año válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Asignación de profesor
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asignación de Profesor',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTeacherId,
                        decoration: const InputDecoration(
                          labelText: 'Profesor Asignado',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Sin asignar'),
                          ),
                          ..._availableTeachers.map((teacher) {
                            return DropdownMenuItem<String>(
                              value: teacher.id?.toString(),
                              child: Text(teacher.fullName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTeacherId = value;
                            if (value != null) {
                              final teacherId = int.tryParse(value);
                              final teacher = _availableTeachers
                                  .firstWhere((t) => t.id == teacherId);
                              _selectedTeacherName = teacher.fullName;
                            } else {
                              _selectedTeacherName = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Materia Activa'),
                        subtitle: const Text(
                            'Determina si la materia está disponible para el período actual'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSubject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(isEditing ? 'Actualizar' : 'Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
