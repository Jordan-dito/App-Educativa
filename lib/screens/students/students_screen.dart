import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../services/student_api_service.dart';
import 'add_edit_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentApiService _studentService = StudentApiService();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';
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
    '11°',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      print(
          '🎓 DEBUG StudentsScreen._loadStudents: Cargando estudiantes desde API...');

      final students = await _studentService.getAllStudents();

      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });

      print(
          '🎓 DEBUG StudentsScreen._loadStudents: ${students.length} estudiantes cargados');
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ DEBUG StudentsScreen._loadStudents: Error: $e');
      _showErrorSnackBar('Error al cargar estudiantes: $e');
    }
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = _students.where((student) {
        final matchesSearch = _searchQuery.isEmpty ||
            student.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (student.phone
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);

        final matchesGrade =
            _selectedGrade == 'Todos' || student.grade == _selectedGrade;

        return matchesSearch && matchesGrade;
      }).toList();
    });
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar a este estudiante?'),
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

    if (confirmed == true) {
      try {
        await _studentService.deleteStudent(studentId);
        _showSuccessSnackBar('Estudiante eliminado exitosamente');
        _loadStudents();
      } catch (e) {
        _showErrorSnackBar('Error al eliminar estudiante: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
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
      backgroundColor: Colors.blue[50],
      deleteIconColor: Colors.blue[700],
      labelStyle: TextStyle(color: Colors.blue[700]),
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
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty || _selectedGrade != 'Todos'
                ? 'No se encontraron estudiantes'
                : 'No hay estudiantes registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedGrade != 'Todos'
                ? 'Intenta ajustar los filtros de búsqueda'
                : 'Agrega el primer estudiante para comenzar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty && _selectedGrade == 'Todos') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditStudentScreen(),
                  ),
                );
                if (result == true) {
                  _loadStudents();
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar Estudiante'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
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

  Widget _buildStudentCard(Student student) {
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
            _showStudentDetails(student);
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
                        Colors.blue[400]!,
                        Colors.blue[600]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      student.firstName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del estudiante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
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
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${student.grade} - ${student.section}',
                              style: TextStyle(
                                color: Colors.green[700],
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
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${student.age} años',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (student.phone?.isNotEmpty == true)
                        Row(
                          children: [
                            Icon(Icons.phone,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              student.phone!,
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
                              student.email,
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
                      onPressed: () async {
                        // TODO: Implementar edición de estudiantes cuando esté disponible
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Edición de estudiantes en desarrollo'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, color: Colors.blue[600]),
                      tooltip: 'Editar estudiante',
                    ),
                    IconButton(
                      onPressed: () => _deleteStudent(student.id),
                      icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                      tooltip: 'Eliminar estudiante',
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

  void _showStudentDetails(Student student) {
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
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        student.firstName.substring(0, 1).toUpperCase(),
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
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.email,
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
                    _buildDetailRow('Grado',
                        '${student.grade} - Sección ${student.section}'),
                    _buildDetailRow('Edad', '${student.age} años'),
                    if (student.phone?.isNotEmpty == true)
                      _buildDetailRow('Teléfono', student.phone!),
                    if (student.address?.isNotEmpty == true)
                      _buildDetailRow('Dirección', student.address!),
                    _buildDetailRow(
                        'Estado',
                        student.estudianteEstado == 'activo'
                            ? 'Activo'
                            : 'Inactivo'),
                    _buildDetailRow('Fecha de registro',
                        _formatDate(student.fechaCreacion)),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
                      setState(() {
                        _selectedGrade = 'Todos';
                        _searchQuery = '';
                      });
                      _filterStudents();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),

            // Filtro por grado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por grado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _grades.map((grade) {
                      final isSelected = grade == _selectedGrade;
                      return FilterChip(
                        label: Text(grade),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGrade = grade;
                          });
                          _filterStudents();
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[700],
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.blue[700] : Colors.grey[700],
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
          'Estudiantes',
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Colors.blue[700],
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
                setState(() {
                  _searchQuery = value;
                });
                _filterStudents();
              },
            ),
          ),

          // Indicadores de filtros activos
          if (_searchQuery.isNotEmpty || _selectedGrade != 'Todos')
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
                        setState(() {
                          _searchQuery = '';
                        });
                        _filterStudents();
                      },
                    ),
                  if (_selectedGrade != 'Todos')
                    _buildFilterChip(
                      label: 'Grado: $_selectedGrade',
                      onDeleted: () {
                        setState(() {
                          _selectedGrade = 'Todos';
                        });
                        _filterStudents();
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
                  '${_filteredStudents.length} estudiante${_filteredStudents.length != 1 ? 's' : ''} encontrado${_filteredStudents.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_filteredStudents.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedGrade = 'Todos';
                      });
                      _filterStudents();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ),

          // Lista de estudiantes mejorada
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando estudiantes...'),
                      ],
                    ),
                  )
                : _filteredStudents.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return _buildStudentCard(student);
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
              builder: (context) => const AddEditStudentScreen(),
            ),
          );
          if (result == true) {
            _loadStudents();
          }
        },
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Estudiante'),
      ),
    );
  }
}
