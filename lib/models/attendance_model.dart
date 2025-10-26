enum AttendanceStatus {
  present('presente'),
  absent('ausente'),
  late('tardanza'),
  justified('justificado');

  const AttendanceStatus(this.value);
  final String value;

  static AttendanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'presente':
        return AttendanceStatus.present;
      case 'ausente':
        return AttendanceStatus.absent;
      case 'tardanza':
        return AttendanceStatus.late;
      case 'justificado':
        return AttendanceStatus.justified;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class AttendanceRecord {
  final int? id;
  final int subjectConfigurationId;
  final int studentId;
  final DateTime classDate;
  final AttendanceStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceRecord({
    this.id,
    required this.subjectConfigurationId,
    required this.studentId,
    required this.classDate,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      subjectConfigurationId: json['subject_configuration_id'],
      studentId: json['student_id'],
      classDate: DateTime.parse(json['class_date']),
      status: AttendanceStatus.fromString(json['status']),
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_configuration_id': subjectConfigurationId,
      'student_id': studentId,
      'class_date': classDate.toIso8601String().split('T')[0],
      'status': status.value,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class StudentAttendanceSummary {
  final int studentId;
  final String studentName;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int justifiedCount;
  final double attendancePercentage;
  final bool meetsGoal;
  final int goalPercentage;

  StudentAttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.justifiedCount,
    required this.attendancePercentage,
    required this.meetsGoal,
    required this.goalPercentage,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      studentId: json['student_id'],
      studentName: json['student_name'],
      totalClasses: json['total_classes'],
      presentCount: json['present_count'],
      absentCount: json['absent_count'],
      lateCount: json['late_count'],
      justifiedCount: json['justified_count'],
      attendancePercentage: json['attendance_percentage'].toDouble(),
      meetsGoal: json['meets_goal'],
      goalPercentage: json['goal_percentage'],
    );
  }
}
