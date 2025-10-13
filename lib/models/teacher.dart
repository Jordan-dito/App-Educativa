class Teacher {
  final int userId;
  final int teacherId;
  final String email;
  final String rol;
  final String nombre;
  final String apellido;
  final String telefono;
  final String direccion;
  final DateTime fechaContratacion;
  final String teacherEstado;
  final String fechaCreacion;

  Teacher({
    required this.userId,
    required this.teacherId,
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.direccion,
    required this.fechaContratacion,
    required this.teacherEstado,
    required this.fechaCreacion,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      userId: json['user_id'] ?? 0,
      teacherId: json['profesor_id'] ?? 0,
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaContratacion: json['fecha_contratacion'] != null 
          ? DateTime.parse(json['fecha_contratacion']) 
          : DateTime.now(),
      teacherEstado: json['profesor_estado'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'profesor_id': teacherId,
      'email': email,
      'rol': rol,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_contratacion': fechaContratacion.toIso8601String(),
      'profesor_estado': teacherEstado,
      'fecha_creacion': fechaCreacion,
    };
  }

  String get fullName => '$nombre $apellido';
  
  // Propiedades de compatibilidad
  int get id => teacherId;
  String get firstName => nombre;
  String get lastName => apellido;
  String? get phone => telefono;
  String? get address => direccion;
  DateTime get hireDate => fechaContratacion;
  String get status => teacherEstado;
  bool get isActive => teacherEstado == 'activo';
  
  // Calcular años de experiencia
  int get yearsOfExperience {
    final now = DateTime.now();
    int years = now.year - fechaContratacion.year;
    if (now.month < fechaContratacion.month || 
        (now.month == fechaContratacion.month && now.day < fechaContratacion.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }
  
  // Calcular edad aproximada (asumiendo que la fecha de contratación es cuando tenía ~25 años)
  int get age {
    return 25 + yearsOfExperience;
  }
  
  // Propiedades por defecto para compatibilidad con el modelo viejo
  String get department => 'General'; // Por defecto, se puede expandir después
  String get specialization => 'General'; // Por defecto, se puede expandir después
  double get salary => 0.0; // Por defecto, se puede expandir después
}