import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/subject_model.dart';
import '../../models/estudiante_reprobado_model.dart';
import '../../services/reforzamiento_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class TeacherSubirMaterialScreen extends StatefulWidget {
  final Subject subject;
  final int profesorId;
  final List<EstudianteReprobado> estudiantesReprobados;

  const TeacherSubirMaterialScreen({
    super.key,
    required this.subject,
    required this.profesorId,
    required this.estudiantesReprobados,
  });

  @override
  State<TeacherSubirMaterialScreen> createState() =>
      _TeacherSubirMaterialScreenState();
}

class _TeacherSubirMaterialScreenState
    extends State<TeacherSubirMaterialScreen> {
  final ReforzamientoApiService _reforzamientoService =
      ReforzamientoApiService();
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlController = TextEditingController();
  final _contenidoController = TextEditingController();

  int? _estudianteSeleccionadoId;
  String _tipoContenido = 'texto';
  File? _archivoSeleccionado;
  DateTime? _fechaVencimiento;
  bool _isLoading = false;

  // Para profesores solo permitimos tipos de contenido texto y link
  final List<String> _tiposContenido = [
    'texto',
    'link'
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _urlController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    try {
      if (_tipoContenido == 'imagen') {
        final ImagePicker picker = ImagePicker();
        final XFile? imagen = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (imagen != null) {
          setState(() {
            _archivoSeleccionado = File(imagen.path);
          });
        }
      } else if (_tipoContenido == 'pdf') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _archivoSeleccionado = File(result.files.single.path!);
          });
        }
      }
    } catch (e) {
      _showError('Error al seleccionar archivo: $e');
    }
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  String _getTargetLabel() {
    if (_estudianteSeleccionadoId == null) return 'Material general (todos los reprobados)';
    final matches = widget.estudiantesReprobados.where((e) => e.estudianteId == _estudianteSeleccionadoId).toList();
    if (matches.isEmpty) return 'Estudiante (id=$_estudianteSeleccionadoId)';
    final est = matches.first;
    return 'Estudiante: ${est.nombreEstudiante}';
  }

  Future<void> _subirMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Confirmación clara del target
    final targetLabel = _getTargetLabel();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar subida'),
        content: Text('Vas a subir material para: $targetLabel\n\n¿Deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Continuar')),
        ],
      ),
    );
    if (confirm != true) return;

    // Validaciones según tipo de contenido
    if (_tipoContenido == 'texto' && _contenidoController.text.isEmpty) {
      _showError('El contenido de texto es requerido');
      return;
    }

    if ((_tipoContenido == 'imagen' || _tipoContenido == 'pdf') &&
        _archivoSeleccionado == null) {
      _showError('Debes seleccionar un archivo');
      return;
    }

    if ((_tipoContenido == 'link' || _tipoContenido == 'video') &&
        _urlController.text.isEmpty) {
      _showError('La URL es requerida');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final success = await _reforzamientoService.subirMaterial(
        materiaId: int.parse(widget.subject.id!),
        estudianteId: _estudianteSeleccionadoId,
        profesorId: widget.profesorId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        tipoContenido: _tipoContenido,
        contenido: _tipoContenido == 'texto'
            ? _contenidoController.text.trim()
            : null,
        archivo: _archivoSeleccionado,
        urlExterna: (_tipoContenido == 'link' || _tipoContenido == 'video')
            ? _urlController.text.trim()
            : null,
        fechaVencimiento: _fechaVencimiento,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showError('Error al subir el material');
      }
    } catch (e) {
      _showError('Error al subir material: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getTipoIcono(String tipo) {
    switch (tipo) {
      case 'texto':
        return '📝';
      case 'imagen':
        return '🖼️';
      case 'pdf':
        return '📄';
      case 'link':
        return '🔗';
      case 'video':
        return '▶️';
      default:
        return '📎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Material de Reforzamiento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info de la materia
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subject.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.subject.grade} - ${widget.subject.section}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estudiante (opcional)
              DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Estudiante (opcional)',
                  hintText: 'Selecciona para material específico',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                value: _estudianteSeleccionadoId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: const Text('Material general (todos los reprobados)'),
                  ),
                  ...widget.estudiantesReprobados.map((est) =>
                      DropdownMenuItem<int?>(
                        value: est.estudianteId,
                        child: Text(est.nombreEstudiante),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _estudianteSeleccionadoId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Tipo de contenido
              const Text(
                'Tipo de contenido *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tiposContenido.map((tipo) {
                  final isSelected = _tipoContenido == tipo;
                  return FilterChip(
                    label: Text('${_getTipoIcono(tipo)} ${tipo.toUpperCase()}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _tipoContenido = tipo;
                        _archivoSeleccionado = null;
                        _urlController.clear();
                        _contenidoController.clear();
                      });
                    },
                    selectedColor: Colors.orange[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Campos condicionales según tipo
              if (_tipoContenido == 'texto') ...[
                TextFormField(
                  controller: _contenidoController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido *',
                    prefixIcon: Icon(Icons.text_fields),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El contenido es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (_tipoContenido == 'imagen' || _tipoContenido == 'pdf') ...[
                ElevatedButton.icon(
                  onPressed: _seleccionarArchivo,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_archivoSeleccionado == null
                      ? 'Seleccionar ${_tipoContenido.toUpperCase()}'
                      : _archivoSeleccionado!.path.split('/').last),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_archivoSeleccionado != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      'Archivo seleccionado: ${_archivoSeleccionado!.path.split('/').last}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() {
                        _archivoSeleccionado = null;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],

              if (_tipoContenido == 'link' || _tipoContenido == 'video') ...[
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL *',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La URL es requerida';
                    }
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'URL inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Fecha de vencimiento (opcional)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de vencimiento (opcional)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                        hintText: _fechaVencimiento == null
                            ? 'No seleccionada'
                            : _fechaVencimiento!.toString().split(' ')[0],
                      ),
                      onTap: _seleccionarFechaVencimiento,
                    ),
                  ),
                  if (_fechaVencimiento != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _fechaVencimiento = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón subir
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _subirMaterial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Subir Material',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

