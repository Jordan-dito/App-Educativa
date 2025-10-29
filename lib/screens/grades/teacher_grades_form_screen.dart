import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/grade_model.dart';
import '../../services/grades_api_service.dart';

class TeacherGradesFormScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  final Subject subject;
  final int profesorId;
  final Grade? existingGrade;

  const TeacherGradesFormScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.profesorId,
    this.existingGrade,
  });

  @override
  State<TeacherGradesFormScreen> createState() => _TeacherGradesFormScreenState();
}

class _TeacherGradesFormScreenState extends State<TeacherGradesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final GradesApiService _gradesService = GradesApiService();
  
  final TextEditingController _nota1Controller = TextEditingController();
  final TextEditingController _nota2Controller = TextEditingController();
  final TextEditingController _nota3Controller = TextEditingController();
  final TextEditingController _nota4Controller = TextEditingController();
  
  bool _isLoading = false;
  double? _calculatedAverage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingGrade != null) {
      _nota1Controller.text = widget.existingGrade!.nota1?.toString() ?? '';
      _nota2Controller.text = widget.existingGrade!.nota2?.toString() ?? '';
      _nota3Controller.text = widget.existingGrade!.nota3?.toString() ?? '';
      _nota4Controller.text = widget.existingGrade!.nota4?.toString() ?? '';
      _calculatedAverage = widget.existingGrade!.promedio;
    }
  }

  @override
  void dispose() {
    _nota1Controller.dispose();
    _nota2Controller.dispose();
    _nota3Controller.dispose();
    _nota4Controller.dispose();
    super.dispose();
  }

  void _calculateAverage() {
    final notes = [
      double.tryParse(_nota1Controller.text),
      double.tryParse(_nota2Controller.text),
      double.tryParse(_nota3Controller.text),
      double.tryParse(_nota4Controller.text),
    ];
    
    final validNotes = notes.where((n) => n != null).toList();
    
    if (validNotes.isNotEmpty && validNotes.length > 0) {
        setState(() {
        _calculatedAverage = validNotes.reduce((a, b) => a! + b!)! / validNotes.length;
      });
    } else {
      setState(() {
        _calculatedAverage = null;
      });
    }
  }

  bool _canSave() {
    final n1 = double.tryParse(_nota1Controller.text);
    final n2 = double.tryParse(_nota2Controller.text);
    final n3 = double.tryParse(_nota3Controller.text);
    final n4 = double.tryParse(_nota4Controller.text);
    
    // Al menos una nota debe tener valor
    if (n1 == null && n2 == null && n3 == null && n4 == null) {
      return false;
    }
    
    // Validar que todas las notas estén entre 0-100 si tienen valor
    if ((n1 != null && (n1 < 0 || n1 > 100)) ||
        (n2 != null && (n2 < 0 || n2 > 100)) ||
        (n3 != null && (n3 < 0 || n3 > 100)) ||
        (n4 != null && (n4 < 0 || n4 > 100))) {
      return false;
    }
    
    return true;
  }

  Future<void> _saveGrades() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_canSave()) {
      _showError('Al menos una nota debe estar entre 0-100');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _gradesService.saveGrade(
        estudianteId: widget.studentId,
        materiaId: int.parse(widget.subject.id!),
        profesorId: widget.profesorId,
        anioAcademico: DateTime.now().year.toString(),
        nota1: double.tryParse(_nota1Controller.text),
        nota2: double.tryParse(_nota2Controller.text),
        nota3: double.tryParse(_nota3Controller.text),
        nota4: double.tryParse(_nota4Controller.text),
      );

      _showSuccess('Notas guardadas exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar notas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildGradeField(String label, int index, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Nota $index',
        hintText: '0 - 100',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.grade),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final note = double.tryParse(value);
          if (note == null) {
            return 'Ingrese un número válido';
          }
          if (note < 0 || note > 100) {
            return 'La nota debe estar entre 0-100';
          }
        }
        return null;
      },
      onChanged: (_) => _calculateAverage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar: ${widget.studentName}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info del estudiante y materia
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child:                             Text(
                              widget.studentName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.book, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.subject.name} - ${widget.subject.grade} ${widget.subject.section}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Campos de notas
              _buildGradeField('Nota 1', 1, _nota1Controller),
              const SizedBox(height: 16),
              _buildGradeField('Nota 2', 2, _nota2Controller),
              const SizedBox(height: 16),
              _buildGradeField('Nota 3', 3, _nota3Controller),
              const SizedBox(height: 16),
              _buildGradeField('Nota 4', 4, _nota4Controller),
              const SizedBox(height: 24),
              
              // Promedio calculado
              if (_calculatedAverage != null)
                Card(
                  color: _calculatedAverage! >= 60
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Promedio Calculado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _calculatedAverage!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _calculatedAverage! >= 60 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            _calculatedAverage! >= 60 ? 'Aprobado' : 'Reprobado',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: _calculatedAverage! >= 60 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_canSave()) ? null : _saveGrades,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Guardar'),
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

