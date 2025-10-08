class User {
  int? id;
  final String username;
  final String password;
  final String role;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.createdAt,
  });

  // Convertir de Map a User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
    );
  }

  // Convertir de User a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Método para crear usuario administrador por defecto
  static User createDefaultAdmin() {
    return User(
      username: 'admin',
      password: 'admin',
      role: 'administrator',
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role}';
  }
}