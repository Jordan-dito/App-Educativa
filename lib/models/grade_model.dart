class Grade {
  final int? id;
  final int estudianteId;
  final int materiaId;
  final int profesorId;
  final String anioAcademico;
  final double? nota1;
  final double? nota2;
  final double? nota3;
  final double? nota4;
  final double? promedio;
  final String? nombreEstudiante;
  final String? nombreMateria;
  final String? nombreProfesor;

  Grade({
    this.id,
    required this.estudianteId,
    required this.materiaId,
    required this.profesorId,
    required this.anioAcademico,
    this.nota1,
    this.nota2,
    this.nota3,
    this.nota4,
    this.promedio,
    this.nombreEstudiante,
    this.nombreMateria,
    this.nombreProfesor,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
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

      // Función helper para convertir a double de forma segura
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          return double.tryParse(value);
        }
        return null;
      }

      return Grade(
        id: json['id'] != null ? parseInt(json['id'], 0) : (json['nota_id'] != null ? parseInt(json['nota_id'], 0) : null),
        estudianteId: parseInt(json['estudiante_id'], 0),
        materiaId: parseInt(json['materia_id'], 0),
        profesorId: parseInt(json['profesor_id'], 0),
        anioAcademico: json['año_academico']?.toString() ?? json['anio_academico']?.toString() ?? DateTime.now().year.toString(),
        nota1: parseDouble(json['nota_1']),
        nota2: parseDouble(json['nota_2']),
        nota3: parseDouble(json['nota_3']),
        nota4: parseDouble(json['nota_4']),
        promedio: parseDouble(json['promedio']),
        nombreEstudiante: json['nombre_estudiante'] ?? json['estudiante_nombre'],
        nombreMateria: json['nombre_materia'] ?? json['materia_nombre'],
        nombreProfesor: json['nombre_profesor'] ?? json['profesor_nombre'],
      );
    } catch (e) {
      print('❌ ERROR Grade.fromJson: Error al parsear JSON: $e');
      print('   JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'profesor_id': profesorId,
      'año_academico': anioAcademico,
      'nota_1': nota1,
      'nota_2': nota2,
      'nota_3': nota3,
      'nota_4': nota4,
    };
  }

  // Lógica de aprobado/reprobado (60 = Aprobado)
  bool get aprobado {
    if (promedio == null) return false;
    return promedio! >= 60.0;
  }

  String get estadoTexto => aprobado ? 'Aprobado' : 'Reprobado';

  String get estadoTextoCompleto {
    if (promedio == null) return 'Sin calificar';
    return aprobado ? 'Aprobado' : 'Reprobado';
  }

  // Método helper para obtener color según la nota
  static String getColorNota(double? nota) {
    if (nota == null) return 'grey';
    if (nota >= 90) return 'green';
    if (nota >= 80) return 'lightGreen';
    if (nota >= 70) return 'yellow';
    if (nota >= 60) return 'orange';
    return 'red';
  }

  // Método para obtener todas las notas en una lista
  List<double?> get todasLasNotas => [nota1, nota2, nota3, nota4];

  // Método para contar cuántas notas tiene
  int get cantidadNotas => todasLasNotas.where((n) => n != null).length;

  // Método para verificar si tiene al menos una nota
  bool get tieneNotas => cantidadNotas > 0;

  // Copiar con
  Grade copyWith({
    int? id,
    int? estudianteId,
    int? materiaId,
    int? profesorId,
    String? anioAcademico,
    double? nota1,
    double? nota2,
    double? nota3,
    double? nota4,
    double? promedio,
    String? nombreEstudiante,
    String? nombreMateria,
    String? nombreProfesor,
  }) {
    return Grade(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      materiaId: materiaId ?? this.materiaId,
      profesorId: profesorId ?? this.profesorId,
      anioAcademico: anioAcademico ?? this.anioAcademico,
      nota1: nota1 ?? this.nota1,
      nota2: nota2 ?? this.nota2,
      nota3: nota3 ?? this.nota3,
      nota4: nota4 ?? this.nota4,
      promedio: promedio ?? this.promedio,
      nombreEstudiante: nombreEstudiante ?? this.nombreEstudiante,
      nombreMateria: nombreMateria ?? this.nombreMateria,
      nombreProfesor: nombreProfesor ?? this.nombreProfesor,
    );
  }
}

