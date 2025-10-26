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
    return SubjectConfiguration(
      id: json['id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      academicYear: json['academic_year'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      classDays: List<String>.from(json['class_days'] ?? []),
      classTime: json['class_time'],
      attendanceGoal: json['attendance_goal'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
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
