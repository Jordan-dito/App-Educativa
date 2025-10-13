import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/teacher_model.dart';
import '../../services/teacher_service.dart';
import '../../services/auth_service.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddEditTeacherScreen({Key? key, this.teacher}) : super(key: key);

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;

  DateTime? _hireDate;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final teacher = widget.teacher;

    _firstNameController =
        TextEditingController(text: teacher?.firstName ?? '');
    _lastNameController = TextEditingController(text: teacher?.lastName ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _phoneController = TextEditingController(text: teacher?.phone ?? '');
    _addressController = TextEditingController(text: teacher?.address ?? '');
    _passwordController = TextEditingController();

    if (teacher != null) {
      _hireDate = teacher.hireDate;
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
    _passwordController.dispose();
    super.dispose();
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

    final phoneRegex = RegExp(r'^\d{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Ingrese un teléfono válido (8 dígitos)';
    }

    return null;
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) {
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
      if (widget.teacher == null) {
        // Crear nuevo profesor usando la API
        final teacherData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'rol': 'profesor',
          'nombre': _firstNameController.text.trim(),
          'apellido': _lastNameController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'direccion': _addressController.text.trim(),
          'fecha_contratacion': _hireDate!.toIso8601String().split('T')[0],
        };

        final response = await AuthService.registerTeacher(teacherData);

        if (response.success) {
          // Mostrar alerta de éxito
          await _showSuccessAlert();
          // Limpiar campos del formulario
          _clearFormFields();
        } else {
          _showErrorMessage('Error al crear profesor: ${response.message}');
        }
      } else {
        // Actualizar profesor existente (usar servicio local)
        final teacher = Teacher(
          id: widget.teacher?.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          birthDate: widget.teacher?.birthDate ??
              DateTime.now().subtract(const Duration(days: 365 * 30)),
          specialization: widget.teacher?.specialization ?? 'General',
          department: widget.teacher?.department ?? 'General',
          hireDate: _hireDate!,
          salary: widget.teacher?.salary ?? 0.0,
          isActive: _isActive,
        );

        await TeacherService.updateTeacher(teacher.id!, teacher.toMap());
        _showSuccessMessage('Profesor actualizado exitosamente');
        Navigator.pop(context, true);
      }
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
                'El profesor ha sido registrado exitosamente en el sistema.',
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
                Navigator.pop(context, true); // Volver a la lista de profesores
              },
              child: const Text(
                'Volver a Profesores',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mantener en el formulario para agregar otro profesor
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
      _hireDate = null;
      _isActive = true;
    });
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

                      // Solo mostrar campo de contraseña para nuevos profesores
                      if (widget.teacher == null) ...[
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (widget.teacher == null &&
                                (value == null || value.trim().isEmpty)) {
                              return 'La contraseña es requerida';
                            }
                            if (widget.teacher == null &&
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                              color: _hireDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Profesor Activo'),
                        subtitle: const Text(
                            'Determina si el profesor está actualmente trabajando'),
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
