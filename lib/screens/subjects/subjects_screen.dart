import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/subject_api_service.dart';
import 'add_edit_subject_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectApiService _subjectApiService = SubjectApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = true;
  String _selectedSection = 'Todos';
  String _selectedGrade = 'Todos';

  final List<String> _sections = ['Todos', 'A', 'B', 'C', 'D'];
  final List<String> _grades = [
    'Todos',
    '1°',
    '2°',
    '3°'
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);

    try {
      debugPrint(
          '📚 DEBUG SubjectsScreen._loadSubjects: Cargando materias desde API...');

      final subjects = await _subjectApiService.getAllSubjects();

      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });

      debugPrint(
          '📚 DEBUG SubjectsScreen._loadSubjects: ${subjects.length} materias cargadas');
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ ERROR SubjectsScreen._loadSubjects: $e');
      _showErrorMessage('Error al cargar materias: $e');
    }
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSubjects = _subjects.where((subject) {
        final matchesSearch = query.isEmpty ||
            subject.name.toLowerCase().contains(query) ||
            subject.grade.toLowerCase().contains(query) ||
            subject.section.toLowerCase().contains(query) ||
            subject.academicYear.toLowerCase().contains(query);

        final matchesSection =
            _selectedSection == 'Todos' || subject.section == _selectedSection;

        final matchesGrade =
            _selectedGrade == 'Todos' || subject.grade == _selectedGrade;

        return matchesSearch && matchesSection && matchesGrade;
      }).toList();
    });
  }

  Future<void> _navigateToAddSubject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditSubjectScreen(),
      ),
    );

    if (result == true) {
      _loadSubjects();
    }
  }

  Future<void> _navigateToEditSubject(Subject subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSubjectScreen(subject: subject),
      ),
    );

    if (result == true) {
      _loadSubjects();
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Está seguro de que desea eliminar la materia "${subject.name}"?'),
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
        await _subjectApiService.deleteSubject(subject.id!);
        _showSuccessMessage('Materia eliminada exitosamente');
        _loadSubjects();
      } catch (e) {
        _showErrorMessage('Error al eliminar materia: $e');
      }
    }
  }

  void _showSubjectDetails(Subject subject) {
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
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple[400]!,
                          Colors.purple[600]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        subject.name.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                          subject.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subject.gradeSection} - ${subject.academicYear}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildDetailSection('Información Académica', [
                      _buildDetailItem('Grado', subject.grade),
                      _buildDetailItem('Sección', subject.section),
                      _buildDetailItem('Año Académico', subject.academicYear),
                      _buildDetailItem(
                          'Estado', subject.isActive ? 'Activa' : 'Inactiva'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Profesor Asignado', [
                      _buildDetailItem(
                          'Nombre', subject.teacherName ?? 'Sin asignar'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Información del Sistema', [
                      _buildDetailItem(
                          'Creada', _formatDate(subject.createdAt)),
                    ]),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToEditSubject(subject);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Materias',
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
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Colors.purple[700],
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
              hintText: 'Buscar por nombre, grado o sección...',
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
                  _searchController.text = value;
                });
                _filterSubjects();
              },
            ),
          ),

          // Indicadores de filtros activos
          if (_searchController.text.isNotEmpty ||
              _selectedGrade != 'Todos' ||
              _selectedSection != 'Todos')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (_searchController.text.isNotEmpty)
                    Chip(
                      label: Text('Búsqueda: ${_searchController.text}'),
                      onDeleted: () {
                        setState(() {
                          _searchController.clear();
                        });
                        _filterSubjects();
                      },
                      backgroundColor: Colors.blue[50],
                      labelStyle: TextStyle(color: Colors.blue[700]),
                      deleteIconColor: Colors.blue[700],
                    ),
                  if (_selectedGrade != 'Todos')
                    Chip(
                      label: Text('Grado: $_selectedGrade'),
                      onDeleted: () {
                        setState(() {
                          _selectedGrade = 'Todos';
                        });
                        _filterSubjects();
                      },
                      backgroundColor: Colors.green[50],
                      labelStyle: TextStyle(color: Colors.green[700]),
                      deleteIconColor: Colors.green[700],
                    ),
                  if (_selectedSection != 'Todos')
                    Chip(
                      label: Text('Sección: $_selectedSection'),
                      onDeleted: () {
                        setState(() {
                          _selectedSection = 'Todos';
                        });
                        _filterSubjects();
                      },
                      backgroundColor: Colors.orange[50],
                      labelStyle: TextStyle(color: Colors.orange[700]),
                      deleteIconColor: Colors.orange[700],
                    ),
                ],
              ),
            ),

          // Lista de materias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubjects.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadSubjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return _buildSubjectCard(subject);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSubject,
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Materia'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isNotEmpty ||
                      _selectedGrade != 'Todos' ||
                      _selectedSection != 'Todos'
                  ? 'No se encontraron materias'
                  : 'No hay materias registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _subjects.isEmpty
                  ? 'Toca el botón + para agregar la primera materia'
                  : 'Intenta con otros filtros de búsqueda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isEmpty &&
                _selectedGrade == 'Todos' &&
                _selectedSection == 'Todos') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToAddSubject,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Materia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
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
            _showSubjectDetails(subject);
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
                      colors: subject.isActive
                          ? [Colors.purple[400]!, Colors.purple[600]!]
                          : [Colors.grey[400]!, Colors.grey[600]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      subject.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información de la materia
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
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
                              subject.gradeSection,
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
                              subject.academicYear,
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
                      if (subject.teacherName != null)
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subject.teacherName!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            subject.isActive
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: subject.isActive
                                ? Colors.green[600]
                                : Colors.red[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subject.isActive ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                              color: subject.isActive
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
                      onPressed: () => _navigateToEditSubject(subject),
                      icon: Icon(Icons.edit, color: Colors.purple[600]),
                      tooltip: 'Editar materia',
                    ),
                    IconButton(
                      onPressed: () => _deleteSubject(subject),
                      icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                      tooltip: 'Eliminar materia',
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                        _selectedSection = 'Todos';
                        _searchController.clear();
                      });
                      _filterSubjects();
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
                          _filterSubjects();
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.purple[100],
                        checkmarkColor: Colors.purple[700],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.purple[700]
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

            // Filtro por sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por sección',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sections.map((section) {
                      final isSelected = section == _selectedSection;
                      return FilterChip(
                        label: Text(section),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSection = section;
                          });
                          _filterSubjects();
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.purple[100],
                        checkmarkColor: Colors.purple[700],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.purple[700]
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
}
