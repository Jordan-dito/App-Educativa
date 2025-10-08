class Teacher {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String subject;
  final String? phone;
  final String? address;
  final DateTime? hireDate;
  final String status;
  final double? salary;

  Teacher({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.subject,
    this.phone,
    this.address,
    this.hireDate,
    this.status = 'active',
    this.salary,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      subject: json['subject'] ?? '',
      phone: json['phone'],
      address: json['address'],
      hireDate: json['hire_date'] != null 
          ? DateTime.parse(json['hire_date']) 
          : null,
      status: json['status'] ?? 'active',
      salary: json['salary']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'email': email,
      'subject': subject,
      'phone': phone,
      'address': address,
      'hire_date': hireDate?.toIso8601String(),
      'status': status,
      'salary': salary,
    };
  }

  String get fullName => '$name $lastName';
}