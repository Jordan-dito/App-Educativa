import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/teacher_model.dart';
import '../../services/teacher_service.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddEditTeacherScreen({Key? key, this.teacher}) : super(key: key);

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TeacherService _teacherService = TeacherService();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  
  DateTime? _birthDate;
  DateTime? _hireDate;
  String _selectedSpecialization = 'Matemáticas';
  String _selectedDepartment = 'Matemáticas';
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _specializations = [
    'Matemáticas',
    'Física',
    'Química',
    'Biología',
    'Lenguaje',
    'Literatura',
    'Historia',
    'Geografía',
    'Educación Física',
    'Artes Plásticas',
    'Música',
    'Inglés',
    'Francés',
    'Tecnología',
    'Informática',
    'Religión',
    'Filosofía',
    'Preescolar',
    'Psicología',
    'Orientación'
  ];

  final List<String> _departments = [
    'Matemáticas',
    'Ciencias',
    'Lenguaje',
    'Ciencias Sociales',
    'Educación Física',
    'Artes',
    'Inglés',
    'Tecnología',
    'Religión',
    'Preescolar'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final teacher = widget.teacher;
    
    _firstNameController = TextEditingController(text: teacher?.firstName ?? '');
    _lastNameController = TextEditingController(text: teacher?.lastName ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _phoneController = TextEditingController(text: teacher?.phone ?? '');
    _addressController = TextEditingController(text: teacher?.address ?? '');
    _salaryController = TextEditingController(text: teacher?.salary.toString() ?? '');
    _emergencyContactController = TextEditingController(text: teacher?.emergencyContact ?? '');
    _emergencyPhoneController = TextEditingController(text: teacher?.emergencyPhone ?? '');
    
    if (teacher != null) {
      _birthDate = teacher.birthDate;
      _hireDate = teacher.hireDate;
      _selectedSpecialization = teacher.specialization;
      _selectedDepartment = teacher.department;
      _isActive = teacher.isActive;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 70)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _selectHireDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 50)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _hireDate) {
      setState(() {
        _hireDate = picked;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Ingrese un teléfono válido (10 dígitos)';
    }
    
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return 'El salario es requerido';
    }
    
    final salary = double.tryParse(value);
    if (salary == null || salary <= 0) {
      return 'Ingrese un salario válido';
    }
    
    return null;
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione la fecha de nacimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione la fecha de contratación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teacher = Teacher(
        id: widget.teacher?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate: _birthDate!,
        specialization: _selectedSpecialization,
        department: _selectedDepartment,
        hireDate: _hireDate!,
        salary: double.parse(_salaryController.text.trim()),
        isActive: _isActive,
        emergencyContact: _emergencyContactController.text.trim().isEmpty 
            ? null 
            : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty 
            ? null 
            : _emergencyPhoneController.text.trim(),
      );

      if (widget.teacher == null) {
        // Crear nuevo profesor
        await _teacherService.insertTeacher(teacher);
        _showSuccessMessage('Profesor creado exitosamente');
      } else {
        // Actualizar profesor existente
        await TeacherService.updateTeacher(teacher.id!, teacher.toMap());
        _showSuccessMessage('Profesor actualizado exitosamente');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorMessage('Error al guardar profesor: $e');
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
    final isEditing = widget.teacher != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Profesor' : 'Nuevo Profesor'),
        backgroundColor: Colors.green,
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
              // Información personal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Personal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los nombres son requeridos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellidos *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los apellidos son requeridos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 16),
                      
                      InkWell(
                        onTap: _selectBirthDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Nacimiento *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _birthDate != null
                                ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              color: _birthDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Información profesional
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Profesional',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedSpecialization,
                        decoration: const InputDecoration(
                          labelText: 'Especialización *',
                          border: OutlineInputBorder(),
                        ),
                        items: _specializations.map((specialization) {
                          return DropdownMenuItem(
                            value: specialization,
                            child: Text(specialization),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSpecialization = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Departamento *',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.map((department) {
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
                      
                      InkWell(
                        onTap: _selectHireDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Contratación *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _hireDate != null
                                ? '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              color: _hireDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _salaryController,
                        decoration: const InputDecoration(
                          labelText: 'Salario *',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        validator: _validateSalary,
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Profesor Activo'),
                        subtitle: const Text('Determina si el profesor está actualmente trabajando'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contacto de emergencia
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contacto de Emergencia',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Contacto',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono de Emergencia',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
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
                      onPressed: _isLoading ? null : _saveTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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