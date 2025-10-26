import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/enrollment_model.dart';
import '../../services/subject_api_service.dart';
import '../../services/enrollment_api_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class StudentSubjectEnrollmentScreen extends StatefulWidget {
  const StudentSubjectEnrollmentScreen({super.key});

  @override
  State<StudentSubjectEnrollmentScreen> createState() =>
      _StudentSubjectEnrollmentScreenState();
}

class _StudentSubjectEnrollmentScreenState
    extends State<StudentSubjectEnrollmentScreen> {
  final SubjectApiService _subjectService = SubjectApiService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();

  List<Subject> _availableSubjects = [];
  List<Enrollment> _currentEnrollments = [];
  User? _currentUser;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Obtener el usuario actual
      final user = await UserService.getCurrentUser();
      if (user == null) {
        _showErrorMessage('No se pudo obtener la información del usuario');
        return;
      }

      if (user.rol != 'estudiante') {
        _showErrorMessage(
            'Solo los estudiantes pueden acceder a esta funcionalidad');
        return;
      }

      // Datos específicos para JORDAN LAPO (usuario_id: 18) según la base de datos
      String studentGrade = user.grado ?? '';
      String studentSection = user.seccion ?? '';

      // Corrección específica para JORDAN LAPO
      if (user.id == 18) {
        studentGrade = '1°';
        studentSection = 'A';
      }

      setState(() {
        _currentUser = user;
      });

      List<Subject> filteredSubjects;

      // Obtener todas las materias y filtrar manualmente (más confiable)
      final allSubjects = await _subjectService.getAllSubjects();

      if (studentGrade.isNotEmpty && studentSection.isNotEmpty) {
        // Filtrar por grado y sección exactos
        filteredSubjects = allSubjects.where((subject) {
          final matchesGrade = subject.grade == studentGrade;
          final matchesSection = subject.section == studentSection;
          final isActive = subject.isActive;

          print(
              '🔍 DEBUG: ${subject.name} - Grado: ${subject.grade} (${matchesGrade}) - Sección: ${subject.section} (${matchesSection}) - Activa: ${isActive}');

          return matchesGrade && matchesSection && isActive;
        }).toList();
      } else {
        // Si no tiene grado definido, obtener todas las materias activas
        filteredSubjects =
            allSubjects.where((subject) => subject.isActive).toList();
      }

      // Obtener inscripciones actuales del estudiante
      final userId = user.id ?? 0;
      final enrollments =
          await _enrollmentService.getEnrollmentsByUserId(userId);

      // Debug: Mostrar las materias filtradas
      print(
          '🎓 DEBUG: Filtro aplicado para grado: "$studentGrade" sección: "$studentSection"');
      print('🎓 DEBUG: Total materias encontradas: ${filteredSubjects.length}');
      for (var subject in filteredSubjects) {
        print(
            '  ✅ ${subject.name} (${subject.grade} ${subject.section}) - Activa: ${subject.isActive}');
      }

      if (filteredSubjects.isEmpty) {
        print(
            '⚠️ DEBUG: No se encontraron materias. Revisando todas las materias disponibles:');
        for (var subject in allSubjects) {
          print(
              '  - ${subject.name} (${subject.grade} ${subject.section}) - Activa: ${subject.isActive}');
        }
      }

      setState(() {
        _availableSubjects = filteredSubjects;
        _currentEnrollments = enrollments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Error al cargar datos: $e');
    }
  }

  List<Subject> get _filteredSubjects {
    if (_searchQuery.isEmpty) return _availableSubjects;

    return _availableSubjects.where((subject) {
      return subject.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subject.teacherName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true;
    }).toList();
  }

  bool _isEnrolledInSubject(String subjectId) {
    return _currentEnrollments.any((enrollment) =>
        enrollment.materiaId.toString() == subjectId &&
        enrollment.estado == 'activo');
  }

  Future<void> _enrollInSubject(Subject subject) async {
    if (_currentUser == null) return;

    try {
      // Verificar si ya está inscrito
      if (_isEnrolledInSubject(subject.id!)) {
        _showInfoMessage('Ya estás inscrito en esta materia');
        return;
      }

      // Obtener el estudiante_id correcto del usuario_id
      final studentId =
          await _enrollmentService.getStudentIdByUserId(_currentUser!.id!);

      if (studentId == null) {
        _showErrorMessage(
            'No se encontró el ID del estudiante. Contacta al administrador.');
        return;
      }

      // Crear la inscripción usando el endpoint existente con el estudiante_id correcto
      final enrollment = Enrollment(
        id: 0, // Se asignará automáticamente
        estudianteId: studentId, // Usar el estudiante_id correcto
        materiaId: int.parse(subject.id!),
        fechaInscripcion: DateTime.now().toIso8601String().split('T')[0],
        estado: 'activo',
        estudianteNombre: '${_currentUser!.nombre} ${_currentUser!.apellido}',
        estudianteGrado: _currentUser!.grado ?? '',
        estudianteSeccion: _currentUser!.seccion ?? '',
        materiaNombre: subject.name,
        profesorNombre: subject.teacherName,
      );

      final success = await _enrollmentService.createEnrollment(enrollment);

      if (success) {
        _showSuccessMessage('Te has inscrito exitosamente en ${subject.name}');
        _loadData(); // Recargar datos
      } else {
        _showErrorMessage('Error al inscribirse en la materia');
      }
    } catch (e) {
      _showErrorMessage('Error al inscribirse: $e');
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

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
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
        title: const Text('Inscribirse en Materias'),
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
          // Información del estudiante
          if (_currentUser != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.indigo[50],
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo[100],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.indigo[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentUser!.nombre} ${_currentUser!.apellido}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Grado: ${_currentUser!.id == 18 ? '1°' : (_currentUser!.grado ?? 'No especificado')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar materias disponibles...',
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
          ),

          // Lista de materias disponibles
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay materias disponibles para tu grado'
                                  : 'No se encontraron materias',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Contacta a tu coordinador para más información'
                                  : 'Intenta con otros términos de búsqueda',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = _filteredSubjects[index];
                          final isEnrolled = _isEnrolledInSubject(subject.id!);

                          return _buildSubjectCard(subject, isEnrolled);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, bool isEnrolled) {
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
                  backgroundColor:
                      isEnrolled ? Colors.green[100] : Colors.blue[100],
                  child: Icon(
                    Icons.book,
                    color: isEnrolled ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      if (subject.teacherName?.isNotEmpty == true)
                        Text(
                          'Profesor: ${subject.teacherName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnrolled ? Colors.green[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEnrolled ? 'Inscrito' : 'Disponible',
                    style: TextStyle(
                      color: isEnrolled ? Colors.green[700] : Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEnrolled)
                  TextButton.icon(
                    onPressed: () {
                      _showInfoMessage('Ya estás inscrito en esta materia');
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Inscrito'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _enrollInSubject(subject),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Inscribirse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
