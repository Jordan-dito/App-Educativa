import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/subject_model.dart';
import '../../services/subject_service.dart';
import '../../services/teacher_service.dart';
import '../../models/teacher_model.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({Key? key, this.subject}) : super(key: key);

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final SubjectService _subjectService = SubjectService();
  final TeacherService _teacherService = TeacherService();
  
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _creditsController;
  late TextEditingController _hoursController;
  
  String _selectedDepartment = 'Matemáticas';
  String _selectedLevel = 'Primaria';
  String _selectedGrade = '1°';
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  bool _isActive = true;
  bool _isLoading = false;
  
  List<Teacher> _availableTeachers = [];
  List<String> _availableGrades = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTeachers();
    _updateGradesForLevel(_selectedLevel);
  }

  void _initializeControllers() {
    final subject = widget.subject;
    
    _nameController = TextEditingController(text: subject?.name ?? '');
    _codeController = TextEditingController(text: subject?.code ?? '');
    _descriptionController = TextEditingController(text: subject?.description ?? '');
    _creditsController = TextEditingController(text: subject?.credits.toString() ?? '');
    _hoursController = TextEditingController(text: subject?.hoursPerWeek.toString() ?? '');
    
    if (subject != null) {
      _selectedDepartment = subject.department;
      _selectedLevel = subject.level;
      _selectedGrade = subject.grade;
      _selectedTeacherId = subject.teacherId;
      _selectedTeacherName = subject.teacherName;
      _isActive = subject.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      final teachers = await _teacherService.getActiveTeachers();
      setState(() {
        _availableTeachers = teachers;
      });
    } catch (e) {
      debugPrint('Error al cargar profesores: $e');
    }
  }

  void _updateGradesForLevel(String level) {
    setState(() {
      _availableGrades = Subject.getGradesForLevel(level);
      if (_availableGrades.isNotEmpty && !_availableGrades.contains(_selectedGrade)) {
        _selectedGrade = _availableGrades.first;
      }
    });
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código es requerido';
    }
    
    if (value.trim().length < 3) {
      return 'El código debe tener al menos 3 caracteres';
    }
    
    final codeRegex = RegExp(r'^[A-Z0-9]+$');
    if (!codeRegex.hasMatch(value.trim().toUpperCase())) {
      return 'El código solo puede contener letras mayúsculas y números';
    }
    
    return null;
  }

  String? _validateCredits(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los créditos son requeridos';
    }
    
    final credits = int.tryParse(value.trim());
    if (credits == null || credits <= 0 || credits > 10) {
      return 'Los créditos deben ser un número entre 1 y 10';
    }
    
    return null;
  }

  String? _validateHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Las horas por semana son requeridas';
    }
    
    final hours = int.tryParse(value.trim());
    if (hours == null || hours <= 0 || hours > 40) {
      return 'Las horas deben ser un número entre 1 y 40';
    }
    
    return null;
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
        code: _codeController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim(),
        department: _selectedDepartment,
        credits: int.parse(_creditsController.text.trim()),
        hoursPerWeek: int.parse(_hoursController.text.trim()),
        level: _selectedLevel,
        grade: _selectedGrade,
        teacherId: _selectedTeacherId,
        teacherName: _selectedTeacherName,
        isActive: _isActive,
        createdAt: widget.subject?.createdAt,
      );

      if (widget.subject == null) {
        // Crear nueva materia
        await _subjectService.insertSubject(subject);
        _showSuccessMessage('Materia creada exitosamente');
      } else {
        // Actualizar materia existente
        await _subjectService.updateSubject(subject);
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
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Básica',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Código de la Materia *',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: MAT101, ESP201',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: _validateCode,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Clasificación académica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clasificación Académica',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Departamento *',
                          border: OutlineInputBorder(),
                        ),
                        items: Subject.departments.map((department) {
                          return DropdownMenuItem(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLevel,
                              decoration: const InputDecoration(
                                labelText: 'Nivel *',
                                border: OutlineInputBorder(),
                              ),
                              items: Subject.levels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedLevel = value!);
                                _updateGradesForLevel(value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGrade,
                              decoration: const InputDecoration(
                                labelText: 'Grado *',
                                border: OutlineInputBorder(),
                              ),
                              items: _availableGrades.map((grade) {
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Carga académica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carga Académica',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _creditsController,
                              decoration: const InputDecoration(
                                labelText: 'Créditos *',
                                border: OutlineInputBorder(),
                                suffixText: 'créditos',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _validateCredits,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _hoursController,
                              decoration: const InputDecoration(
                                labelText: 'Horas/Semana *',
                                border: OutlineInputBorder(),
                                suffixText: 'horas',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _validateHours,
                            ),
                          ),
                        ],
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              child: Text('${teacher.fullName} - ${teacher.specialization}'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTeacherId = value;
                            if (value != null) {
                              final teacherId = int.tryParse(value);
                              final teacher = _availableTeachers.firstWhere((t) => t.id == teacherId);
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
                        subtitle: const Text('Determina si la materia está disponible para el período actual'),
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
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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