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
    return MaterialReforzamiento(
      id: json['id'],
      materiaId: json['materia_id'] ?? json['materiaId'] ?? 0,
      estudianteId: json['estudiante_id'] ?? json['estudianteId'],
      profesorId: json['profesor_id'] ?? json['profesorId'] ?? 0,
      anioAcademico: json['año_academico']?.toString() ?? 
                    json['anio_academico']?.toString() ?? 
                    json['anioAcademico']?.toString() ?? 
                    DateTime.now().year.toString(),
      titulo: json['titulo'] ?? json['title'] ?? '',
      descripcion: json['descripcion'] ?? json['description'],
      tipoContenido: json['tipo_contenido'] ?? json['tipoContenido'] ?? 'texto',
      contenido: json['contenido'] ?? json['content'],
      archivoNombre: json['archivo_nombre'] ?? json['archivoNombre'] ?? json['file_name'],
      archivoRuta: json['archivo_ruta'] ?? json['archivoRuta'] ?? json['file_path'],
      urlExterna: json['url_externa'] ?? json['urlExterna'] ?? json['url'],
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'])
          : json['fechaPublicacion'] != null
              ? DateTime.parse(json['fechaPublicacion'])
              : null,
      fechaVencimiento: json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'])
          : json['fechaVencimiento'] != null
              ? DateTime.parse(json['fechaVencimiento'])
              : null,
    );
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

