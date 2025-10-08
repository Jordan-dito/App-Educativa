# 🚀 Configuración de la API para Flutter

## ✅ Configuración Completada (Simplificada sin Providers)

Tu proyecto Flutter ya está configurado para consumir la API de manera simple y directa. Aquí está el resumen de lo que se ha implementado:

### 📁 Estructura de Archivos Creados

```
lib/
├── config/
│   └── api_config.dart          # Configuración de la API
├── models/
│   ├── user.dart               # Modelo de usuario
│   └── api_response.dart       # Modelo de respuesta de API
├── services/
│   └── auth_service.dart       # Servicio de autenticación
└── screens/
    ├── login_screen.dart       # Pantalla de login (actualizada)
    └── test_connection_screen.dart # Pantalla de prueba de conexión
```

### 🔧 Dependencias Agregadas

- `http: ^1.1.0` - Para peticiones HTTP
- `shared_preferences: ^2.2.2` - Para almacenamiento local
- `email_validator: ^2.1.17` - Para validación de emails

### 🌐 Configuración de la API

**URL Base:** `http://10.0.2.2/controladores_api_flutter`

**Endpoints configurados:**
- Login: `/api/auth.php?action=login`
- Registro: `/api/auth.php?action=register`
- Perfil: `/api/auth.php?action=profile`
- Test: `/api/test.php`

### 📱 Características Implementadas

1. **Autenticación completa** con login directo a la API
2. **Persistencia de sesión** usando SharedPreferences
3. **Manejo de errores** y estados de carga
4. **Validación de formularios** con email_validator
5. **Arquitectura simple** sin providers complejos

### 🚀 Cómo Usar

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Configurar tu servidor:**
   - Asegúrate de que tu servidor XAMPP esté corriendo
   - Coloca tus archivos PHP en la carpeta `controladores_api_flutter`
   - La URL `10.0.2.2` es para el emulador de Android

3. **Para dispositivo físico:**
   - Cambia la URL en `lib/config/api_config.dart` por la IP de tu computadora
   - Ejemplo: `http://192.168.1.100/controladores_api_flutter`

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

### 🧪 Probar la Conexión

Puedes usar la pantalla de prueba de conexión para verificar que la API funciona:

```dart
// Navegar a la pantalla de prueba
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TestConnectionScreen()),
);
```

### 📝 Credenciales de Prueba

La pantalla de login muestra estas credenciales por defecto:
- **Email:** admin@colegio.com
- **Contraseña:** admin

### 🔄 Flujo de la Aplicación

1. **Login Screen** → Pantalla principal de autenticación
2. **Dashboard Screen** → Después del login exitoso
3. **Persistencia** → El usuario se mantiene logueado usando SharedPreferences

### 🛠️ Personalización

Para cambiar la URL de la API, edita el archivo `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'TU_URL_AQUI';
```

### 📋 Próximos Pasos

1. Configura tu servidor XAMPP con los archivos PHP
2. Ajusta la URL base según tu configuración
3. Prueba la conexión con la pantalla de test
4. Implementa el registro de usuarios si es necesario

¡Tu aplicación Flutter está lista para consumir la API! 🎉
