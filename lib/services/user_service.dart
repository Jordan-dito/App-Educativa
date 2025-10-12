import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _userKey = 'user';

  // Obtener usuario actual desde SharedPreferences
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      print('DEBUG: Datos de usuario en SharedPreferences: $userData');

      if (userData == null) {
        print('DEBUG: No hay datos de usuario en SharedPreferences');
        return null;
      }

      final Map<String, dynamic> userJson = jsonDecode(userData);
      print('DEBUG: JSON del usuario parseado: $userJson');

      final user = User.fromJson(userJson);
      print(
          'DEBUG: Usuario creado desde JSON - Email: ${user.email}, Rol: ${user.rol}');

      return user;
    } catch (e) {
      print('DEBUG: Error obteniendo usuario: $e');
      return null;
    }
  }

  // Verificar si el usuario actual puede crear estudiantes
  static Future<bool> canCreateStudents() async {
    final user = await getCurrentUser();
    if (user == null) {
      print('DEBUG: Usuario es null en canCreateStudents');
      return false;
    }

    print('DEBUG: Usuario encontrado - Email: ${user.email}, Rol: ${user.rol}');
    print('DEBUG: Rol en lowercase: ${user.rol.toLowerCase()}');

    // Normalizar el rol para hacer la comparación más flexible
    final normalizedRol = user.rol.toLowerCase().trim();

    // Solo administradores y profesores pueden crear estudiantes
    // Agregamos variaciones comunes del rol
    final canCreate = normalizedRol == 'administrador' ||
        normalizedRol == 'admin' ||
        normalizedRol == 'profesor' ||
        normalizedRol == 'teacher' ||
        normalizedRol == 'maestro';

    print('DEBUG: Rol normalizado: "$normalizedRol"');
    print('DEBUG: Puede crear estudiantes: $canCreate');
    return canCreate;
  }

  // Verificar si el usuario es administrador
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    return user.rol.toLowerCase() == 'administrador';
  }

  // Verificar si el usuario es profesor
  static Future<bool> isTeacher() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    return user.rol.toLowerCase() == 'profesor';
  }

  // Verificar si el usuario es estudiante
  static Future<bool> isStudent() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    return user.rol.toLowerCase() == 'estudiante';
  }

  // Guardar usuario en SharedPreferences
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
    } catch (e) {
      throw Exception('Error al guardar usuario: $e');
    }
  }

  // Eliminar usuario de SharedPreferences
  static Future<void> removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // Método de debug para verificar el estado completo del usuario
  static Future<Map<String, dynamic>> debugUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final user = await getCurrentUser();
      final canCreate = await canCreateStudents();

      return {
        'raw_user_data': userData,
        'parsed_user': user?.toJson(),
        'can_create_students': canCreate,
        'user_email': user?.email,
        'user_rol': user?.rol,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
