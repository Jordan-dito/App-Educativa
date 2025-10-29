class SubjectConfiguration {
  final int? id;
  final int subjectId;
  final int teacherId;
  final String academicYear;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> classDays; // ['lunes', 'miercoles', 'viernes']
  final String? classTime; // "08:00" formato opcional
  final int attendanceGoal; // Meta de asistencia en porcentaje (ej: 80)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubjectConfiguration({
    this.id,
    required this.subjectId,
    required this.teacherId,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    required this.classDays,
    this.classTime,
    required this.attendanceGoal,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectConfiguration.fromJson(Map<String, dynamic> json) {
    // Manejar diferentes formatos de días de clase
    List<String> classDays = [];
    if (json['dias_clase'] != null) {
      if (json['dias_clase'] is String) {
        // Si viene como string separado por comas
        final diasStr = json['dias_clase'] as String;
        if (diasStr.isNotEmpty) {
          classDays = diasStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else if (json['dias_clase'] is List) {
        // Si viene como array
        final diasList = json['dias_clase'] as List;
        classDays = diasList
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else if (json['class_days'] != null) {
      if (json['class_days'] is String) {
        final diasStr = json['class_days'] as String;
        if (diasStr.isNotEmpty) {
          classDays = diasStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else if (json['class_days'] is List) {
        final diasList = json['class_days'] as List;
        classDays = diasList
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return SubjectConfiguration(
      id: json['id'] ?? json['configuracion_id'],
      subjectId: json['materia_id'] ?? json['subject_id'] ?? 0,
      teacherId: json['profesor_id'] != null
          ? (json['profesor_id'] is int
              ? json['profesor_id']
              : int.tryParse(json['profesor_id'].toString()) ?? 0)
          : (json['teacher_id'] != null
              ? (json['teacher_id'] is int
                  ? json['teacher_id']
                  : int.tryParse(json['teacher_id'].toString()) ?? 0)
              : 0), // Se asignará desde el servicio si es 0
      academicYear: json['año_academico']?.toString() ??
          json['academic_year']?.toString() ??
          DateTime.now().year.toString(),
      startDate: DateTime.parse(json['fecha_inicio'] ?? json['start_date']),
      endDate: DateTime.parse(json['fecha_fin'] ?? json['end_date']),
      classDays: classDays,
      classTime: json['hora_clase'] ?? json['class_time'],
      attendanceGoal: json['meta_asistencia'] != null
          ? (json['meta_asistencia'] is int
              ? json['meta_asistencia']
              : (json['meta_asistencia'] is double
                  ? json['meta_asistencia'].toInt()
                  : double.tryParse(json['meta_asistencia'].toString())
                          ?.toInt() ??
                      80))
          : (json['attendance_goal'] != null
              ? (json['attendance_goal'] is int
                  ? json['attendance_goal']
                  : (json['attendance_goal'] is double
                      ? json['attendance_goal'].toInt()
                      : double.tryParse(json['attendance_goal'].toString())
                              ?.toInt() ??
                          80))
              : 80),
      createdAt: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'academic_year': academicYear,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'class_days': classDays,
      'class_time': classTime,
      'attendance_goal': attendanceGoal,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
