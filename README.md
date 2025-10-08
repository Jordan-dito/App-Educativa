# Colegio App - Aplicación Móvil Flutter

Aplicación móvil desarrollada en Flutter para la gestión de un colegio, conectándose a un backend PHP mediante APIs REST.

## Características

- **Autenticación de usuarios** con login seguro
- **Gestión de estudiantes** (crear, leer, actualizar, eliminar)
- **Gestión de profesores** (crear, leer, actualizar, eliminar)
- **Búsqueda y filtrado** de estudiantes y profesores
- **Interfaz moderna y responsive** con Material Design
- **Manejo de estado** con Provider
- **Comunicación con API REST** en PHP

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user.dart
│   ├── student.dart
│   └── teacher.dart
├── services/                 # Servicios para comunicación con API
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── student_service.dart
│   └── teacher_service.dart
├── providers/                # Providers para manejo de estado
│   ├── auth_provider.dart
│   ├── student_provider.dart
│   └── teacher_provider.dart
└── screens/                  # Pantallas de la aplicación
    ├── login_screen.dart
    ├── home_screen.dart
    ├── students_screen.dart
    └── teachers_screen.dart
```

## Configuración

### 1. Configurar la URL del Backend

Edita el archivo `lib/services/api_service.dart` y cambia la URL base:

```dart
static const String baseUrl = 'http://tu-servidor.com/api'; // Cambiar por tu URL
```

### 2. Dependencias

Las principales dependencias incluidas son:

- `http`: Para peticiones HTTP
- `provider`: Para manejo de estado
- `shared_preferences`: Para almacenamiento local

### 3. Instalación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## API Backend Esperada

La aplicación espera que el backend PHP tenga los siguientes endpoints:

### Autenticación
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar usuario
- `POST /auth/logout` - Cerrar sesión
- `GET /auth/me` - Obtener usuario actual

### Estudiantes
- `GET /students` - Listar estudiantes
- `GET /students/{id}` - Obtener estudiante específico
- `POST /students` - Crear estudiante
- `PUT /students/{id}` - Actualizar estudiante
- `DELETE /students/{id}` - Eliminar estudiante
- `GET /students/search?q={query}` - Buscar estudiantes
- `GET /students/grade/{grade}` - Estudiantes por grado

### Profesores
- `GET /teachers` - Listar profesores
- `GET /teachers/{id}` - Obtener profesor específico
- `POST /teachers` - Crear profesor
- `PUT /teachers/{id}` - Actualizar profesor
- `DELETE /teachers/{id}` - Eliminar profesor
- `GET /teachers/search?q={query}` - Buscar profesores
- `GET /teachers/subject/{subject}` - Profesores por materia

## Formato de Respuesta Esperado

Todas las respuestas del API deben seguir este formato:

```json
{
  "success": true,
  "message": "Mensaje descriptivo",
  "data": {
    // Datos específicos del endpoint
  }
}
```

### Ejemplo de respuesta de login:
```json
{
  "success": true,
  "message": "Login exitoso",
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@colegio.com",
    "role": "admin"
  },
  "token": "jwt_token_aqui"
}
```

### Ejemplo de respuesta de estudiantes:
```json
{
  "success": true,
  "message": "Estudiantes obtenidos",
  "students": [
    {
      "id": 1,
      "name": "María",
      "last_name": "García",
      "email": "maria@email.com",
      "grade": "5°",
      "section": "A",
      "phone": "123456789",
      "address": "Calle 123",
      "birth_date": "2010-05-15",
      "status": "active"
    }
  ]
}
```

## Funcionalidades Implementadas

### Pantalla de Login
- Formulario de autenticación
- Validación de campos
- Manejo de errores
- Navegación automática al home

### Pantalla Principal (Home)
- Dashboard con información del usuario
- Módulos del sistema
- Menú de navegación
- Opción de logout

### Gestión de Estudiantes
- Lista de estudiantes con búsqueda
- Filtrado por grado
- Formulario para crear/editar
- Eliminación con confirmación
- Vista de detalles

### Gestión de Profesores
- Lista de profesores con búsqueda
- Filtrado por materia
- Formulario para crear/editar
- Eliminación con confirmación
- Vista de detalles

## Próximas Funcionalidades

- Módulo de calificaciones
- Gestión de horarios
- Sistema de reportes
- Notificaciones push
- Modo offline
- Exportación de datos

## Requisitos del Sistema

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Dispositivo Android 5.0+ o iOS 11.0+

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para más detalles.

## Soporte

Para soporte técnico o preguntas, contacta al equipo de desarrollo.

---

**Nota**: Asegúrate de configurar correctamente la URL del backend antes de ejecutar la aplicación.