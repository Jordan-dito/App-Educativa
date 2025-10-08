class User {
  final int? id;
  final String email;
  final String rol;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? direccion;

  // Campos específicos para estudiantes
  final String? grado;
  final String? seccion;
  final String? fechaNacimiento;

  // Campos específicos para profesores
  final String? fechaContratacion;

  User({
    this.id,
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.direccion,
    this.grado,
    this.seccion,
    this.fechaNacimiento,
    this.fechaContratacion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Manejar la nueva estructura de respuesta de la API
    if (json.containsKey('user_data')) {
      // Estructura nueva: {id, email, rol, user_data: {id, nombre, apellido}}
      final userData = json['user_data'] as Map<String, dynamic>;
      return User(
        id: json['id'],
        email: json['email'],
        rol: json['rol'],
        nombre: userData['nombre'] ?? '',
        apellido: userData['apellido'] ?? '',
        telefono: json['telefono'],
        direccion: json['direccion'],
        grado: json['grado'],
        seccion: json['seccion'],
        fechaNacimiento: json['fecha_nacimiento'],
        fechaContratacion: json['fecha_contratacion'],
      );
    } else {
      // Estructura antigua: campos directos
      return User(
        id: json['user_id'] ?? json['id'],
        email: json['email'],
        rol: json['rol'],
        nombre: json['nombre'],
        apellido: json['apellido'],
        telefono: json['telefono'],
        direccion: json['direccion'],
        grado: json['grado'],
        seccion: json['seccion'],
        fechaNacimiento: json['fecha_nacimiento'],
        fechaContratacion: json['fecha_contratacion'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'rol': rol,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'direccion': direccion,
      'grado': grado,
      'seccion': seccion,
      'fecha_nacimiento': fechaNacimiento,
      'fecha_contratacion': fechaContratacion,
    };
  }
}
