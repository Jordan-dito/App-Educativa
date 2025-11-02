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

Para que esta aplicación funcione correctamente en cualquier máquina, se requieren las siguientes versiones:

### Versiones Requeridas

#### Flutter
- **Flutter SDK**: `>=3.0.0` (recomendado: última versión estable)
- **Dart SDK**: `>=3.0.0 <4.0.0` (viene incluido con Flutter)

#### Android Studio
- **Android Studio**: `Giraffe | 2022.3.1` o superior (recomendado: última versión estable)
- **Android Gradle Plugin**: `8.9.1` (se configura automáticamente)
- **Gradle**: `8.12` (se descarga automáticamente)

#### Java / JDK
- **Java JDK**: `17` (Java 17 LTS) - **Recomendado**
  - Puede ser OpenJDK 17, Oracle JDK 17, o Amazon Corretto 17
  - **Alternativa**: Java 21 LTS (también compatible, más reciente)
  - **Mínimo**: Java 11 (pero Java 17 o 21 es recomendado para mejor rendimiento)

#### Android SDK
- **compileSdk**: `35` (Android 15)
- **targetSdk**: `35` (Android 15)
- **minSdk**: `21` (Android 5.0 Lollipop)
- **NDK**: `27.0.12077973` (se configura automáticamente)

#### Kotlin
- **Kotlin**: `2.1.0` (se configura automáticamente)

### Compatibilidad de Dispositivos

- **Android**: Dispositivos con Android 5.0 (API 21) o superior
- **iOS**: No configurado en este proyecto (solo Android)

### Verificación de Instalación

Después de instalar todo, ejecuta:

```bash
flutter doctor
```

Este comando te mostrará qué componentes están instalados correctamente y cuáles faltan.

### Instalación Recomendada

1. **Instalar Flutter**:
   - Descarga Flutter desde: https://flutter.dev/docs/get-started/install
   - Descomprime y agrega Flutter a tu PATH
   - Ejecuta `flutter doctor` para verificar

2. **Instalar Android Studio**:
   - Descarga desde: https://developer.android.com/studio
   - Durante la instalación, asegúrate de instalar:
     - Android SDK
     - Android SDK Platform-Tools
     - Android SDK Build-Tools
     - Android Emulator (opcional)

3. **Instalar Java JDK 17 o 21** (recomendado):
   - **OpenJDK 17 LTS**: https://adoptium.net/temurin/releases/?version=17 (recomendado)
   - **OpenJDK 21 LTS**: https://adoptium.net/temurin/releases/?version=21 (más reciente)
   - **Oracle JDK 17**: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
   - Configura la variable de entorno `JAVA_HOME` apuntando a la instalación de Java 17 o 21
   - **Nota**: También funciona con Java 11, pero Java 17/21 es recomendado

4. **Configurar Variables de Entorno** (Windows):
   ```
   ANDROID_HOME = C:\Users\<tu_usuario>\AppData\Local\Android\Sdk
   JAVA_HOME = C:\Program Files\Java\jdk-17
   # O para Java 21:
   # JAVA_HOME = C:\Program Files\Java\jdk-21
   PATH = %PATH%;%FLUTTER_HOME%\bin;%ANDROID_HOME%\platform-tools;%JAVA_HOME%\bin
   ```

5. **Aceptar Licencias de Android**:
   ```bash
   flutter doctor --android-licenses
   ```

### Solución de Problemas

Si encuentras errores al compilar:

1. **Error de Java**: Verifica que `JAVA_HOME` apunte a Java 17 o 21 (recomendado). También funciona con Java 11, pero es mejor usar una versión más reciente
2. **Error de Android SDK**: Ejecuta `flutter doctor` y sigue las instrucciones
3. **Error de Gradle**: Asegúrate de tener conexión a internet para descargar Gradle automáticamente
4. **Versión de Flutter**: Ejecuta `flutter upgrade` para actualizar a la última versión

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