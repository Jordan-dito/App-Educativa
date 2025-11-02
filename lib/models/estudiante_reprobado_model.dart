class EstudianteReprobado {
  final int estudianteId;
  final String nombreEstudiante;
  final double promedio;
  final int materiaId;
  final String nombreMateria;

  EstudianteReprobado({
    required this.estudianteId,
    required this.nombreEstudiante,
    required this.promedio,
    required this.materiaId,
    required this.nombreMateria,
  });

  factory EstudianteReprobado.fromJson(Map<String, dynamic> json) {
    return EstudianteReprobado(
      estudianteId: json['estudiante_id'] ?? json['estudianteId'] ?? 0,
      nombreEstudiante: json['nombre_estudiante'] ?? json['nombreEstudiante'] ?? '',
      promedio: (json['promedio'] is double)
          ? json['promedio']
          : (json['promedio'] is int)
              ? json['promedio'].toDouble()
              : double.tryParse(json['promedio'].toString()) ?? 0.0,
      materiaId: json['materia_id'] ?? json['materiaId'] ?? 0,
      nombreMateria: json['nombre_materia'] ?? json['nombreMateria'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estudiante_id': estudianteId,
      'nombre_estudiante': nombreEstudiante,
      'promedio': promedio,
      'materia_id': materiaId,
      'nombre_materia': nombreMateria,
    };
  }
}

