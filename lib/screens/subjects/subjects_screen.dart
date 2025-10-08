import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/subject_service.dart';
import 'add_edit_subject_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectService _subjectService = SubjectService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = true;
  String _selectedDepartment = 'Todos';
  String _selectedLevel = 'Todos';
  String _selectedGrade = 'Todos';

  final List<String> _departments = ['Todos', ...Subject.departments];
  final List<String> _levels = ['Todos', ...Subject.levels];
  List<String> _grades = ['Todos'];

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
      final subjects = await _subjectService.getAllSubjects();
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Error al cargar materias: $e');
    }
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSubjects = _subjects.where((subject) {
        final matchesSearch = query.isEmpty ||
            subject.name.toLowerCase().contains(query) ||
            subject.code.toLowerCase().contains(query) ||
            subject.description.toLowerCase().contains(query) ||
            subject.department.toLowerCase().contains(query);
        
        final matchesDepartment = _selectedDepartment == 'Todos' ||
            subject.department == _selectedDepartment;
        
        final matchesLevel = _selectedLevel == 'Todos' ||
            subject.level == _selectedLevel;
        
        final matchesGrade = _selectedGrade == 'Todos' ||
            subject.grade == _selectedGrade;
        
        return matchesSearch && matchesDepartment && matchesLevel && matchesGrade;
      }).toList();
    });
  }

  void _updateGradesForLevel(String level) {
    setState(() {
      if (level == 'Todos') {
        _grades = ['Todos'];
        _selectedGrade = 'Todos';
      } else {
        _grades = ['Todos', ...Subject.getGradesForLevel(level)];
        _selectedGrade = 'Todos';
      }
    });
    _filterSubjects();
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
        content: Text('¿Está seguro de que desea eliminar la materia "${subject.name}"?'),
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
        await _subjectService.deleteSubject(subject.id!);
        _showSuccessMessage('Materia eliminada exitosamente');
        _loadSubjects();
      } catch (e) {
        _showErrorMessage('Error al eliminar materia: $e');
      }
    }
  }

  void _showSubjectDetails(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Código:', subject.code),
              _buildDetailRow('Descripción:', subject.description),
              _buildDetailRow('Departamento:', subject.department),
              _buildDetailRow('Nivel:', subject.level),
              _buildDetailRow('Grado:', subject.grade),
              _buildDetailRow('Créditos:', subject.credits.toString()),
              _buildDetailRow('Horas/Semana:', subject.hoursPerWeek.toString()),
              _buildDetailRow('Profesor:', subject.teacherName ?? 'Sin asignar'),
              _buildDetailRow('Estado:', subject.isActive ? 'Activa' : 'Inactiva'),
              _buildDetailRow('Creada:', _formatDate(subject.createdAt)),
              if (subject.updatedAt != null)
                _buildDetailRow('Actualizada:', _formatDate(subject.updatedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEditSubject(subject);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
      appBar: AppBar(
        title: const Text('Gestión de Materias'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubjects,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSubject,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar materias...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtros
                Row(
                  children: [
                    // Filtro por departamento
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Departamento',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _departments.map((department) {
                          return DropdownMenuItem(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value!);
                          _filterSubjects();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Filtro por nivel
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Nivel',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedLevel = value!);
                          _updateGradesForLevel(value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Filtro por grado
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'Grado',
                          border: OutlineInputBorder(),
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
                          _filterSubjects();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de materias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _subjects.isEmpty
                                  ? 'No hay materias registradas'
                                  : 'No se encontraron materias',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subjects.isEmpty
                                  ? 'Toca el botón + para agregar la primera materia'
                                  : 'Intenta con otros filtros de búsqueda',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSubjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: subject.isActive 
                                      ? Colors.purple 
                                      : Colors.grey,
                                  child: Text(
                                    subject.code.substring(0, 2).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  subject.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${subject.code} - ${subject.department}'),
                                    Text('${subject.levelGrade} - ${subject.workload}'),
                                    if (subject.teacherName != null)
                                      Text('Profesor: ${subject.teacherName}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view':
                                        _showSubjectDetails(subject);
                                        break;
                                      case 'edit':
                                        _navigateToEditSubject(subject);
                                        break;
                                      case 'delete':
                                        _deleteSubject(subject);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: ListTile(
                                        leading: Icon(Icons.visibility),
                                        title: Text('Ver detalles'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Editar'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _showSubjectDetails(subject),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}