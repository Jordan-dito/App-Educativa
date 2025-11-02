import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'students/students_screen.dart';
import 'students/student_enrollments_screen.dart';
import 'teachers/teachers_screen.dart';
import 'subjects/subjects_screen.dart';
import 'enrollments/enrollments_screen.dart';
import 'attendance/teacher_configuration_screen.dart';
import 'attendance/take_attendance_screen.dart';
import 'attendance/student_attendance_screen.dart';
import 'grades/teacher_grades_list_screen.dart';
import 'grades/student_grades_list_screen.dart';
import 'reforzamiento/teacher_reforzamiento_screen.dart';
import 'reforzamiento/student_reforzamiento_screen.dart';
import '../models/subject_model.dart';
import '../models/subject_configuration_model.dart';
import '../services/student_subject_service.dart';
import '../services/subject_api_service.dart';
import '../services/teacher_api_service.dart';
import '../services/attendance_api_service.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final SubjectApiService _subjectApiService = SubjectApiService();
  final StudentSubjectService _studentSubjectService = StudentSubjectService();
  final TeacherApiService _teacherApiService = TeacherApiService();
  int _subjectsCount = 0;
  bool _isLoadingSubjectsCount = true;

  // Menús completos disponibles
  final List<DashboardItem> _allMenuItems = [
    DashboardItem(
      title: 'Estudiantes',
      icon: Icons.school,
      color: Colors.green,
      roles: ['admin', 'profesor'], // Admin y Profesor pueden ver estudiantes
    ),
    DashboardItem(
      title: 'Profesores',
      icon: Icons.person,
      color: Colors.orange,
      roles: ['admin'], // Solo admin puede ver profesores
    ),
    DashboardItem(
      title: 'Materias',
      icon: Icons.book,
      color: Colors.purple,
      roles: ['admin', 'profesor'], // Admin y Profesor pueden ver materias
    ),
    DashboardItem(
      title: 'Inscripciones',
      icon: Icons.assignment_ind,
      color: Colors.indigo,
      roles: ['admin'], // Solo admin puede ver inscripciones
    ),
    DashboardItem(
      title: 'Mis Materias',
      icon: Icons.school,
      color: Colors.teal,
      roles: ['estudiante'], // Solo estudiantes pueden ver sus materias
    ),
    DashboardItem(
      title: 'Calificaciones',
      icon: Icons.grade,
      color: Colors.red,
      roles: [
        'admin',
        'profesor'
      ], // Admin y Profesor pueden ver calificaciones
    ),
    DashboardItem(
      title: 'Configurar Asistencia',
      icon: Icons.settings,
      color: Colors.blue,
      roles: ['profesor'], // Solo profesores pueden configurar asistencia
    ),
    DashboardItem(
      title: 'Tomar Asistencia',
      icon: Icons.checklist,
      color: Colors.green,
      roles: ['profesor'], // Solo profesores pueden tomar asistencia
    ),
    DashboardItem(
      title: 'Reforzamiento',
      icon: Icons.school,
      color: Colors.orange,
      roles: ['profesor'], // Solo profesores pueden acceder a reforzamiento
    ),
    DashboardItem(
      title: 'Mi Asistencia',
      icon: Icons.person_pin_circle,
      color: Colors.purple,
      roles: ['estudiante'], // Solo estudiantes pueden ver su asistencia
    ),
    DashboardItem(
      title: 'Mis Notas',
      icon: Icons.assessment,
      color: Colors.red,
      roles: ['estudiante'], // Solo estudiantes pueden ver sus notas
    ),
  ];

  // Obtener menús según el rol del usuario
  List<DashboardItem> get _menuItems {
    return _allMenuItems
        .where((item) => item.roles.contains(widget.user.rol.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSubjectsCount();
  }

  Future<void> _loadSubjectsCount() async {
    try {
      List<Subject> subjects;

      // Si es estudiante, obtener solo sus materias inscritas
      if (widget.user.rol.toLowerCase() == 'estudiante') {
        subjects =
            await _studentSubjectService.getStudentSubjects(widget.user.id!);
      } else if (widget.user.rol.toLowerCase() == 'profesor') {
        // Para profesores, obtener solo las materias que imparten
        try {
          // Obtener el profesor_id del usuario
          final allTeachers = await _teacherApiService.getAllTeachers();
          final userEmail = widget.user.email.toLowerCase();
          final teacher = allTeachers.firstWhere(
            (t) => t.email.toLowerCase() == userEmail,
            orElse: () =>
                throw Exception('No se encontró el profesor para este usuario'),
          );

          final profesorId = teacher.id;
          if (profesorId == null) {
            throw Exception('No se pudo obtener el ID del profesor');
          }

          // Obtener materias del profesor
          subjects = await _subjectApiService
              .getSubjectsByTeacher(profesorId.toString());
        } catch (e) {
          debugPrint(
              '❌ ERROR DashboardScreen._loadSubjectsCount (profesor): $e');
          // Si falla, mostrar 0 en lugar de error
          subjects = [];
        }
      } else {
        // Para admin, obtener todas las materias
        subjects = await _subjectApiService.getAllSubjects();
      }

      setState(() {
        _subjectsCount = subjects.length;
        _isLoadingSubjectsCount = false;
      });
    } catch (e) {
      debugPrint('❌ ERROR DashboardScreen._loadSubjectsCount: $e');
      setState(() {
        _isLoadingSubjectsCount = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Eliminar usuario de SharedPreferences
                await UserService.removeUser();

                print(
                    '🔐 DEBUG DashboardScreen: Usuario deslogueado, eliminando sesión');

                // Navegar al login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToModule(String moduleName, int index) {
    Widget? screen;

    switch (moduleName) {
      case 'Estudiantes':
        screen = const StudentsScreen();
        break;
      case 'Profesores':
        screen = const TeachersScreen();
        break;
      case 'Materias':
        screen = const SubjectsScreen();
        break;
      case 'Inscripciones':
        screen = const EnrollmentsScreen();
        break;
      case 'Mis Materias':
        screen = const StudentEnrollmentsScreen();
        break;
      case 'Configurar Asistencia':
        _navigateToSubjectSelection('Configurar Asistencia');
        return;
      case 'Tomar Asistencia':
        _navigateToSubjectSelection('Tomar Asistencia');
        return;
      case 'Reforzamiento':
        if (widget.user.rol == 'profesor') {
          screen = const TeacherReforzamientoScreen();
        } else if (widget.user.rol == 'estudiante') {
          screen = const StudentReforzamientoScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes acceso a este módulo')),
          );
          return;
        }
        break;
      case 'Mi Asistencia':
        _navigateToStudentSubjectSelection();
        return;
      case 'Mis Notas':
        if (widget.user.rol == 'estudiante') {
          screen = const StudentGradesListScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes acceso a este módulo')),
          );
          return;
        }
        break;
      case 'Calificaciones':
        // Navegar a pantalla de calificaciones según el rol
        final userRole = widget.user.rol;
        if (userRole == 'profesor' || userRole == 'admin') {
          screen = const TeacherGradesListScreen();
        } else if (userRole == 'estudiante') {
          screen = const StudentGradesListScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes acceso a este módulo')),
          );
          return;
        }
        break;
      default:
        // Para módulos que aún no están implementados
        setState(() {
          _selectedIndex = index + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo de $moduleName en desarrollo'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen!),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuario: ${widget.user.email}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rol: ${widget.user.rol}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas rápidas
          Text(
            'Resumen del Sistema',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Materias',
                  value: _isLoadingSubjectsCount ? '...' : '$_subjectsCount',
                  icon: Icons.book,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Accesos rápidos
          Text(
            'Accesos Rápidos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuCard(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(DashboardItem item, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _navigateToModule(item.title, index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.1),
                item.color.withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 40,
                color: item.color,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleContent(String moduleName) {
    // Contenido genérico para otros módulos
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Módulo de $moduleName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'En desarrollo...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Dashboard'
            : _menuItems[_selectedIndex - 1].title),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay notificaciones nuevas')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.school,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistema Colegio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            const Divider(),
            ...List.generate(_menuItems.length, (index) {
              final item = _menuItems[index];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: _selectedIndex == index + 1,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToModule(item.title, index);
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _buildModuleContent(_menuItems[_selectedIndex - 1].title),
    );
  }

  // Función para navegar a selección de materia (profesores)
  void _navigateToSubjectSelection(String action) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener el usuario_id del profesor logueado
      final userId = widget.user.id!;

      // Obtener el profesor_id desde el usuario_id
      // Buscamos el profesor que tiene el mismo email que el usuario logueado
      final TeacherApiService teacherService = TeacherApiService();
      final allTeachers = await teacherService.getAllTeachers();

      // Buscar el profesor que tiene el mismo email que el usuario actual
      final userEmail = widget.user.email.toLowerCase();
      final teacher = allTeachers.firstWhere(
        (t) => t.email.toLowerCase() == userEmail,
        orElse: () => throw Exception(
            'No se encontró el profesor para este usuario (email: $userEmail)'),
      );

      final profesorId = teacher.id;
      debugPrint(
          '📚 DEBUG DashboardScreen: Profesor encontrado - ID: $profesorId, Email: ${teacher.email} para usuario_id: $userId');

      // Cargar las materias del profesor usando el profesor_id
      final SubjectApiService subjectService = SubjectApiService();

      // SIEMPRE filtrar por profesor_id para asegurar que solo se muestren sus materias
      List<Subject> teacherSubjects = [];

      try {
        // Primero intentar con el método específico
        teacherSubjects =
            await subjectService.getSubjectsByTeacher(profesorId.toString());
        debugPrint(
            '📚 DEBUG DashboardScreen: ${teacherSubjects.length} materias encontradas para profesor_id: $profesorId');

        // Verificar que realmente están filtradas correctamente
        teacherSubjects = teacherSubjects.where((subject) {
          if (subject.teacherId != null) {
            final subjectTeacherId = int.tryParse(subject.teacherId!);
            return subjectTeacherId == profesorId;
          }
          return false;
        }).toList();
        debugPrint(
            '📚 DEBUG DashboardScreen: ${teacherSubjects.length} materias después de verificación de filtro');
      } catch (e) {
        debugPrint(
            '⚠️ ERROR DashboardScreen: Error obteniendo materias por profesor: $e');
      }

      // Si aún no hay materias o falló el método, usar filtrado manual como respaldo
      if (teacherSubjects.isEmpty) {
        debugPrint(
            '📚 DEBUG DashboardScreen: Usando método de respaldo - obteniendo todas y filtrando manualmente');
        final allSubjects = await subjectService.getAllSubjects();

        // Filtrar estrictamente por profesor_id
        teacherSubjects = allSubjects.where((subject) {
          if (subject.teacherId != null) {
            final subjectTeacherId = int.tryParse(subject.teacherId!);
            final matches = subjectTeacherId == profesorId && subject.isActive;
            if (matches) {
              debugPrint(
                  '✅ DEBUG DashboardScreen: Materia incluida - ${subject.name} (profesor_id: ${subject.teacherId})');
            }
            return matches;
          }
          return false;
        }).toList();

        debugPrint(
            '📚 DEBUG DashboardScreen: ${teacherSubjects.length} materias encontradas después de filtrado manual estricto');
      }

      // Cerrar loading
      Navigator.pop(context);

      if (teacherSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes materias asignadas')),
        );
        return;
      }

      final selectedSubject = await showDialog<Subject>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController searchController =
                TextEditingController();
            List<Subject> filteredSubjects = teacherSubjects;

            void _filterSubjects(String query) {
              setState(() {
                if (query.isEmpty) {
                  filteredSubjects = teacherSubjects;
                } else {
                  filteredSubjects = teacherSubjects.where((subject) {
                    return subject.name
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        subject.grade
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        subject.section
                            .toLowerCase()
                            .contains(query.toLowerCase());
                  }).toList();
                }
              });
            }

            return AlertDialog(
              title: Text('Seleccionar Materia - $action'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de búsqueda
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar materia...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  _filterSubjects('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: _filterSubjects,
                    ),
                    const SizedBox(height: 16),
                    // Lista de materias con altura fija
                    SizedBox(
                      height: 300,
                      child: filteredSubjects.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No se encontraron materias',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredSubjects.length,
                              itemBuilder: (context, index) {
                                final subject = filteredSubjects[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.book,
                                        color: Colors.indigo),
                                    title: Text(
                                      subject.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                        '${subject.grade} ${subject.section}'),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                    onTap: () =>
                                        Navigator.pop(context, subject),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      if (selectedSubject != null) {
        if (action == 'Configurar Asistencia') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TeacherConfigurationScreen(subject: selectedSubject),
            ),
          );
        } else if (action == 'Tomar Asistencia') {
          // Obtener el profesor_id correcto del usuario logueado
          final TeacherApiService teacherService = TeacherApiService();
          final allTeachers = await teacherService.getAllTeachers();

          // Buscar el profesor que tiene el mismo email que el usuario actual
          final userEmail = widget.user.email.toLowerCase();
          final teacher = allTeachers.firstWhere(
            (t) => t.email.toLowerCase() == userEmail,
            orElse: () =>
                throw Exception('No se encontró el profesor para este usuario'),
          );

          final profesorId = teacher.id ?? 0;
          if (profesorId == 0) {
            throw Exception('No se pudo obtener el ID del profesor');
          }

          // Intentar obtener la configuración de la materia, si no existe crear una temporal
          final AttendanceApiService attendanceService = AttendanceApiService();
          SubjectConfiguration? config;

          try {
            config = await attendanceService.getSubjectConfiguration(
              int.parse(selectedSubject.id!),
              DateTime.now().year,
              fallbackTeacherId:
                  profesorId, // Inyectar profesor_id si no viene en la respuesta
            );
          } catch (e) {
            debugPrint('⚠️ No se encontró configuración, usando temporal: $e');
          }

          // Si la configuración se cargó pero teacherId es 0, asignarlo manualmente
          if (config != null && config.teacherId == 0) {
            config = SubjectConfiguration(
              id: config.id,
              subjectId: config.subjectId,
              teacherId: profesorId,
              academicYear: config.academicYear,
              startDate: config.startDate,
              endDate: config.endDate,
              classDays: config.classDays,
              classTime: config.classTime,
              attendanceGoal: config.attendanceGoal,
              createdAt: config.createdAt,
              updatedAt: config.updatedAt,
            );
          }

          // Si no hay configuración, crear una temporal
          final finalConfig = config ??
              SubjectConfiguration(
                id: null,
                subjectId: int.parse(selectedSubject.id!),
                teacherId: profesorId,
                academicYear: DateTime.now().year.toString(),
                startDate: DateTime.now(),
                endDate: DateTime.now().add(const Duration(days: 120)),
                classDays: [
                  'lunes',
                  'martes',
                  'miercoles',
                  'jueves',
                  'viernes'
                ],
                classTime: '08:00',
                attendanceGoal: 80,
              );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TakeAttendanceScreen(configuration: finalConfig),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Función para navegar a selección de materia (estudiantes)
  void _navigateToStudentSubjectSelection() async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Cargar las materias del estudiante desde la API
      final StudentSubjectService studentSubjectService =
          StudentSubjectService();
      // Usar getStudentSubjects que filtra correctamente por usuario_id
      final List<Subject> studentSubjects =
          await studentSubjectService.getStudentSubjects(widget.user.id!);

      // Cerrar loading
      Navigator.pop(context);

      if (studentSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No estás inscrito en ninguna materia')),
        );
        return;
      }

      final selectedSubject = await showDialog<Subject>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController searchController =
                TextEditingController();
            List<Subject> filteredSubjects = studentSubjects;

            void filterSubjects(String query) {
              setState(() {
                if (query.isEmpty) {
                  filteredSubjects = studentSubjects;
                } else {
                  filteredSubjects = studentSubjects.where((subject) {
                    return subject.name
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        subject.grade
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        subject.section
                            .toLowerCase()
                            .contains(query.toLowerCase());
                  }).toList();
                }
              });
            }

            return AlertDialog(
              title: const Text('Seleccionar Materia'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de búsqueda
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar materia...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  filterSubjects('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: filterSubjects,
                    ),
                    const SizedBox(height: 16),
                    // Lista de materias con altura fija
                    SizedBox(
                      height: 300,
                      child: filteredSubjects.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No se encontraron materias',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredSubjects.length,
                              itemBuilder: (context, index) {
                                final subject = filteredSubjects[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.book,
                                        color: Colors.indigo),
                                    title: Text(
                                      subject.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                        '${subject.grade} ${subject.section}'),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                    onTap: () =>
                                        Navigator.pop(context, subject),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      if (selectedSubject != null) {
        // Intentar obtener la configuración de la materia
        final AttendanceApiService attendanceService = AttendanceApiService();
        SubjectConfiguration? config;

        try {
          // Intentar obtener configuración real (puede que no tenga profesor_id)
          config = await attendanceService.getSubjectConfiguration(
            int.parse(selectedSubject.id!),
            DateTime.now().year,
            fallbackTeacherId: selectedSubject.teacherId != null
                ? int.tryParse(selectedSubject.teacherId!) ?? 0
                : 0,
          );
        } catch (e) {
          debugPrint(
              '⚠️ No se encontró configuración para estudiante, usando temporal: $e');
        }

        // Si no hay configuración, crear una temporal
        final finalConfig = config ??
            SubjectConfiguration(
              id: null,
              subjectId: int.parse(selectedSubject.id!),
              teacherId: selectedSubject.teacherId != null
                  ? int.tryParse(selectedSubject.teacherId!) ?? 0
                  : 0,
              academicYear: DateTime.now().year.toString(),
              startDate: DateTime.now().subtract(const Duration(days: 60)),
              endDate: DateTime.now().add(const Duration(days: 120)),
              classDays: ['lunes', 'martes', 'miercoles', 'jueves', 'viernes'],
              classTime: '08:00',
              attendanceGoal: 80,
            );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentAttendanceScreen(configuration: finalConfig),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> roles;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.roles,
  });
}
