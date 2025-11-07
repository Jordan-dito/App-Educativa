class ReporteNotasModel {
  final bool success;
  final String message;
  final ReporteNotasData? data;

  ReporteNotasModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReporteNotasModel.fromJson(Map<String, dynamic> json) {
    return ReporteNotasModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ReporteNotasData.fromJson(json['data'])
          : null,
    );
  }
}

class ReporteNotasData {
  final EstudianteInfo estudiante;
  final String anioAcademico;
  final EstadisticasNotas estadisticas;
  final List<NotaMateria> notas;

  ReporteNotasData({
    required this.estudiante,
    required this.anioAcademico,
    required this.estadisticas,
    required this.notas,
  });

  factory ReporteNotasData.fromJson(Map<String, dynamic> json) {
    return ReporteNotasData(
      estudiante: EstudianteInfo.fromJson(json['estudiante']),
      anioAcademico: json['año_academico'].toString(),
      estadisticas: EstadisticasNotas.fromJson(json['estadisticas']),
      notas: (json['notas'] as List)
          .map((nota) => NotaMateria.fromJson(nota))
          .toList(),
    );
  }
}

class EstudianteInfo {
  final int id;
  final String nombre;
  final String apellido;
  final String grado;
  final String seccion;

  EstudianteInfo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.grado,
    required this.seccion,
  });

  factory EstudianteInfo.fromJson(Map<String, dynamic> json) {
    return EstudianteInfo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      grado: json['grado'] ?? '',
      seccion: json['seccion'] ?? '',
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}

class EstadisticasNotas {
  final double? promedioGeneral;
  final int totalMaterias;
  final int materiasAprobadas;
  final int materiasReprobadas;

  EstadisticasNotas({
    this.promedioGeneral,
    required this.totalMaterias,
    required this.materiasAprobadas,
    required this.materiasReprobadas,
  });

  factory EstadisticasNotas.fromJson(Map<String, dynamic> json) {
    return EstadisticasNotas(
      promedioGeneral: json['promedio_general'] != null
          ? double.tryParse(json['promedio_general'].toString())
          : null,
      totalMaterias: json['total_materias'] ?? 0,
      materiasAprobadas: json['materias_aprobadas'] ?? 0,
      materiasReprobadas: json['materias_reprobadas'] ?? 0,
    );
  }
}

class NotaMateria {
  final int id;
  final int materiaId;
  final String nombreMateria;
  final String grado;
  final String seccion;
  final String? nombreProfesor;
  final double? nota1;
  final double? nota2;
  final double? nota3;
  final double? nota4;
  final double? promedio;
  final String anioAcademico;
  final String? fechaFinAnio;
  final String estadoMateria; // "Aprobado" o "Reprobado"

  NotaMateria({
    required this.id,
    required this.materiaId,
    required this.nombreMateria,
    required this.grado,
    required this.seccion,
    this.nombreProfesor,
    this.nota1,
    this.nota2,
    this.nota3,
    this.nota4,
    this.promedio,
    required this.anioAcademico,
    this.fechaFinAnio,
    required this.estadoMateria,
  });

  factory NotaMateria.fromJson(Map<String, dynamic> json) {
    return NotaMateria(
      id: json['id'] ?? 0,
      materiaId: json['materia_id'] ?? 0,
      nombreMateria: json['nombre_materia'] ?? '',
      grado: json['grado'] ?? '',
      seccion: json['seccion'] ?? '',
      nombreProfesor: json['nombre_profesor'],
      nota1: json['nota_1'] != null
          ? double.tryParse(json['nota_1'].toString())
          : null,
      nota2: json['nota_2'] != null
          ? double.tryParse(json['nota_2'].toString())
          : null,
      nota3: json['nota_3'] != null
          ? double.tryParse(json['nota_3'].toString())
          : null,
      nota4: json['nota_4'] != null
          ? double.tryParse(json['nota_4'].toString())
          : null,
      promedio: json['promedio'] != null
          ? double.tryParse(json['promedio'].toString())
          : null,
      anioAcademico: json['año_academico'].toString(),
      fechaFinAnio: json['fecha_fin_año'],
      estadoMateria: json['estado_materia'] ?? '',
    );
  }

  bool get estaAprobado => estadoMateria == 'Aprobado';
}

