class Enrollment {
  final int id;
  final int estudianteId;
  final String estudianteNombre;
  final String estudianteGrado;
  final String estudianteSeccion;
  final int materiaId;
  final String materiaNombre;
  final String fechaInscripcion;
  final String estado;
  final int? profesorId;
  final String? profesorNombre;

  Enrollment({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.estudianteSeccion,
    required this.materiaId,
    required this.materiaNombre,
    required this.fechaInscripcion,
    required this.estado,
    this.profesorId,
    this.profesorNombre,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    // Debug: Imprimir la estructura completa del JSON recibido
    print('🔍 DEBUG Enrollment.fromJson: JSON recibido: $json');
    print(
        '🔍 DEBUG Enrollment.fromJson: Claves disponibles: ${json.keys.toList()}');

    // Función helper para convertir a int de forma segura
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? safeIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Debug específico para IDs
    print('🔍 DEBUG Enrollment.fromJson: Valores de ID encontrados:');
    print('  - json["id"]: ${json['id']}');
    print('  - json["estudiante_id"]: ${json['estudiante_id']}');
    print('  - json["materia_id"]: ${json['materia_id']}');
    print('  - json["profesor_id"]: ${json['profesor_id']}');

    // Intentar diferentes nombres de campos que podrían venir del endpoint
    final enrollment = Enrollment(
      id: safeInt(json['inscripcion_id'] ?? json['id'] ?? json['ID']),
      estudianteId: safeInt(
          json['estudiante_id'] ?? json['student_id'] ?? json['id_estudiante']),
      estudianteNombre: (json['estudiante_nombre'] ??
              json['student_name'] ??
              json['nombre_estudiante'] ??
              json['nombre'] ??
              '')
          .toString(),
      estudianteGrado: (json['estudiante_grado'] ??
              json['student_grade'] ??
              json['grado_estudiante'] ??
              json['grado'] ??
              '')
          .toString(),
      estudianteSeccion: (json['estudiante_seccion'] ??
              json['student_section'] ??
              json['seccion_estudiante'] ??
              json['seccion'] ??
              '')
          .toString(),
      materiaId: safeInt(
          json['materia_id'] ?? json['subject_id'] ?? json['id_materia']),
      materiaNombre: (json['materia_nombre'] ??
              json['subject_name'] ??
              json['nombre_materia'] ??
              json['materia'] ??
              '')
          .toString(),
      fechaInscripcion: (json['fecha_inscripcion'] ??
              json['enrollment_date'] ??
              json['fecha'] ??
              json['created_at'] ??
              '')
          .toString(),
      estado: (json['estado'] ?? json['estado_inscripcion'] ?? json['status'] ?? json['state'] ?? 'activo')
          .toString(),
      profesorId: safeIntNullable(
          json['profesor_id'] ?? json['teacher_id'] ?? json['id_profesor']),
      profesorNombre: (json['profesor_nombre'] ??
              json['teacher_name'] ??
              json['nombre_profesor'] ??
              json['profesor'] ??
              '')
          .toString(),
    );

    print('🔍 DEBUG Enrollment.fromJson: Objeto creado:');
    print('  - ID: ${enrollment.id}');
    print('  - Estudiante ID: ${enrollment.estudianteId}');
    print('  - Estudiante: ${enrollment.estudianteNombre}');
    print('  - Grado: ${enrollment.estudianteGrado}');
    print('  - Sección: ${enrollment.estudianteSeccion}');
    print('  - Materia ID: ${enrollment.materiaId}');
    print('  - Materia: ${enrollment.materiaNombre}');
    print('  - Profesor ID: ${enrollment.profesorId}');
    print('  - Profesor: ${enrollment.profesorNombre}');
    print('  - Fecha: ${enrollment.fechaInscripcion}');
    print('  - Estado: ${enrollment.estado}');

    return enrollment;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'estudiante_nombre': estudianteNombre,
      'estudiante_grado': estudianteGrado,
      'estudiante_seccion': estudianteSeccion,
      'materia_id': materiaId,
      'materia_nombre': materiaNombre,
      'fecha_inscripcion': fechaInscripcion,
      'estado': estado,
      'profesor_id': profesorId,
      'profesor_nombre': profesorNombre,
    };
  }

  // Método para crear una nueva inscripción (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'fecha_inscripcion': fechaInscripcion,
      'estado': estado,
      'profesor_id': profesorId,
    };
  }
}
