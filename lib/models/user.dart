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
  final int? profesorId; // ID del profesor (user_data.id)

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
    this.profesorId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('DEBUG User.fromJson: Recibiendo JSON: $json');

    // Función helper para convertir ID a int de forma segura
    int? parseId(dynamic idValue) {
      if (idValue == null) return null;
      if (idValue is int) return idValue;
      if (idValue is String) {
        return int.tryParse(idValue);
      }
      return null;
    }

    // Función helper para convertir valores a String de forma segura
    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Manejar la nueva estructura de respuesta de la API
    if (json.containsKey('user_data')) {
      print('DEBUG User.fromJson: Usando estructura nueva con user_data');
      // Estructura nueva: {id, email, rol, user_data: {id, nombre, apellido}}
      final userData = json['user_data'] as Map<String, dynamic>;
      final user = User(
        id: parseId(json['id']),
        email: parseString(json['email']),
        rol: parseString(json['rol']),
        nombre: parseString(userData['nombre']),
        apellido: parseString(userData['apellido']),
        telefono: json['telefono'],
        direccion: json['direccion'],
        grado: json['grado'],
        seccion: json['seccion'],
        fechaNacimiento: json['fecha_nacimiento'],
        fechaContratacion: json['fecha_contratacion'],
        profesorId: parseId(userData['id']), // profesor_id viene en user_data.id
      );
      print(
          'DEBUG User.fromJson: Usuario creado con estructura nueva - Rol: ${user.rol}');
      return user;
    } else {
      print('DEBUG User.fromJson: Usando estructura antigua (campos directos)');
      // Estructura antigua: campos directos
      final user = User(
        id: parseId(json['user_id'] ?? json['id']),
        email: parseString(json['email']),
        rol: parseString(json['rol']),
        nombre: parseString(json['nombre']),
        apellido: parseString(json['apellido']),
        telefono: json['telefono'],
        direccion: json['direccion'],
        grado: json['grado'],
        seccion: json['seccion'],
        fechaNacimiento: json['fecha_nacimiento'],
        fechaContratacion: json['fecha_contratacion'],
      );
      print(
          'DEBUG User.fromJson: Usuario creado con estructura antigua - Rol: ${user.rol}');
      return user;
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
      'profesor_id': profesorId,
    };
  }
}
