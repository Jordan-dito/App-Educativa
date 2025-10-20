import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import '../../services/teacher_service.dart';
import 'add_edit_teacher_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({Key? key}) : super(key: key);

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherService _teacherService = TeacherService();
  List<Teacher> _teachers = [];
  List<Teacher> _filteredTeachers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDepartment = 'Todos';
  String _selectedStatus = 'Todos';

  final List<String> _departments = [
    'Todos',
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

  final List<String> _statusOptions = [
    'Todos',
    'Activo',
    'Inactivo',
  ];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }

  // Método de prueba para verificar el estado
  void _debugPrintState() {
    print('🔍 DEBUG Estado actual:');
    print('   - Total profesores: ${_teachers.length}');
    print('   - Profesores filtrados: ${_filteredTeachers.length}');
    print('   - Cargando: $_isLoading');
    print('   - Búsqueda: "$_searchQuery"');
    print('   - Departamento: $_selectedDepartment');
    print('   - Estado: $_selectedStatus');
  }

  Future<void> _loadTeachers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      print(
          '👨‍🏫 DEBUG TeachersScreen._loadTeachers: Cargando profesores desde API...');

      final teachers = await _teacherService.getActiveTeachers();

      if (!mounted) return;
      setState(() {
        _teachers = teachers;
        _filteredTeachers = teachers;
        _isLoading = false;
      });

      print(
          '👨‍🏫 DEBUG TeachersScreen._loadTeachers: ${teachers.length} profesores cargados');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('❌ DEBUG TeachersScreen._loadTeachers: Error: $e');
      _showErrorSnackBar('Error al cargar profesores: $e');
    }
  }

  void _filterTeachers() {
    if (!mounted) return;
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        final matchesSearch = _searchQuery.isEmpty ||
            teacher.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            teacher.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            teacher.phone.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesDepartment = _selectedDepartment == 'Todos' ||
            teacher.department == _selectedDepartment;

        final matchesStatus = _selectedStatus == 'Todos' ||
            (_selectedStatus == 'Activo' && teacher.isActive) ||
            (_selectedStatus == 'Inactivo' && !teacher.isActive);

        return matchesSearch && matchesDepartment && matchesStatus;
      }).toList();
    });
  }

  Future<void> _navigateToEditTeacher(Teacher teacher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTeacherScreen(teacher: teacher),
      ),
    );

    if (result == true && mounted) {
      _loadTeachers();
    }
  }

  Future<void> _deleteTeacher(Teacher teacher) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar a ${teacher.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        print(
            '🗑️ DEBUG: Iniciando eliminación del profesor ${teacher.fullName} (ID: ${teacher.id})');

        // Mostrar indicador de carga
        if (mounted) {
          setState(() => _isLoading = true);
        }

        // Eliminar del servidor
        final success = await TeacherService.deleteTeacher(teacher.id!);
        print('🗑️ DEBUG: Resultado eliminación: $success');

        if (success && mounted) {
          // Crear nuevas listas sin el profesor eliminado
          final originalLength = _teachers.length;
          final filteredLength = _filteredTeachers.length;

          final updatedTeachers =
              _teachers.where((t) => t.id != teacher.id).toList();
          final updatedFilteredTeachers =
              _filteredTeachers.where((t) => t.id != teacher.id).toList();

          print(
              '🗑️ DEBUG: Lista original: $originalLength -> ${updatedTeachers.length}');
          print(
              '🗑️ DEBUG: Lista filtrada: $filteredLength -> ${updatedFilteredTeachers.length}');

          // Actualizar el estado con las nuevas listas
          setState(() {
            _teachers = updatedTeachers;
            _filteredTeachers = updatedFilteredTeachers;
            _isLoading = false;
          });

          // Verificar el estado después de la eliminación
          _debugPrintState();

          _showSuccessSnackBar('Profesor eliminado exitosamente');
        } else if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('No se pudo eliminar el profesor');
        }
      } catch (e) {
        print('❌ DEBUG: Error al eliminar profesor: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Error al eliminar profesor: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
      backgroundColor: Colors.orange[50],
      deleteIconColor: Colors.orange[700],
      labelStyle: TextStyle(color: Colors.orange[700]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedDepartment != 'Todos' ||
                    _selectedStatus != 'Todos'
                ? 'No se encontraron profesores'
                : 'No hay profesores registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedDepartment != 'Todos' ||
                    _selectedStatus != 'Todos'
                ? 'Intenta ajustar los filtros de búsqueda'
                : 'Agrega el primer profesor para comenzar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty &&
              _selectedDepartment == 'Todos' &&
              _selectedStatus == 'Todos') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditTeacherScreen(),
                  ),
                );
                if (result == true && mounted) {
                  _loadTeachers();
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar Profesor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: () {
            _showTeacherDetails(teacher);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange[400]!,
                        Colors.orange[600]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      teacher.firstName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del profesor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${teacher.yearsOfExperience} años exp.',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: teacher.isActive
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              teacher.isActive ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: teacher.isActive
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (teacher.phone.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.phone,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              teacher.phone,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              teacher.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botones de acción
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _navigateToEditTeacher(teacher),
                      icon: Icon(Icons.edit, color: Colors.orange[600]),
                      tooltip: 'Editar profesor',
                    ),
                    IconButton(
                      onPressed: () => _deleteTeacher(teacher),
                      icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                      tooltip: 'Eliminar profesor',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTeacherDetails(Teacher teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        teacher.firstName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          teacher.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Detalles
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Email', teacher.email),
                    _buildDetailRow('Teléfono', teacher.phone),
                    _buildDetailRow('Dirección', teacher.address),
                    _buildDetailRow(
                        'Estado', teacher.isActive ? 'Activo' : 'Inactivo'),
                    _buildDetailRow(
                        'Fecha de contratación', _formatDate(teacher.hireDate)),
                    _buildDetailRow('Años de experiencia',
                        '${teacher.yearsOfExperience} años'),
                    _buildDetailRow(
                        'Fecha de registro', _formatDate(teacher.hireDate)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _selectedDepartment = 'Todos';
                        _selectedStatus = 'Todos';
                        _searchQuery = '';
                      });
                      _filterTeachers();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),

            // Filtro por departamento
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Departamento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _departments.map((department) {
                      final isSelected = department == _selectedDepartment;
                      return FilterChip(
                        label: Text(department),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (!mounted) return;
                          setState(() {
                            _selectedDepartment = department;
                          });
                          _filterTeachers();
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.orange[100],
                        checkmarkColor: Colors.orange[700],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.orange[700]
                              : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filtro por estado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusOptions.map((status) {
                      final isSelected = status == _selectedStatus;
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (!mounted) return;
                          setState(() {
                            _selectedStatus = status;
                          });
                          _filterTeachers();
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: status == 'Activo'
                            ? Colors.green[100]
                            : status == 'Inactivo'
                                ? Colors.red[100]
                                : Colors.orange[100],
                        checkmarkColor: status == 'Activo'
                            ? Colors.green[700]
                            : status == 'Inactivo'
                                ? Colors.red[700]
                                : Colors.orange[700],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (status == 'Activo'
                                  ? Colors.green[700]
                                  : status == 'Inactivo'
                                      ? Colors.red[700]
                                      : Colors.orange[700])
                              : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profesores',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.black87,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                _showFilterBottomSheet(context);
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Colors.orange[700],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda mejorada
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              hintText: 'Buscar por nombre, email o teléfono...',
              leading: Icon(Icons.search, color: Colors.grey[600]),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _searchQuery = value;
                });
                _filterTeachers();
              },
            ),
          ),

          // Indicadores de filtros activos
          if (_searchQuery.isNotEmpty ||
              _selectedDepartment != 'Todos' ||
              _selectedStatus != 'Todos')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchQuery.isNotEmpty)
                    _buildFilterChip(
                      label: 'Búsqueda: "$_searchQuery"',
                      onDeleted: () {
                        if (!mounted) return;
                        setState(() {
                          _searchQuery = '';
                        });
                        _filterTeachers();
                      },
                    ),
                  if (_selectedDepartment != 'Todos')
                    _buildFilterChip(
                      label: 'Departamento: $_selectedDepartment',
                      onDeleted: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedDepartment = 'Todos';
                        });
                        _filterTeachers();
                      },
                    ),
                  if (_selectedStatus != 'Todos')
                    _buildFilterChip(
                      label: 'Estado: $_selectedStatus',
                      onDeleted: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedStatus = 'Todos';
                        });
                        _filterTeachers();
                      },
                    ),
                ],
              ),
            ),

          // Contador de resultados
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredTeachers.length} profesor${_filteredTeachers.length != 1 ? 'es' : ''} encontrado${_filteredTeachers.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_filteredTeachers.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _searchQuery = '';
                        _selectedDepartment = 'Todos';
                        _selectedStatus = 'Todos';
                      });
                      _filterTeachers();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ),

          // Lista de profesores mejorada
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando profesores...'),
                      ],
                    ),
                  )
                : _filteredTeachers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTeachers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            return _buildTeacherCard(teacher);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTeacherScreen(),
            ),
          );
          if (result == true && mounted) {
            _loadTeachers();
          }
        },
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Profesor'),
      ),
    );
  }
}
