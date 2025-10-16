class Teacher {
  int? id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  DateTime birthDate;
  String specialization;
  String department;
  DateTime hireDate;
  double salary;
  bool isActive;
  String? emergencyContact;
  String? emergencyPhone;

  Teacher({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.specialization,
    required this.department,
    required this.hireDate,
    required this.salary,
    this.isActive = true,
    this.emergencyContact,
    this.emergencyPhone,
  });

  // Nombre completo
  String get fullName => '$firstName $lastName';

  // Edad calculada
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Años de experiencia
  int get yearsOfExperience {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    if (now.month < hireDate.month || 
        (now.month == hireDate.month && now.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  // Convertir desde Map (para SharedPreferences)
  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      birthDate: DateTime.parse(map['birthDate']),
      specialization: map['specialization'] ?? '',
      department: map['department'] ?? '',
      hireDate: DateTime.parse(map['hireDate']),
      salary: (map['salary'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
    );
  }

  // Convertir desde JSON (para API)
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['profesor_id'] ?? json['id'],
      firstName: json['nombre'] ?? json['firstName'] ?? '',
      lastName: json['apellido'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['telefono'] ?? json['phone'] ?? '',
      address: json['direccion'] ?? json['address'] ?? '',
      birthDate: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento'])
          : json['birthDate'] != null 
              ? DateTime.parse(json['birthDate'])
              : DateTime.now(),
      specialization: json['especializacion'] ?? json['specialization'] ?? 'Sin especialización',
      department: json['departamento'] ?? json['department'] ?? 'Sin departamento',
      hireDate: json['fecha_contratacion'] != null 
          ? DateTime.parse(json['fecha_contratacion'])
          : json['hireDate'] != null 
              ? DateTime.parse(json['hireDate'])
              : DateTime.now(),
      salary: (json['salario'] ?? json['salary'] ?? 0.0).toDouble(),
      isActive: json['profesor_estado'] == 'activo' || json['estado'] == 'activo' || json['isActive'] == true,
      emergencyContact: json['contacto_emergencia'] ?? json['emergencyContact'],
      emergencyPhone: json['telefono_emergencia'] ?? json['emergencyPhone'],
    );
  }

  // Convertir a Map (para SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'birthDate': birthDate.toIso8601String(),
      'specialization': specialization,
      'department': department,
      'hireDate': hireDate.toIso8601String(),
      'salary': salary,
      'isActive': isActive,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    };
  }

  // Crear copia con modificaciones
  Teacher copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? specialization,
    String? department,
    DateTime? hireDate,
    double? salary,
    bool? isActive,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    return Teacher(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      specialization: specialization ?? this.specialization,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }

  @override
  String toString() {
    return 'Teacher{id: $id, fullName: $fullName, email: $email, department: $department, specialization: $specialization}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Teacher && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}