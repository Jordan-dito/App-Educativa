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
        classDays = json['dias_clase'].split(',').map((e) => e.trim()).toList();
      } else if (json['dias_clase'] is List) {
        // Si viene como array
        classDays = List<String>.from(json['dias_clase']);
      }
    } else if (json['class_days'] != null) {
      classDays = List<String>.from(json['class_days']);
    }

    return SubjectConfiguration(
      id: json['id'] ?? json['configuracion_id'],
      subjectId: json['materia_id'] ?? json['subject_id'],
      teacherId: json['profesor_id'] ?? json['teacher_id'],
      academicYear: json['año_academico']?.toString() ?? json['academic_year']?.toString() ?? DateTime.now().year.toString(),
      startDate: DateTime.parse(json['fecha_inicio'] ?? json['start_date']),
      endDate: DateTime.parse(json['fecha_fin'] ?? json['end_date']),
      classDays: classDays,
      classTime: json['hora_clase'] ?? json['class_time'],
      attendanceGoal: json['meta_asistencia']?.toInt() ?? json['attendance_goal']?.toInt() ?? 80,
      createdAt: json['fecha_creacion'] != null ? DateTime.parse(json['fecha_creacion']) : 
                 json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['fecha_actualizacion'] != null ? DateTime.parse(json['fecha_actualizacion']) :
                 json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
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
