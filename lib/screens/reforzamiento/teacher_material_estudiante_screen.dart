import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/material_reforzamiento_model.dart';
import '../../models/estudiante_reprobado_model.dart';
import '../../services/reforzamiento_api_service.dart';
import 'material_preview_screen.dart';
import 'teacher_subir_material_screen.dart';

class TeacherMaterialEstudianteScreen extends StatefulWidget {
  final int estudianteId;
  final String estudianteNombre;
  final Subject subject;
  final int profesorId;
  final List<EstudianteReprobado> estudiantesReprobados;

  const TeacherMaterialEstudianteScreen({
    super.key,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.subject,
    required this.profesorId,
    required this.estudiantesReprobados,
  });

  @override
  State<TeacherMaterialEstudianteScreen> createState() =>
      _TeacherMaterialEstudianteScreenState();
}

class _TeacherMaterialEstudianteScreenState
    extends State<TeacherMaterialEstudianteScreen> {
  final ReforzamientoApiService _reforzamientoService =
      ReforzamientoApiService();

  List<MaterialReforzamiento> _materiales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateriales();
  }

  Future<void> _loadMateriales() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Usar obtener_estudiante en lugar de obtenerMaterialPorEstudiante
      // porque este endpoint incluye tanto materiales específicos como generales (estudiante_id = NULL)
      final materiales = await _reforzamientoService
          .obtenerMaterialEstudiante(
        estudianteId: widget.estudianteId,
        materiaId: int.parse(widget.subject.id!),
      );

      if (mounted) {
        setState(() {
          _materiales = materiales;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR TeacherMaterialEstudianteScreen._loadMateriales: $e');
      if (mounted) {
        _showError('Error al cargar materiales: $e');
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

  Future<void> _eliminarMaterial(int materialId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: const Text('¿Estás seguro de que deseas eliminar este material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await _reforzamientoService.eliminarMaterial(materialId);
        if (!mounted) return;
        if (success) {
          _showError('Material eliminado exitosamente');
          _loadMateriales();
        } else {
          _showError('Error al eliminar el material');
        }
      } catch (e) {
        if (mounted) {
          _showError('Error al eliminar material: $e');
        }
      }
    }
  }

  void _verMaterial(MaterialReforzamiento material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialPreviewScreen(material: material),
      ),
    );
  }

  Future<void> _editarMaterial(MaterialReforzamiento material) async {
    if (material.id == null) {
      _showError('No se puede editar este material (ID no disponible)');
      return;
    }

    try {
      // Obtener el material completo con todos los datos
      final materialCompleto = await _reforzamientoService.obtenerMaterialPorId(
        materialId: material.id!,
        profesorId: widget.profesorId,
      );

      if (materialCompleto == null || !mounted) {
        _showError('No se pudo cargar el material para editar');
        return;
      }

      // Navegar a la pantalla de edición
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherSubirMaterialScreen(
            subject: widget.subject,
            profesorId: widget.profesorId,
            estudiantesReprobados: widget.estudiantesReprobados,
            materialToEdit: materialCompleto,
          ),
        ),
      );

      // Si se editó exitosamente, recargar materiales
      if (result == true && mounted) {
        _loadMateriales();
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al cargar material para editar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material - ${widget.estudianteNombre}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materiales.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay material subido para este estudiante',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.estudianteNombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.subject.name} - ${widget.subject.grade} ${widget.subject.section}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Lista de materiales
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _materiales.length,
                        itemBuilder: (context, index) {
                          final material = _materiales[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: Text(
                                  material.tipoIcono,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      material.titulo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (material.esNuevo)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'NUEVO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (material.descripcion != null)
                                    Text(
                                      material.descripcion!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    material.fechaPublicacion != null
                                        ? 'Publicado: ${material.fechaPublicacion!.toString().split(' ')[0]}'
                                        : 'Sin fecha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'ver',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility),
                                        SizedBox(width: 8),
                                        Text('Ver'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'editar',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Editar',
                                            style: TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'eliminar',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar',
                                            style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'ver') {
                                    _verMaterial(material);
                                  } else if (value == 'editar') {
                                    _editarMaterial(material);
                                  } else if (value == 'eliminar' &&
                                      material.id != null) {
                                    _eliminarMaterial(material.id!);
                                  }
                                },
                              ),
                              onTap: () => _verMaterial(material),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

