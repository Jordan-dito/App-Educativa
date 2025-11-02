class MaterialReforzamiento {
  final int? id;
  final int materiaId;
  final int? estudianteId;
  final int profesorId;
  final String anioAcademico;
  final String titulo;
  final String? descripcion;
  final String tipoContenido; // 'texto', 'imagen', 'pdf', 'link', 'video'
  final String? contenido; // Para tipo 'texto'
  final String? archivoNombre;
  final String? archivoRuta;
  final String? urlExterna;
  final DateTime? fechaPublicacion;
  final DateTime? fechaVencimiento;

  MaterialReforzamiento({
    this.id,
    required this.materiaId,
    this.estudianteId,
    required this.profesorId,
    required this.anioAcademico,
    required this.titulo,
    this.descripcion,
    required this.tipoContenido,
    this.contenido,
    this.archivoNombre,
    this.archivoRuta,
    this.urlExterna,
    this.fechaPublicacion,
    this.fechaVencimiento,
  });

  factory MaterialReforzamiento.fromJson(Map<String, dynamic> json) {
    try {
      // Función helper para convertir a int de forma segura
      int parseInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? defaultValue;
        }
        if (value is double) return value.toInt();
        return defaultValue;
      }

      // Función helper para parsear fechas de forma segura
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      return MaterialReforzamiento(
        id: json['id'] != null ? parseInt(json['id'], 0) : null,
        materiaId: parseInt(json['materia_id'] ?? json['materiaId'], 0),
        estudianteId: json['estudiante_id'] != null 
            ? parseInt(json['estudiante_id'], 0)
            : (json['estudianteId'] != null ? parseInt(json['estudianteId'], 0) : null),
        profesorId: parseInt(json['profesor_id'] ?? json['profesorId'], 0),
        anioAcademico: json['año_academico']?.toString() ?? 
                      json['anio_academico']?.toString() ?? 
                      json['anioAcademico']?.toString() ?? 
                      DateTime.now().year.toString(),
        titulo: json['titulo']?.toString() ?? json['title']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? json['description']?.toString(),
        tipoContenido: json['tipo_contenido']?.toString() ?? json['tipoContenido']?.toString() ?? 'texto',
        contenido: json['contenido']?.toString() ?? json['content']?.toString(),
        archivoNombre: json['archivo_nombre']?.toString() ?? json['archivoNombre']?.toString() ?? json['file_name']?.toString(),
        archivoRuta: json['archivo_ruta']?.toString() ?? json['archivoRuta']?.toString() ?? json['file_path']?.toString(),
        urlExterna: json['url_externa']?.toString() ?? json['urlExterna']?.toString() ?? json['url']?.toString(),
        fechaPublicacion: parseDateTime(json['fecha_publicacion'] ?? json['fechaPublicacion'] ?? json['fecha_creacion'] ?? json['fechaCreacion']),
        fechaVencimiento: parseDateTime(json['fecha_vencimiento'] ?? json['fechaVencimiento']),
      );
    } catch (e) {
      print('❌ ERROR MaterialReforzamiento.fromJson: Error al parsear JSON: $e');
      print('   JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'materia_id': materiaId,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      'profesor_id': profesorId,
      'año_academico': anioAcademico,
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'tipo_contenido': tipoContenido,
      if (contenido != null) 'contenido': contenido,
      if (archivoNombre != null) 'archivo_nombre': archivoNombre,
      if (archivoRuta != null) 'archivo_ruta': archivoRuta,
      if (urlExterna != null) 'url_externa': urlExterna,
      if (fechaPublicacion != null) 'fecha_publicacion': fechaPublicacion!.toIso8601String(),
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento!.toIso8601String(),
    };
  }

  // Helpers
  bool get esNuevo {
    if (fechaPublicacion == null) return false;
    final diferencia = DateTime.now().difference(fechaPublicacion!);
    return diferencia.inDays <= 7; // Nuevo si tiene menos de 7 días
  }

  bool get estaVencido {
    if (fechaVencimiento == null) return false;
    return DateTime.now().isAfter(fechaVencimiento!);
  }

  String get tipoIcono {
    switch (tipoContenido.toLowerCase()) {
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
}

