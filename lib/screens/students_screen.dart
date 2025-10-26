import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();
  String _selectedGrade = 'Todos';
  final List<String> _grades = [
    'Todos',
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
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  void _searchStudents(String query) {
    // Implementar búsqueda cuando sea necesario
    print('Buscando: $query');
  }

  void _filterByGrade(String grade) {
    setState(() {
      _selectedGrade = grade;
    });
    print('Filtrando por grado: $grade');
  }

  void _showStudentDialog({Map<String, dynamic>? student}) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(student: student),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar estudiantes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchStudents('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _searchStudents,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _grades.map((grade) {
                      final isSelected = _selectedGrade == grade;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(grade),
                          selected: isSelected,
                          onSelected: (_) => _filterByGrade(grade),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.green[100],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de estudiantes
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudents,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Lista vacía por ahora
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay estudiantes registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar un estudiante',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }


}

// Diálogo para crear/editar estudiante
class StudentFormDialog extends StatefulWidget {
  final Map<String, dynamic>? student;

  const StudentFormDialog({super.key, this.student});

  @override
  _StudentFormDialogState createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String _selectedGrade = '1°';
  String _selectedSection = 'A';
  
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
    _nameController = TextEditingController(text: widget.student?['nombre'] ?? '');
    _lastNameController = TextEditingController(text: widget.student?['apellido'] ?? '');
    _emailController = TextEditingController(text: widget.student?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.student?['telefono'] ?? '');
    _addressController = TextEditingController(text: widget.student?['direccion'] ?? '');
    
    if (widget.student != null) {
      // Validar que el grado del estudiante existe en la lista de grados disponibles
      final studentGrade = widget.student!['grado'] ?? '1°';
      _selectedGrade = _grades.contains(studentGrade) ? studentGrade : '1°';
      
      // Validar que la sección del estudiante existe en la lista de secciones disponibles
      final studentSection = widget.student!['seccion'] ?? 'A';
      _selectedSection = _sections.contains(studentSection) ? studentSection : 'A';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.student == null 
                ? 'Estudiante creado exitosamente'
                : 'Estudiante actualizado exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Nuevo Estudiante' : 'Editar Estudiante'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el apellido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el email';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
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
                      decoration: const InputDecoration(labelText: 'Grado'),
                      items: _grades.map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: const InputDecoration(labelText: 'Sección'),
                      items: _sections.map((section) {
                        return DropdownMenuItem(
                          value: section,
                          child: Text(section),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSection = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección (opcional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveStudent,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}