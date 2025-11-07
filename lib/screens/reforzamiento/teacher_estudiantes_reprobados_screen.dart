import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/estudiante_reprobado_model.dart';
import '../../models/material_reforzamiento_model.dart';
import '../../services/reforzamiento_api_service.dart';
import '../../services/attendance_api_service.dart';
import '../../services/enrollment_api_service.dart';
import 'teacher_subir_material_screen.dart';
import 'teacher_material_estudiante_screen.dart';
import 'material_preview_screen.dart';

class TeacherEstudiantesReprobadosScreen extends StatefulWidget {
  final Subject subject;
  final int profesorId;

  const TeacherEstudiantesReprobadosScreen({
    super.key,
    required this.subject,
    required this.profesorId,
  });

  @override
  State<TeacherEstudiantesReprobadosScreen> createState() =>
      _TeacherEstudiantesReprobadosScreenState();
}

class _TeacherEstudiantesReprobadosScreenState
    extends State<TeacherEstudiantesReprobadosScreen> {
  final ReforzamientoApiService _reforzamientoService =
      ReforzamientoApiService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

  List<EstudianteReprobado> _estudiantesReprobados = [];
  List<MaterialReforzamiento> _materiales = [];
  bool _isLoading = true;
  bool _isLoadingMateriales = false;
  bool _showMateriales = false;

  @override
  void initState() {
    super.initState();
    _loadEstudiantesReprobados();
  }

  Future<void> _loadEstudiantesReprobados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Validar que el ciclo académico ya terminó
      final anioAcademico = int.tryParse(widget.subject.academicYear) ?? DateTime.now().year;
      final config = await _attendanceService.getSubjectConfiguration(
        int.parse(widget.subject.id!),
        anioAcademico,
      );

      if (config == null) {
        // No hay configuración, mostrar advertencia pero permitir continuar
        print('⚠️ No se encontró configuración para la materia, validación de fecha no aplica');
      } else {
        // Validar que el ciclo académico ya terminó
        final fechaActual = DateTime.now();
        // Comparar solo las fechas (sin hora) para determinar si el ciclo terminó
        final fechaActualSinHora = DateTime(fechaActual.year, fechaActual.month, fechaActual.day);
        final fechaFinSinHora = DateTime(config.endDate.year, config.endDate.month, config.endDate.day);
        final cicloTerminado = fechaActualSinHora.isAfter(fechaFinSinHora) || fechaActualSinHora.isAtSameMomentAs(fechaFinSinHora);

        if (!cicloTerminado) {
          // El ciclo aún no termina
          if (mounted) {
            _showError('El ciclo académico aún no ha terminado. La fecha de fin es: ${config.endDate.toString().split(' ')[0]}');
            setState(() {
              _estudiantesReprobados = [];
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Obtener estudiantes reprobados
      final estudiantes = await _reforzamientoService
          .obtenerEstudiantesReprobados(
        materiaId: int.parse(widget.subject.id!),
        profesorId: widget.profesorId,
      );

      if (mounted) {
        setState(() {
          _estudiantesReprobados = estudiantes;
          _isLoading = false;
        });
        // Siempre intentar cargar materiales (incluso si no hay estudiantes)
        _loadMateriales();
      }
    } catch (e) {
      print('❌ ERROR TeacherEstudiantesReprobadosScreen._loadEstudiantesReprobados: $e');
      if (mounted) {
        _showError('Error al cargar estudiantes reprobados: $e');
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

  void _navigateToSubirMaterial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherSubirMaterialScreen(
          subject: widget.subject,
          profesorId: widget.profesorId,
          estudiantesReprobados: _estudiantesReprobados,
        ),
      ),
    ).then((result) {
      // Recargar materiales después de subir/editar material
      debugPrint('🔄 Recargando materiales después de subir/editar...');
      _loadEstudiantesReprobados();
      // Esperar un momento antes de recargar materiales para asegurar que el backend haya procesado
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _loadMateriales();
        }
      });
    });
  }

  Future<void> _loadMateriales() async {
    setState(() => _isLoadingMateriales = true);
    
    try {
      List<MaterialReforzamiento> todosLosMateriales = [];
      final Set<int> materialIds = {}; // Para evitar duplicados
      
      debugPrint('🔍 DEBUG _loadMateriales: Iniciando carga de materiales');
      debugPrint('   Profesor ID: ${widget.profesorId}');
      debugPrint('   Materia ID: ${widget.subject.id}');
      debugPrint('   Estudiantes reprobados: ${_estudiantesReprobados.length}');
      
      // Método principal: usar obtenerMaterialEstudiante con el primer estudiante reprobado
      // Este endpoint retorna materiales generales (estudiante_id = NULL) Y materiales específicos
      if (_estudiantesReprobados.isNotEmpty) {
        debugPrint('📚 Obteniendo materiales usando primer estudiante: ${_estudiantesReprobados.first.estudianteId}');
        
        try {
          final materialesPrimerEstudiante = await _reforzamientoService.obtenerMaterialEstudiante(
            estudianteId: _estudiantesReprobados.first.estudianteId,
            materiaId: int.parse(widget.subject.id!),
          );
          
          debugPrint('📚 Materiales obtenidos del primer estudiante: ${materialesPrimerEstudiante.length}');
          
          // Filtrar solo materiales del profesor actual
          // MEJORADO: Aceptar materiales si pertenecen a la materia y:
          // 1. El profesor_id coincide exactamente, O
          // 2. El profesor_id es 0/null y la materia pertenece al profesor actual, O
          // 3. La materia pertenece al profesor actual (validación adicional)
          final materiaDelProfesor = widget.subject.teacherId != null && 
                                    widget.subject.teacherId == widget.profesorId.toString();
          
          for (var material in materialesPrimerEstudiante) {
            final materialProfesorId = material.profesorId;
            final materialMateriaId = material.materiaId;
            debugPrint('   🔍 Material ID: ${material.id}');
            debugPrint('      - Título: ${material.titulo}');
            debugPrint('      - Profesor ID del material: $materialProfesorId');
            debugPrint('      - Profesor ID esperado: ${widget.profesorId}');
            debugPrint('      - Materia ID del material: $materialMateriaId');
            debugPrint('      - Materia ID esperada: ${widget.subject.id}');
            debugPrint('      - Materia pertenece al profesor: $materiaDelProfesor');
            
            // Verificar que el material pertenezca a la materia correcta
            final materiaCorrecta = materialMateriaId.toString() == widget.subject.id ||
                                   materialMateriaId == int.parse(widget.subject.id ?? '0');
            
            if (!materiaCorrecta) {
              debugPrint('   ⏭️ Material de otra materia omitido: Materia ID $materialMateriaId != ${widget.subject.id}');
              continue;
            }
            
            // Verificar si el material pertenece al profesor actual
            // Estrategia más permisiva: si el material es de la materia correcta y:
            // - El profesor_id coincide, O
            // - El profesor_id es 0/null y la materia pertenece al profesor, O
            // - La materia pertenece al profesor (asumimos que es del profesor si la materia es suya)
            final esDelProfesor = materialProfesorId == widget.profesorId || 
                                 (materialProfesorId == 0 && materiaDelProfesor) ||
                                 materiaDelProfesor; // Si la materia es del profesor, asumir que el material también
            
            if (!esDelProfesor) {
              debugPrint('   ⏭️ Material de otro profesor omitido: Profesor ID $materialProfesorId != ${widget.profesorId}, materia del prof: $materiaDelProfesor');
              continue;
            }
            
            // Agregar el material si no está duplicado
            if (material.id == null || !materialIds.contains(material.id!)) {
              todosLosMateriales.add(material);
              if (material.id != null) {
                materialIds.add(material.id!);
                debugPrint('   ✅ Material AGREGADO: ${material.titulo} (ID: ${material.id}, Profesor: $materialProfesorId)');
              } else {
                debugPrint('   ✅ Material AGREGADO: ${material.titulo} (sin ID, Profesor: $materialProfesorId)');
              }
            } else {
              debugPrint('   ⏭️ Material duplicado omitido: ${material.id}');
            }
          }
          
          if (todosLosMateriales.isEmpty && materialesPrimerEstudiante.isNotEmpty) {
            debugPrint('⚠️ ADVERTENCIA: Se obtuvieron ${materialesPrimerEstudiante.length} materiales pero ninguno coincide con los criterios');
            debugPrint('   Profesor esperado: ${widget.profesorId}');
            debugPrint('   Materia esperada: ${widget.subject.id}');
            debugPrint('   Materiales recibidos:');
            for (var m in materialesPrimerEstudiante) {
              debugPrint('      - ID: ${m.id}, Título: ${m.titulo}, Profesor: ${m.profesorId}, Materia: ${m.materiaId}');
            }
          }
          
          // Obtener materiales específicos de otros estudiantes
          if (_estudiantesReprobados.length > 1) {
            debugPrint('📚 Obteniendo materiales de otros ${_estudiantesReprobados.length - 1} estudiantes');
            
            for (var estudiante in _estudiantesReprobados.skip(1)) {
              try {
                final materialesEstudiante = await _reforzamientoService.obtenerMaterialEstudiante(
                  estudianteId: estudiante.estudianteId,
                  materiaId: int.parse(widget.subject.id!),
                );
                
                for (var material in materialesEstudiante) {
                  // Solo agregar materiales específicos de este estudiante que pertenezcan al profesor
                  if (material.profesorId == widget.profesorId &&
                      material.estudianteId != null && // Solo materiales específicos
                      (material.id == null || !materialIds.contains(material.id!))) {
                    todosLosMateriales.add(material);
                    if (material.id != null) {
                      materialIds.add(material.id!);
                    }
                  }
                }
              } catch (e) {
                debugPrint('⚠️ Error obteniendo materiales del estudiante ${estudiante.estudianteId}: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('❌ Error obteniendo materiales del primer estudiante: $e');
          debugPrint('   Stack trace: $e');
        }
      } else {
        // Si no hay estudiantes reprobados, intentar obtener materiales generales
        // usando cualquier estudiante inscrito en la materia
        debugPrint('⚠️ No hay estudiantes reprobados, intentando obtener materiales generales usando estudiantes inscritos...');
        
        try {
          // Intentar obtener inscripciones de la materia para usar un estudiante como referencia
          final enrollmentService = EnrollmentApiService();
          final allEnrollments = await enrollmentService.getAllEnrollments();
          
          // Buscar un estudiante inscrito en esta materia
          final enrollmentsMateria = allEnrollments.where((e) => 
            e.materiaId == int.parse(widget.subject.id!) && 
            e.estado == 'activo'
          ).toList();
          
          if (enrollmentsMateria.isNotEmpty) {
            final primerEstudianteId = enrollmentsMateria.first.estudianteId;
            debugPrint('📚 Usando estudiante inscrito ID: $primerEstudianteId para obtener materiales generales');
            
            try {
              final materialesGenerales = await _reforzamientoService.obtenerMaterialEstudiante(
                estudianteId: primerEstudianteId,
                materiaId: int.parse(widget.subject.id!),
              );
              
              debugPrint('📚 Materiales obtenidos (generales y específicos): ${materialesGenerales.length}');
              
              // Filtrar solo materiales del profesor actual y de la materia correcta
              // Incluir materiales generales (estudianteId == null) Y específicos del profesor
              final materiaDelProfesor = widget.subject.teacherId != null && 
                                        widget.subject.teacherId == widget.profesorId.toString();
              
              for (var material in materialesGenerales) {
                final materialProfesorId = material.profesorId;
                final materialMateriaId = material.materiaId;
                final esGeneral = material.estudianteId == null;
                final materiaCorrecta = materialMateriaId.toString() == widget.subject.id ||
                                       materialMateriaId == int.parse(widget.subject.id ?? '0');
                
                // Estrategia más permisiva para incluir materiales del profesor
                final esDelProfesor = materialProfesorId == widget.profesorId || 
                                     (materialProfesorId == 0 && materiaDelProfesor) ||
                                     materiaDelProfesor;
                
                debugPrint('   🔍 Material: ${material.titulo}');
                debugPrint('      - Materia correcta: $materiaCorrecta');
                debugPrint('      - Es del profesor: $esDelProfesor (prof ID: $materialProfesorId, esperado: ${widget.profesorId})');
                debugPrint('      - Es general: $esGeneral');
                
                // Incluir materiales de la materia correcta que pertenezcan al profesor
                if (materiaCorrecta && esDelProfesor) {
                  if (material.id == null || !materialIds.contains(material.id!)) {
                    todosLosMateriales.add(material);
                    if (material.id != null) {
                      materialIds.add(material.id!);
                      debugPrint('   ✅ Material AGREGADO: ${material.titulo} (ID: ${material.id}, General: $esGeneral)');
                    } else {
                      debugPrint('   ✅ Material AGREGADO: ${material.titulo} (sin ID, General: $esGeneral)');
                    }
                  } else {
                    debugPrint('   ⏭️ Material duplicado: ${material.id}');
                  }
                } else {
                  if (!materiaCorrecta) {
                    debugPrint('   ⏭️ Material omitido: materia incorrecta');
                  } else {
                    debugPrint('   ⏭️ Material omitido: no es del profesor');
                  }
                }
              }
            } catch (e) {
              debugPrint('❌ Error obteniendo materiales usando estudiante inscrito: $e');
            }
          } else {
            debugPrint('⚠️ No se encontraron estudiantes inscritos en la materia para usar como referencia');
          }
        } catch (e) {
          debugPrint('❌ Error obteniendo inscripciones: $e');
        }
      }
      
      debugPrint('✅ Total materiales encontrados: ${todosLosMateriales.length}');
      
      if (mounted) {
        setState(() {
          _materiales = todosLosMateriales;
          _isLoadingMateriales = false;
        });
        debugPrint('✅ Materiales cargados en estado: ${todosLosMateriales.length}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR TeacherEstudiantesReprobadosScreen._loadMateriales: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _materiales = [];
          _isLoadingMateriales = false;
        });
      }
    }
  }

  void _navigateToMaterialEstudiante(EstudianteReprobado estudiante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherMaterialEstudianteScreen(
          estudianteId: estudiante.estudianteId,
          estudianteNombre: estudiante.nombreEstudiante,
          subject: widget.subject,
          profesorId: widget.profesorId,
          estudiantesReprobados: _estudiantesReprobados,
        ),
      ),
    ).then((_) {
      _loadEstudiantesReprobados();
      _loadMateriales();
    });
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
            estudiantesReprobados: _estudiantesReprobados,
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
          _showSuccessMessage('Material eliminado exitosamente');
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

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }


  Color _getPromedioColor(double promedio) {
    if (promedio < 40) return Colors.red;
    if (promedio < 50) return Colors.deepOrange;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes Reprobados - ${widget.subject.name}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
                  children: [
                    // Info de la materia
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange[50],
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
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total de reprobados: ${_estudiantesReprobados.length}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Materiales: ${_materiales.length}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Sección de materiales del profesor (siempre visible)
                    ExpansionTile(
                        leading: Icon(Icons.description, color: Colors.orange[700]),
                        title: Text(
                          'Mis Materiales (${_materiales.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        subtitle: const Text('Ver y editar materiales subidos'),
                        initiallyExpanded: _showMateriales,
                        onExpansionChanged: (expanded) {
                          setState(() => _showMateriales = expanded);
                        },
                        children: [
                          _isLoadingMateriales
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : _materiales.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay materiales subidos',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Toca el botón + para subir tu primer material',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: _materiales.isEmpty ? 1 : _materiales.length,
                                      itemBuilder: (context, index) {
                                        if (_materiales.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Card(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: [
                                                    Icon(Icons.description, size: 48, color: Colors.grey[400]),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'No hay materiales subidos',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Sube material usando el botón "Subir Material"',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[500],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        
                                        final material = _materiales[index];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          elevation: 1,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.orange[100],
                                              child: Text(
                                                material.tipoIcono,
                                                style: const TextStyle(fontSize: 20),
                                              ),
                                            ),
                                            title: Text(
                                              material.titulo,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (material.descripcion != null)
                                                  Text(
                                                    material.descripcion!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Builder(
                                                      builder: (context) {
                                                        String labelText;
                                                        IconData icon;
                                                        Color chipColor;
                                                        
                                                        if (material.estudianteId == null) {
                                                          labelText = 'Todos los reprobados';
                                                          icon = Icons.people;
                                                          chipColor = Colors.blue;
                                                        } else {
                                                          // Buscar el nombre del estudiante
                                                          final estudianteEncontrado = _estudiantesReprobados
                                                              .where((e) => e.estudianteId == material.estudianteId)
                                                              .firstOrNull;
                                                          
                                                          if (estudianteEncontrado != null) {
                                                            labelText = estudianteEncontrado.nombreEstudiante;
                                                          } else {
                                                            labelText = 'Estudiante desconocido';
                                                          }
                                                          icon = Icons.person;
                                                          chipColor = Colors.green;
                                                        }
                                                        
                                                        return Chip(
                                                          avatar: Icon(
                                                            icon,
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            labelText,
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          backgroundColor: chipColor,
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 8, vertical: 4),
                                                        );
                                                      },
                                                    ),
                                                  ],
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
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MaterialPreviewScreen(
                                                              material: material),
                                                    ),
                                                  );
                                                } else if (value == 'editar') {
                                                  _editarMaterial(material);
                                                } else if (value == 'eliminar' &&
                                                    material.id != null) {
                                                  _eliminarMaterial(material.id!);
                                                }
                                              },
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MaterialPreviewScreen(
                                                          material: material),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    // Lista de estudiantes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_estudiantesReprobados.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Estudiantes Reprobados',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          Expanded(
                            child: _estudiantesReprobados.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.school, size: 64, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No hay estudiantes reprobados en esta materia',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _estudiantesReprobados.length,
                                    itemBuilder: (context, index) {
                                      final estudiante =
                                          _estudiantesReprobados[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        elevation: 2,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                _getPromedioColor(estudiante.promedio)
                                                    .withOpacity(0.2),
                                            child: Text(
                                              estudiante.nombreEstudiante[0].toUpperCase(),
                                              style: TextStyle(
                                                color: _getPromedioColor(estudiante.promedio),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            estudiante.nombreEstudiante,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Chip(
                                                label: Text(
                                                  'Promedio: ${estudiante.promedio.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 12, color: Colors.white),
                                                ),
                                                backgroundColor:
                                                    _getPromedioColor(estudiante.promedio),
                                                padding: EdgeInsets.zero,
                                                labelPadding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 0),
                                              ),
                                            ],
                                          ),
                                          onTap: () => _navigateToMaterialEstudiante(estudiante),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSubirMaterial,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Subir Material'),
      ),
    );
  }
}

