import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../models/subject_model.dart';
import '../../models/enrollment_model.dart';
import '../../services/student_api_service.dart';
import '../../services/subject_api_service.dart';
import '../../services/enrollment_api_service.dart';

class AddEnrollmentScreen extends StatefulWidget {
  const AddEnrollmentScreen({Key? key}) : super(key: key);

  @override
  State<AddEnrollmentScreen> createState() => _AddEnrollmentScreenState();
}

class _AddEnrollmentScreenState extends State<AddEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final StudentApiService _studentService = StudentApiService();
  final SubjectApiService _subjectService = SubjectApiService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();

  List<Student> _students = [];
  List<Subject> _subjects = [];
  Student? _selectedStudent;
  Subject? _selectedSubject;
  bool _isLoading = false;
  bool _isDataLoading = true;

  // Filtros para estudiantes
  String? _selectedGrade;
  String? _selectedSection;
  String _searchQuery = '';
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _studentService.getAllStudents(),
        _subjectService.getAllSubjects(),
      ]);

      setState(() {
        _students = results[0] as List<Student>;
        _subjects = results[1] as List<Subject>;
        _filteredStudents = _students;
        _isDataLoading = false;
      });
    } catch (e) {
      setState(() => _isDataLoading = false);
      _showErrorMessage('Error al cargar datos: $e');
    }
  }

  // Obtener grados únicos
  List<String> get _uniqueGrades {
    return _students.map((s) => s.grade).toSet().toList()..sort();
  }

  // Obtener secciones únicas para un grado específico
  List<String> get _uniqueSections {
    if (_selectedGrade == null) return [];
    return _students
        .where((s) => s.grade == _selectedGrade)
        .map((s) => s.section)
        .toSet()
        .toList()
      ..sort();
  }

  // Filtrar estudiantes
  void _filterStudents() {
    setState(() {
      _filteredStudents = _students.where((student) {
        // Filtro por búsqueda de texto
        bool matchesSearch = _searchQuery.isEmpty ||
            student.fullName.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtro por grado
        bool matchesGrade =
            _selectedGrade == null || student.grade == _selectedGrade;

        // Filtro por sección
        bool matchesSection =
            _selectedSection == null || student.section == _selectedSection;

        return matchesSearch && matchesGrade && matchesSection;
      }).toList();

      // Si el estudiante seleccionado ya no está en la lista filtrada, resetear la selección
      if (_selectedStudent != null &&
          !_filteredStudents
              .any((student) => student.id == _selectedStudent!.id)) {
        _selectedStudent = null;
      }
    });
  }

  // Limpiar filtros
  void _clearFilters() {
    setState(() {
      _selectedGrade = null;
      _selectedSection = null;
      _searchQuery = '';
      _filteredStudents = _students;
      _selectedStudent = null; // También resetear la selección de estudiante
    });
  }

  Future<void> _saveEnrollment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudent == null) {
      _showErrorMessage('Seleccione un estudiante');
      return;
    }

    if (_selectedSubject == null) {
      _showErrorMessage('Seleccione una materia');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Crear el objeto de inscripción
      final enrollment = Enrollment(
        id: 0, // Se asignará automáticamente en el servidor
        estudianteId: _selectedStudent!.id,
        estudianteNombre: _selectedStudent!.fullName,
        estudianteGrado: _selectedStudent!.grade,
        estudianteSeccion: _selectedStudent!.section,
        materiaId: int.tryParse(_selectedSubject!.id ?? '0') ?? 0,
        materiaNombre: _selectedSubject!.name,
        fechaInscripcion:
            DateTime.now().toIso8601String().split('T')[0], // Fecha actual
        estado: 'activo',
        profesorId: int.tryParse(_selectedSubject!.teacherId ?? '0'),
        profesorNombre: _selectedSubject!.teacherName,
      );

      // Guardar la inscripción usando la API
      final success = await _enrollmentService.createEnrollment(enrollment);

      if (success) {
        _showSuccessMessage('Inscripción creada exitosamente');
        Navigator.pop(context, true);
      } else {
        _showErrorMessage('Error al crear la inscripción');
      }
    } catch (e) {
      // Manejar diferentes tipos de errores
      String errorMessage = e.toString();

      if (errorMessage
          .contains('El estudiante ya está inscrito en esta materia')) {
        _showWarningMessage('El estudiante ya está inscrito en esta materia');
      } else if (errorMessage.contains('Error del servidor')) {
        _showErrorMessage('Error del servidor. Contacte al administrador.');
      } else {
        _showErrorMessage('Error al crear inscripción: $e');
      }
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Inscripción'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información del estudiante
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Seleccionar Estudiante',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_selectedGrade != null ||
                                    _selectedSection != null ||
                                    _searchQuery.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Limpiar filtros'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.indigo,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Campo de búsqueda
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Buscar estudiante',
                                hintText: 'Escriba el nombre del estudiante',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() => _searchQuery = '');
                                          _filterStudents();
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                                _filterStudents();
                              },
                            ),

                            const SizedBox(height: 16),

                            // Filtros de grado y sección
                            Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedGrade,
                                  decoration: InputDecoration(
                                    labelText: 'Grado',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    prefixIcon: const Icon(Icons.school),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Todos los grados'),
                                    ),
                                    ..._uniqueGrades.map((grade) {
                                      return DropdownMenuItem<String>(
                                        value: grade,
                                        child: Text('Grado $grade'),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGrade = value;
                                      _selectedSection =
                                          null; // Reset section when grade changes
                                    });
                                    _filterStudents();
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedSection,
                                  decoration: InputDecoration(
                                    labelText: 'Sección',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    prefixIcon: const Icon(Icons.group),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Todas las secciones'),
                                    ),
                                    ..._uniqueSections.map((section) {
                                      return DropdownMenuItem<String>(
                                        value: section,
                                        child: Text('Sección $section'),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedSection = value);
                                    _filterStudents();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Dropdown de estudiantes filtrados
                            DropdownButtonFormField<Student>(
                              value: _selectedStudent,
                              decoration: InputDecoration(
                                labelText: 'Estudiante *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: const Icon(Icons.person),
                              ),
                              items: _filteredStudents.map((student) {
                                return DropdownMenuItem<Student>(
                                  value: student,
                                  child: Text(
                                    '${student.fullName} - ${student.grade} ${student.section}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedStudent = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Seleccione un estudiante';
                                }
                                return null;
                              },
                            ),

                            // Mostrar cantidad de estudiantes filtrados
                            if (_filteredStudents.length != _students.length)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Mostrando ${_filteredStudents.length} de ${_students.length} estudiantes',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Información de la materia
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seleccionar Materia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Subject>(
                              value: _selectedSubject,
                              decoration: InputDecoration(
                                labelText: 'Materia *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: const Icon(Icons.book),
                              ),
                              items: _subjects.map((subject) {
                                return DropdownMenuItem<Subject>(
                                  value: subject,
                                  child: Text(
                                    '${subject.name} - ${subject.grade} ${subject.section}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedSubject = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Seleccione una materia';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resumen de la inscripción
                    if (_selectedStudent != null && _selectedSubject != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen de la Inscripción',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.indigo[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: Colors.indigo[600]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Estudiante: ${_selectedStudent!.fullName}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                'Grado: ${_selectedStudent!.grade} ${_selectedStudent!.section}',
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
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.book,
                                            color: Colors.indigo[600]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Materia: ${_selectedSubject!.name}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                'Grado: ${_selectedSubject!.grade} ${_selectedSubject!.section}',
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
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEnrollment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Guardar Inscripción'),
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
