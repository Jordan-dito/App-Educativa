class Student {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String grade;
  final String section;
  final String? phone;
  final String? address;
  final DateTime? birthDate;
  final String status;

  Student({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.grade,
    required this.section,
    this.phone,
    this.address,
    this.birthDate,
    this.status = 'active',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      grade: json['grade'] ?? '',
      section: json['section'] ?? '',
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'email': email,
      'grade': grade,
      'section': section,
      'phone': phone,
      'address': address,
      'birth_date': birthDate?.toIso8601String(),
      'status': status,
    };
  }

  String get fullName => '$name $lastName';
}