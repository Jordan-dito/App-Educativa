import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'students/students_screen.dart';
import 'students/student_enrollments_screen.dart';
import 'teachers/teachers_screen.dart';
import 'subjects/subjects_screen.dart';
import 'enrollments/enrollments_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

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
      title: 'Reportes',
      icon: Icons.analytics,
      color: Colors.teal,
      roles: ['admin', 'profesor'], // Admin y Profesor pueden ver reportes
    ),
    DashboardItem(
      title: 'Pendientes',
      icon: Icons.pending_actions,
      color: Colors.amber,
      roles: ['estudiante'], // Solo estudiantes ven pendientes
    ),
  ];

  // Obtener menús según el rol del usuario
  List<DashboardItem> get _menuItems {
    return _allMenuItems
        .where((item) => item.roles.contains(widget.user.rol.toLowerCase()))
        .toList();
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
      case 'Pendientes':
        // Mostrar contenido de pendientes para estudiantes
        setState(() {
          _selectedIndex = index + 1;
        });
        return;
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
                  Text(
                    '¡Bienvenido!',
                    style: const TextStyle(
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
                  title: 'Estudiantes',
                  value: '150',
                  icon: Icons.school,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Profesores',
                  value: '25',
                  icon: Icons.person,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Materias',
                  value: '12',
                  icon: Icons.book,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Clases Hoy',
                  value: '8',
                  icon: Icons.schedule,
                  color: Colors.blue,
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
    // Contenido específico para el módulo de Pendientes
    if (moduleName == 'Pendientes') {
      return _buildPendingContent();
    }

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

  Widget _buildPendingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  colors: [Colors.amber[600]!, Colors.amber[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.pending_actions,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tareas Pendientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estudiante: ${widget.user.nombre} ${widget.user.apellido}',
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

          // Lista de pendientes
          Text(
            'Actividades Pendientes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 16),

          // Tareas pendientes de ejemplo
          _buildPendingTask(
            title: 'Matemáticas - Tarea de Álgebra',
            subject: 'Matemáticas',
            dueDate: '15 de Diciembre',
            priority: 'Alta',
            color: Colors.red,
          ),
          _buildPendingTask(
            title: 'Historia - Ensayo sobre Independencia',
            subject: 'Historia',
            dueDate: '18 de Diciembre',
            priority: 'Media',
            color: Colors.orange,
          ),
          _buildPendingTask(
            title: 'Ciencias - Proyecto de Biología',
            subject: 'Ciencias Naturales',
            dueDate: '20 de Diciembre',
            priority: 'Alta',
            color: Colors.red,
          ),
          _buildPendingTask(
            title: 'Literatura - Lectura de Novela',
            subject: 'Lengua y Literatura',
            dueDate: '22 de Diciembre',
            priority: 'Baja',
            color: Colors.green,
          ),

          const SizedBox(height: 24),

          // Estadísticas rápidas
          Text(
            'Resumen Académico',
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
                  title: 'Tareas Completadas',
                  value: '12',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Pendientes',
                  value: '4',
                  icon: Icons.pending,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Promedio General',
                  value: '8.5',
                  icon: Icons.grade,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Asistencia',
                  value: '95%',
                  icon: Icons.schedule,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTask({
    required String title,
    required String subject,
    required String dueDate,
    required String priority,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Entrega: $dueDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Marcando como completada: $title')),
                );
              },
              icon: Icon(Icons.check_circle_outline, color: Colors.green[600]),
              tooltip: 'Marcar como completada',
            ),
          ],
        ),
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
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración en desarrollo')),
                );
              },
            ),
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
