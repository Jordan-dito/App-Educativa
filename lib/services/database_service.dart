import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';

  // Inicializar el servicio y crear usuario admin por defecto
  Future<void> initializeDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si ya existen usuarios
      final usersData = prefs.getString(_usersKey);
      if (usersData == null) {
        // Crear usuario admin por defecto
        await _createDefaultAdmin();
      }
    } catch (e) {
      debugPrint('Error inicializando base de datos: $e');
    }
  }

  // Crear usuario administrador por defecto
  Future<void> _createDefaultAdmin() async {
    try {
      final adminUser = User.createDefaultAdmin();
      await insertUser(adminUser);
      debugPrint('Usuario admin creado exitosamente');
    } catch (e) {
      debugPrint('Error creando usuario admin: $e');
    }
  }

  // Insertar un nuevo usuario
  Future<int> insertUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener usuarios existentes
      List<User> users = await getAllUsers();
      
      // Asignar ID único
       int newId = users.isEmpty ? 1 : users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      user.id = newId;
      
      // Agregar nuevo usuario
      users.add(user);
      
      // Guardar en SharedPreferences
      final usersJson = users.map((u) => u.toMap()).toList();
      await prefs.setString(_usersKey, jsonEncode(usersJson));
      
      return newId;
    } catch (e) {
      debugPrint('Error insertando usuario: $e');
      return -1;
    }
  }

  // Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersData = prefs.getString(_usersKey);
      
      if (usersData == null) {
        return [];
      }
      
      final List<dynamic> usersJson = jsonDecode(usersData);
      return usersJson.map((json) => User.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error obteniendo usuarios: $e');
      return [];
    }
  }

  // Autenticar usuario
  Future<User?> authenticateUser(String username, String password) async {
    try {
      final users = await getAllUsers();
      
      for (User user in users) {
        if (user.username == username && user.password == password) {
          // Guardar usuario actual
          await _saveCurrentUser(user);
          return user;
        }
      }
      
      return null; // Usuario no encontrado o credenciales incorrectas
    } catch (e) {
      debugPrint('Error autenticando usuario: $e');
      return null;
    }
  }

  // Guardar usuario actual en sesión
  Future<void> _saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
    } catch (e) {
      debugPrint('Error guardando usuario actual: $e');
    }
  }

  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_currentUserKey);
      
      if (userData == null) {
        return null;
      }
      
      final userJson = jsonDecode(userData);
      return User.fromMap(userJson);
    } catch (e) {
      debugPrint('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
    }
  }

  // Obtener usuario por ID
   Future<User?> getUserById(int id) async {
     try {
       final users = await getAllUsers();
       for (User user in users) {
         if (user.id == id) {
           return user;
         }
       }
       return null;
     } catch (e) {
       debugPrint('Error obteniendo usuario por ID: $e');
       return null;
     }
   }

  // Actualizar usuario
  Future<int> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<User> users = await getAllUsers();
      
      // Encontrar y actualizar usuario
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == user.id) {
          users[i] = user;
          break;
        }
      }
      
      // Guardar cambios
      final usersJson = users.map((u) => u.toMap()).toList();
      await prefs.setString(_usersKey, jsonEncode(usersJson));
      
      return 1; // Éxito
    } catch (e) {
      debugPrint('Error actualizando usuario: $e');
      return 0; // Error
    }
  }

  // Eliminar usuario
  Future<int> deleteUser(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<User> users = await getAllUsers();
      
      // Filtrar usuario a eliminar
      users.removeWhere((user) => user.id == id);
      
      // Guardar cambios
      final usersJson = users.map((u) => u.toMap()).toList();
      await prefs.setString(_usersKey, jsonEncode(usersJson));
      
      return 1; // Éxito
    } catch (e) {
      debugPrint('Error eliminando usuario: $e');
      return 0; // Error
    }
  }

  // Limpiar todos los datos (para testing)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_currentUserKey);
    } catch (e) {
      debugPrint('Error limpiando datos: $e');
    }
  }
}