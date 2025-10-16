class Subject {
  final String? id;
  final String name;
  final String grade; // 1°, 2°, 3°, etc.
  final String section; // A, B, C, D
  final String? teacherId;
  final String? teacherName;
  final String academicYear; // 2024, 2025, etc.
  final bool isActive;
  final DateTime createdAt;

  Subject({
    this.id,
    required this.name,
    required this.grade,
    required this.section,
    this.teacherId,
    this.teacherName,
    required this.academicYear,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Crear Subject desde Map (para SharedPreferences)
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'] ?? '',
      grade: map['grade'] ?? '',
      section: map['section'] ?? '',
      teacherId: map['teacherId'],
      teacherName: map['teacherName'],
      academicYear: map['academicYear'] ?? DateTime.now().year.toString(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  // Crear Subject desde JSON (para API)
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['materia_id']?.toString() ?? json['id']?.toString(),
      name: json['nombre'] ?? json['name'] ?? '',
      grade: json['grado'] ?? json['grade'] ?? '',
      section: json['seccion'] ?? json['section'] ?? '',
      teacherId: json['profesor_id']?.toString() ?? json['teacherId']?.toString(),
      teacherName: json['profesor_nombre'] != null && json['profesor_apellido'] != null 
          ? '${json['profesor_nombre']} ${json['profesor_apellido']}'
          : json['profesor_nombre'] ?? json['teacherName'],
      academicYear: json['año_academico']?.toString() ?? json['academicYear'] ?? DateTime.now().year.toString(),
      isActive: (json['estado'] ?? json['activo'] ?? json['isActive']) == 'activo' || 
                (json['estado'] ?? json['activo'] ?? json['isActive']) == 1 || 
                (json['estado'] ?? json['activo'] ?? json['isActive']) == true,
      createdAt: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : json['createdAt'] != null 
              ? DateTime.parse(json['createdAt']) 
              : DateTime.now(),
    );
  }

  // Convertir Subject a Map (para SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'section': section,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'academicYear': academicYear,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear copia con modificaciones
  Subject copyWith({
    String? id,
    String? name,
    String? grade,
    String? section,
    String? teacherId,
    String? teacherName,
    String? academicYear,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      academicYear: academicYear ?? this.academicYear,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Propiedades calculadas
  String get fullName => '$name - $grade $section';
  
  String get gradeSection => '$grade - $section';
  
  String get displayInfo => '$name ($grade $section) - $academicYear';

  // Validaciones
  bool get isValidGrade => grade.isNotEmpty;
  
  bool get isValidSection => section.isNotEmpty;
  
  bool get isValidAcademicYear => academicYear.isNotEmpty && int.tryParse(academicYear) != null;

  @override
  String toString() {
    return 'Subject{id: $id, name: $name, grade: $grade, section: $section}';
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