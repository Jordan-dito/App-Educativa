class Subject {
  final String? id;
  final String name;
  final String code;
  final String description;
  final String department;
  final int credits;
  final int hoursPerWeek;
  final String level; // Preescolar, Primaria, Secundaria
  final String grade; // 1°, 2°, 3°, etc.
  final String? teacherId;
  final String? teacherName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Subject({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.department,
    required this.credits,
    required this.hoursPerWeek,
    required this.level,
    required this.grade,
    this.teacherId,
    this.teacherName,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Crear Subject desde Map (para SharedPreferences)
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      credits: map['credits'] ?? 0,
      hoursPerWeek: map['hoursPerWeek'] ?? 0,
      level: map['level'] ?? '',
      grade: map['grade'] ?? '',
      teacherId: map['teacherId'],
      teacherName: map['teacherName'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  // Convertir Subject a Map (para SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'department': department,
      'credits': credits,
      'hoursPerWeek': hoursPerWeek,
      'level': level,
      'grade': grade,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Crear copia con modificaciones
  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? department,
    int? credits,
    int? hoursPerWeek,
    String? level,
    String? grade,
    String? teacherId,
    String? teacherName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      department: department ?? this.department,
      credits: credits ?? this.credits,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      level: level ?? this.level,
      grade: grade ?? this.grade,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Propiedades calculadas
  String get fullName => '$code - $name';
  
  String get levelGrade => '$level - $grade';
  
  String get workload => '$hoursPerWeek horas/semana - $credits créditos';

  // Validaciones
  bool get isValidCode => code.isNotEmpty && code.length >= 3;
  
  bool get isValidCredits => credits > 0 && credits <= 10;
  
  bool get isValidHours => hoursPerWeek > 0 && hoursPerWeek <= 40;

  @override
  String toString() {
    return 'Subject{id: $id, name: $name, code: $code, level: $level, grade: $grade}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Métodos estáticos para listas predefinidas
  static List<String> get departments => [
    'Matemáticas',
    'Ciencias',
    'Lenguaje',
    'Ciencias Sociales',
    'Educación Física',
    'Artes',
    'Inglés',
    'Tecnología',
    'Religión',
    'Preescolar'
  ];

  static List<String> get levels => [
    'Preescolar',
    'Primaria',
    'Secundaria'
  ];

  static Map<String, List<String>> get gradesByLevel => {
    'Preescolar': ['Jardín', 'Transición'],
    'Primaria': ['1°', '2°', '3°', '4°', '5°'],
    'Secundaria': ['6°', '7°', '8°', '9°', '10°', '11°'],
  };

  static List<String> getGradesForLevel(String level) {
    return gradesByLevel[level] ?? [];
  }
}