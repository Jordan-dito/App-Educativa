class Student {
  int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final String grade;
  final String section;
  final String guardianName;
  final String guardianPhone;
  final DateTime? enrollmentDate;
  final bool isActive;

  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.grade,
    required this.section,
    required this.guardianName,
    required this.guardianPhone,
    this.enrollmentDate,
    this.isActive = true,
  });

  // Convertir de Map a Student
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : DateTime.now(),
      grade: map['grade'] ?? '',
      section: map['section'] ?? '',
      guardianName: map['guardianName'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      enrollmentDate: map['enrollmentDate'] != null 
          ? DateTime.parse(map['enrollmentDate']) 
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  // Convertir de Student a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'grade': grade,
      'section': section,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'enrollmentDate': enrollmentDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Nombre completo
  String get fullName => '$firstName $lastName';

  // Edad calculada
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Copia con modificaciones
  Student copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? grade,
    String? section,
    String? guardianName,
    String? guardianPhone,
    DateTime? enrollmentDate,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, fullName: $fullName, grade: $grade, section: $section}';
  }
}