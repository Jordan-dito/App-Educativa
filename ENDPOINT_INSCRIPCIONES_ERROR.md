# Error del Endpoint de Inscripciones

## 🚨 Problema Identificado

El endpoint de inscripciones está devolviendo un error PHP fatal:

```
Fatal error: Uncaught Error: Failed opening required '../controllers/InscripcionController.php' 
(include_path='.:') in /home/hermanosfrios/www/api/inscripciones.php:8
```

## 🔍 Análisis del Error

### **Causa Raíz:**
- El archivo `inscripciones.php` está intentando incluir `../controllers/InscripcionController.php`
- Este archivo no existe en el servidor
- El servidor devuelve HTML con errores PHP en lugar de JSON

### **Ubicación del Error:**
- **Archivo:** `/home/hermanosfrios/www/api/inscripciones.php`
- **Línea:** 8
- **Error:** `include '../controllers/InscripcionController.php'`

## 🛠️ Soluciones Requeridas

### **1. Crear el Controlador Faltante**

Crear el archivo `InscripcionController.php` en la ruta:
```
/home/hermanosfrios/www/controllers/InscripcionController.php
```

### **2. Estructura del Controlador**

El controlador debe manejar las siguientes acciones:

```php
<?php
class InscripcionController {
    
    // GET /api/inscripciones.php?action=all
    public function getAll() {
        // Obtener todas las inscripciones
    }
    
    // GET /api/inscripciones.php?action=by-estudiante&estudiante_id={id}
    public function getByStudent($studentId) {
        // Obtener inscripciones por estudiante
    }
    
    // GET /api/inscripciones.php?action=by-profesor&profesor_id={id}
    public function getByTeacher($teacherId) {
        // Obtener inscripciones por profesor
    }
    
    // POST /api/inscripciones.php?action=create
    public function create($data) {
        // Crear nueva inscripción
    }
    
    // DELETE /api/inscripciones.php?action=delete&id={id}
    public function delete($id) {
        // Eliminar inscripción
    }
    
    // PUT /api/inscripciones.php?action=update
    public function update($data) {
        // Actualizar inscripción
    }
}
```

### **3. Formato de Respuesta Esperado**

Todas las respuestas deben devolver JSON con esta estructura:

```json
{
    "success": true,
    "message": "Operación exitosa",
    "data": [
        {
            "id": 1,
            "estudiante_id": 123,
            "estudiante_nombre": "Juan Pérez",
            "estudiante_grado": "1°",
            "estudiante_seccion": "A",
            "materia_id": 456,
            "materia_nombre": "Matemáticas",
            "fecha_inscripcion": "2024-01-15",
            "estado": "activo",
            "profesor_id": 789,
            "profesor_nombre": "María García"
        }
    ]
}
```

## 🔧 Solución Temporal en Flutter

He implementado manejo de errores mejorado en la aplicación Flutter:

### **Detección de Errores del Servidor:**
```dart
// Verificar si la respuesta contiene errores HTML/PHP
if (response.body.contains('<b>Fatal error</b>') || 
    response.body.contains('<br />') ||
    response.body.contains('include_path')) {
  throw Exception('Error del servidor: El controlador de inscripciones no está disponible. Contacte al administrador.');
}
```

### **Manejo de FormatException:**
```dart
try {
  final Map<String, dynamic> jsonResponse = json.decode(response.body);
  // ... procesar respuesta
} catch (e) {
  if (e is FormatException) {
    throw Exception('Error del servidor: Respuesta no válida. El endpoint puede no estar configurado correctamente.');
  }
  rethrow;
}
```

## 📋 Checklist para el Administrador del Servidor

- [ ] Verificar que existe el directorio `/home/hermanosfrios/www/controllers/`
- [ ] Crear el archivo `InscripcionController.php` en el directorio controllers
- [ ] Implementar todos los métodos requeridos en el controlador
- [ ] Configurar la conexión a la base de datos
- [ ] Crear la tabla de inscripciones si no existe
- [ ] Probar todos los endpoints con Postman o similar
- [ ] Verificar que las respuestas sean JSON válido

## 🎯 Endpoints que Deben Funcionar

1. **GET** `/api/inscripciones.php?action=all`
2. **GET** `/api/inscripciones.php?action=by-estudiante&estudiante_id={id}`
3. **GET** `/api/inscripciones.php?action=by-profesor&profesor_id={id}`
4. **POST** `/api/inscripciones.php?action=create`
5. **DELETE** `/api/inscripciones.php?action=delete&id={id}`
6. **PUT** `/api/inscripciones.php?action=update`

## ⚠️ Nota Importante

**Este es un problema del backend, no de la aplicación Flutter.** La app Flutter está correctamente implementada y maneja los errores apropiadamente. El problema debe resolverse en el servidor creando el controlador faltante.
