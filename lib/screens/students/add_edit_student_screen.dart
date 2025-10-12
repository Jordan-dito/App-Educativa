import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({Key? key, this.student}) : super(key: key);

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;

  DateTime? _birthDate;
  String _selectedGrade = '1°';
  String _selectedSection = 'A';
  bool _isActive = true;
  bool _isLoading = false;
  bool _canCreateStudents = false;

  final List<String> _grades = [
    'Preescolar',
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
    _checkUserPermissions();
  }

  void _initializeControllers() {
    final student = widget.student;

    _firstNameController =
        TextEditingController(text: student?.firstName ?? '');
    _lastNameController = TextEditingController(text: student?.lastName ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _addressController = TextEditingController(text: student?.address ?? '');
    _passwordController = TextEditingController();

    if (student != null) {
      _birthDate = student.dateOfBirth;
      _selectedGrade = student.grade;
      _selectedSection = student.section;
      _isActive = student.isActive;
    }
  }

  Future<void> _checkUserPermissions() async {
    final canCreate = await UserService.canCreateStudents();
    setState(() {
      _canCreateStudents = canCreate;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
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

  Future<void> _saveStudent() async {
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

    // Validar permisos para crear estudiantes
    if (widget.student == null && !_canCreateStudents) {
      _showErrorMessage(
          'No tiene permisos para crear estudiantes. Solo administradores y profesores pueden realizar esta acción.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.student == null) {
        // Crear nuevo estudiante usando la API
        final studentData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'rol': 'estudiante',
          'nombre': _firstNameController.text.trim(),
          'apellido': _lastNameController.text.trim(),
          'grado': _selectedGrade,
          'seccion': _selectedSection,
          'telefono': _phoneController.text.trim(),
          'direccion': _addressController.text.trim(),
          'fecha_nacimiento': _birthDate!.toIso8601String().split('T')[0],
        };

        final response = await AuthService.registerStudent(studentData);

        if (response.success) {
          // Mostrar alerta de confirmación
          await _showSuccessAlert();
          // Limpiar campos del formulario
          _clearFormFields();
        } else {
          _showErrorMessage('Error al crear estudiante: ${response.message}');
        }
      } else {
        // Actualizar estudiante existente (usar servicio local)
        final student = Student(
          id: widget.student?.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          dateOfBirth: _birthDate!,
          grade: _selectedGrade,
          section: _selectedSection,
          guardianName: widget.student?.guardianName ?? '',
          guardianPhone: widget.student?.guardianPhone ?? '',
          isActive: _isActive,
        );

        await _studentService.updateStudent(student);
        _showSuccessMessage('Estudiante actualizado exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorMessage('Error al guardar estudiante: $e');
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

  // Mostrar alerta de éxito con opciones
  Future<void> _showSuccessAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                '¡Éxito!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El estudiante ha sido registrado exitosamente en el sistema.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los datos se han guardado en la base de datos y el formulario se ha limpiado.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(
                    context, true); // Volver a la lista de estudiantes
              },
              child: const Text(
                'Volver a Estudiantes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mantener en el formulario para agregar otro estudiante
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Agregar Otro'),
            ),
          ],
        );
      },
    );
  }

  // Limpiar todos los campos del formulario
  void _clearFormFields() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _passwordController.clear();
      _birthDate = null;
      _selectedGrade = '1°';
      _selectedSection = 'A';
      _isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    // Si no es edición y el usuario no puede crear estudiantes, mostrar mensaje de error
    if (!isEditing && !_canCreateStudents) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Estudiante'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Acceso Denegado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tiene permisos para crear estudiantes.\nSolo administradores y profesores pueden realizar esta acción.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
                const SizedBox(height: 16),
                // Botón de debug temporal
                ElevatedButton(
                  onPressed: () async {
                    final debugInfo = await UserService.debugUserInfo();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Info'),
                        content: SingleChildScrollView(
                          child: Text(debugInfo.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Debug Info'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Estudiante' : 'Nuevo Estudiante'),
        backgroundColor: Colors.blue,
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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

                      // Solo mostrar campo de contraseña para nuevos estudiantes
                      if (widget.student == null) ...[
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (widget.student == null &&
                                (value == null || value.trim().isEmpty)) {
                              return 'La contraseña es requerida';
                            }
                            if (widget.student == null &&
                                value != null &&
                                value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

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
                        onTap: _selectDate,
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
                              color: _birthDate != null
                                  ? Colors.black
                                  : Colors.grey,
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

              // Información académica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Académica',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
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
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Estudiante Activo'),
                        subtitle: const Text(
                            'Determina si el estudiante está actualmente matriculado'),
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
                      onPressed: _isLoading ? null : _saveStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
