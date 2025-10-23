import 'package:flutter/material.dart';
import '../../models/enrollment_model.dart';
import '../../services/enrollment_api_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class StudentEnrollmentsScreen extends StatefulWidget {
  const StudentEnrollmentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentEnrollmentsScreen> createState() =>
      _StudentEnrollmentsScreenState();
}

class _StudentEnrollmentsScreenState extends State<StudentEnrollmentsScreen> {
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();

  List<Enrollment> _enrollments = [];
  bool _isLoading = true;
  User? _currentUser;
  String _searchQuery = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndEnrollments();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadUserAndEnrollments() async {
    if (_isDisposed || !mounted) return;
    setState(() => _isLoading = true);

    try {
      // Obtener el usuario actual
      final user = await UserService.getCurrentUser();

      if (_isDisposed || !mounted) return;
      if (user == null) {
        _showErrorMessage('No se pudo obtener la información del usuario');
        return;
      }

      // Verificar que el usuario sea un estudiante
      if (user.rol != 'estudiante') {
        _showErrorMessage(
            'Solo los estudiantes pueden acceder a esta información');
        return;
      }

      if (_isDisposed || !mounted) return;
      setState(() {
        _currentUser = user;
      });

      // Obtener las inscripciones del estudiante
      await _loadEnrollments();
    } catch (e) {
      if (!_isDisposed && mounted) {
        _showErrorMessage('Error al cargar datos: $e');
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadEnrollments() async {
    if (_currentUser == null || _isDisposed || !mounted) return;

    try {
      // Debug: Imprimir información del usuario actual
      print('🎓 DEBUG StudentEnrollmentsScreen: Usuario actual:');
      print('  - ID: ${_currentUser!.id}');
      print('  - Nombre: ${_currentUser!.nombre}');
      print('  - Apellido: ${_currentUser!.apellido}');
      print('  - Email: ${_currentUser!.email}');
      print('  - Rol: ${_currentUser!.rol}');
      print('  - Grado: ${_currentUser!.grado}');
      print('  - Sección: ${_currentUser!.seccion}');

      // Obtener el ID del usuario actual (que se usará para buscar el estudiante_id)
      final userId = _currentUser!.id ?? 0;

      print('🎓 DEBUG StudentEnrollmentsScreen: ID del usuario: $userId');

      if (userId == 0) {
        _showErrorMessage(
            'ID de usuario no válido. ID recibido: ${_currentUser!.id}');
        return;
      }

      print(
          '🎓 DEBUG StudentEnrollmentsScreen: Cargando inscripciones para usuario ID: $userId');

      // Primero, obtener todas las inscripciones para debug
      print(
          '🎓 DEBUG StudentEnrollmentsScreen: Obteniendo todas las inscripciones para debug...');
      final allEnrollments = await _enrollmentService.getAllEnrollments();
      print(
          '🎓 DEBUG StudentEnrollmentsScreen: Total de inscripciones en el sistema: ${allEnrollments.length}');

      // Mostrar IDs de estudiantes que tienen inscripciones
      final studentIds =
          allEnrollments.map((e) => e.estudianteId).toSet().toList();
      print(
          '🎓 DEBUG StudentEnrollmentsScreen: IDs de estudiantes con inscripciones: $studentIds');

      // Verificar si nuestro usuario tiene un estudiante asociado con inscripciones
      // Primero obtenemos el estudiante_id del usuario
      final studentId = await _enrollmentService.getStudentIdByUserId(userId);
      if (studentId != null && studentIds.contains(studentId)) {
        print(
            '🎓 DEBUG StudentEnrollmentsScreen: ✅ El usuario $userId (estudiante_id: $studentId) SÍ tiene inscripciones en el sistema');
      } else {
        print(
            '🎓 DEBUG StudentEnrollmentsScreen: ❌ El usuario $userId NO tiene inscripciones en el sistema');
        if (studentId == null) {
          print(
              '🎓 DEBUG StudentEnrollmentsScreen: - No se encontró estudiante_id para este usuario');
        } else {
          print(
              '🎓 DEBUG StudentEnrollmentsScreen: - Estudiante_id encontrado: $studentId, pero no tiene inscripciones');
        }
        print('🎓 DEBUG StudentEnrollmentsScreen: Posibles causas:');
        print('  - El usuario no está registrado como estudiante');
        print('  - Las inscripciones están en estado inactivo');
        print('  - Error en la consulta de la API');
      }

      final enrollments =
          await _enrollmentService.getEnrollmentsByUserId(userId);

      print(
          '🎓 DEBUG StudentEnrollmentsScreen: Inscripciones obtenidas para usuario $userId: ${enrollments.length}');

      if (_isDisposed || !mounted) return;
      setState(() {
        _enrollments = enrollments;
      });

      if (_isDisposed || !mounted) return;
      if (enrollments.isEmpty) {
        _showInfoMessage('No estás inscrito en ninguna materia');
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        _showErrorMessage('Error al cargar inscripciones: $e');
      }
    }
  }

  List<Enrollment> get _filteredEnrollments {
    if (_searchQuery.isEmpty) return _enrollments;

    return _enrollments.where((enrollment) {
      return enrollment.materiaNombre
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (enrollment.profesorNombre
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
    }).toList();
  }

  void _showErrorMessage(String message) {
    if (!_isDisposed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInfoMessage(String message) {
    if (!_isDisposed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materias'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!_isDisposed && mounted) {
                _loadEnrollments();
              }
            },
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
                    _currentUser!.nombre.isNotEmpty
                        ? _currentUser!.nombre
                        : 'Estudiante',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Estudiante',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
                hintText: 'Buscar por materia o profesor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (!_isDisposed && mounted) {
                  setState(() {
                    _searchQuery = value;
                  });
                }
              },
            ),
          ),

          // Lista de materias inscritas
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
                              _searchQuery.isEmpty
                                  ? 'No estás inscrito en ninguna materia'
                                  : 'No se encontraron materias',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Contacta a tu coordinador para inscribirte'
                                  : 'Intenta con otros términos de búsqueda',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Información de debug para el usuario
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Información técnica:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tu ID de estudiante es: ${_currentUser?.id ?? 'No disponible'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  Text(
                                    'El sistema no encontró inscripciones para este ID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Si acabas de inscribirte, presiona el botón de actualizar (🔄) o usa el botón de debug (🐛) para verificar el estado',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
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
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.book,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrollment.materiaNombre.isNotEmpty
                            ? enrollment.materiaNombre
                            : 'Materia no disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (enrollment.profesorNombre?.isNotEmpty == true)
                        Text(
                          'Profesor: ${enrollment.profesorNombre}',
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
                    Icons.calendar_today,
                    color: Colors.indigo[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de inscripción: ${enrollment.fechaInscripcion.isNotEmpty ? enrollment.fechaInscripcion : 'No disponible'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (enrollment.estudianteGrado.isNotEmpty &&
                            enrollment.estudianteSeccion.isNotEmpty)
                          Text(
                            'Grado: ${enrollment.estudianteGrado} ${enrollment.estudianteSeccion}',
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
          ],
        ),
      ),
    );
  }
}
