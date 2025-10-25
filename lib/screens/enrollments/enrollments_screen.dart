import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/enrollment_model.dart';
import '../../services/subject_api_service.dart';
import '../../services/enrollment_api_service.dart';
import 'add_enrollment_screen.dart';
import 'edit_enrollment_screen.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({super.key});

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  final SubjectApiService _subjectService = SubjectApiService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();

  List<Subject> _subjects = [];
  List<Enrollment> _enrollments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGrade = 'Todos';
  String _selectedSubject = 'Todos';
  String _selectedStatus = 'Activos';

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
    '11°',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Cargar materias e inscripciones en paralelo
      final results = await Future.wait([
        _subjectService.getAllSubjects(),
        _enrollmentService.getAllEnrollments(),
      ]);

      setState(() {
        _subjects = results[0] as List<Subject>;
        _enrollments = results[1] as List<Enrollment>;
        _isLoading = false;
      });

      // Mostrar mensaje informativo si no hay inscripciones
      if (_enrollments.isEmpty) {
        _showInfoMessage(
            'No hay inscripciones registradas. Agrega una nueva inscripción para comenzar.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Error al cargar datos: $e');
    }
  }

  List<Enrollment> get _filteredEnrollments {
    // Debug: Mostrar información sobre las inscripciones
    debugPrint('🔍 DEBUG _filteredEnrollments:');
    debugPrint('  - Total inscripciones: ${_enrollments.length}');
    debugPrint('  - Filtro seleccionado: $_selectedStatus');
    
    for (var enrollment in _enrollments) {
      debugPrint('  - Inscripción ${enrollment.id}: ${enrollment.estudianteNombre} - Estado: "${enrollment.estado}"');
    }

    final filtered = _enrollments.where((enrollment) {
      final matchesSearch = _searchQuery.isEmpty ||
          enrollment.estudianteNombre
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          enrollment.materiaNombre
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesGrade = _selectedGrade == 'Todos' ||
          enrollment.estudianteGrado == _selectedGrade;

      final matchesSubject = _selectedSubject == 'Todos' ||
          enrollment.materiaNombre == _selectedSubject;

      // Filtrar por estado
      final matchesStatus = _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Activos' && enrollment.estado == 'activo') ||
          (_selectedStatus == 'Inactivos' && enrollment.estado == 'inactivo');

      final result = matchesSearch && matchesGrade && matchesSubject && matchesStatus;
      
      if (result) {
        debugPrint('  ✅ Incluida: ${enrollment.estudianteNombre} (${enrollment.estado})');
      }

      return result;
    }).toList();

    debugPrint('  - Resultado filtrado: ${filtered.length} inscripciones');
    return filtered;
  }

  // Contar inscripciones activas
  int _getActiveCount() {
    return _enrollments.where((enrollment) => enrollment.estado == 'activo').length;
  }

  // Contar inscripciones inactivas
  int _getInactiveCount() {
    return _enrollments.where((enrollment) => enrollment.estado == 'inactivo').length;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deleteEnrollment(int enrollmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Está seguro que desea eliminar esta inscripción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _enrollmentService.deleteEnrollment(enrollmentId);
        if (success) {
          setState(() {
            _enrollments.removeWhere((e) => e.id == enrollmentId);
          });
          _showSuccessMessage('Inscripción eliminada exitosamente');
        } else {
          _showErrorMessage('Error al eliminar la inscripción');
        }
      } catch (e) {
        _showErrorMessage('Error al eliminar la inscripción: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscripciones'),
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
      body: Column(
        children: [
          // Filtros y búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por estudiante o materia...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por grado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por materia',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'Todos',
                            child: Text('Todos'),
                          ),
                          ..._subjects.map((subject) {
                            return DropdownMenuItem(
                              value: subject.name,
                              child: Text(subject.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSubject = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filtro por estado
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.filter_list),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Activos',
                            child: Text('Solo Activos (${_getActiveCount()})'),
                          ),
                          DropdownMenuItem(
                            value: 'Inactivos',
                            child: Text('Solo Inactivos (${_getInactiveCount()})'),
                          ),
                          DropdownMenuItem(
                            value: 'Todos',
                            child: Text('Todos los Estados (${_enrollments.length})'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón para limpiar filtros
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedGrade = 'Todos';
                          _selectedSubject = 'Todos';
                          _selectedStatus = 'Activos';
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Limpiar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de inscripciones
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEnrollments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay inscripciones registradas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega una nueva inscripción para comenzar',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredEnrollments.length,
                        itemBuilder: (context, index) {
                          final enrollment = _filteredEnrollments[index];
                          return _buildEnrollmentCard(enrollment);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEnrollmentScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Icon(
                    Icons.school,
                    color: Colors.indigo[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrollment.estudianteNombre.isNotEmpty
                            ? enrollment.estudianteNombre
                            : 'Estudiante no disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        enrollment.estudianteGrado.isNotEmpty &&
                                enrollment.estudianteSeccion.isNotEmpty
                            ? '${enrollment.estudianteGrado} ${enrollment.estudianteSeccion}'
                            : 'Grado/Sección no disponible',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enrollment.estado == 'activo'
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enrollment.estado == 'activo' ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: enrollment.estado == 'activo'
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.book,
                    color: Colors.indigo[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Materia: ${enrollment.materiaNombre.isNotEmpty ? enrollment.materiaNombre : 'No disponible'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (enrollment.profesorNombre != null &&
                            enrollment.profesorNombre!.isNotEmpty)
                          Text(
                            'Profesor: ${enrollment.profesorNombre}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          'Fecha de inscripción: ${enrollment.fechaInscripcion.isNotEmpty ? enrollment.fechaInscripcion : 'No disponible'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mostrar advertencia si faltan datos importantes
            if (enrollment.estudianteNombre.isEmpty ||
                enrollment.materiaNombre.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta inscripción tiene datos incompletos',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEnrollmentScreen(
                          enrollment: enrollment,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadData(); // Recargar datos después de editar
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteEnrollment(enrollment.id),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Eliminar',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
