class Student {
  final int userId;
  final int studentId;
  final String email;
  final String rol;
  final String userEstado;
  final String nombre;
  final String apellido;
  final String grado;
  final String seccion;
  final String telefono;
  final String direccion;
  final DateTime fechaNacimiento;
  final String estudianteEstado;
  final String fechaCreacion;

  Student({
    required this.userId,
    required this.studentId,
    required this.email,
    required this.rol,
    required this.userEstado,
    required this.nombre,
    required this.apellido,
    required this.grado,
    required this.seccion,
    required this.telefono,
    required this.direccion,
    required this.fechaNacimiento,
    required this.estudianteEstado,
    required this.fechaCreacion,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['user_id'] ?? 0,
      studentId: json['estudiante_id'] ?? 0,
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
      userEstado: json['user_estado'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      grado: json['grado'] ?? '',
      seccion: json['seccion'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento']) 
          : DateTime.now(),
      estudianteEstado: json['estudiante_estado'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'estudiante_id': studentId,
      'email': email,
      'rol': rol,
      'user_estado': userEstado,
      'nombre': nombre,
      'apellido': apellido,
      'grado': grado,
      'seccion': seccion,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'estudiante_estado': estudianteEstado,
      'fecha_creacion': fechaCreacion,
    };
  }

  String get fullName => '$nombre $apellido';
  
  // Propiedades de compatibilidad
  int get id => studentId;
  String get name => nombre;
  String get firstName => nombre;
  String get lastName => apellido;
  String get grade => grado;
  String get section => seccion;
  String? get phone => telefono;
  String? get address => direccion;
  DateTime? get birthDate => fechaNacimiento;
  String get status => estudianteEstado;
  
  // Calcular edad
  int get age {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month || 
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }
}