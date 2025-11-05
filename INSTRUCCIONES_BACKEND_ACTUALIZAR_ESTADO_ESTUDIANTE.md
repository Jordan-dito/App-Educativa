# Instrucciones: Actualizar Estado de Estudiante (activo/inactivo)

## Problema
Cuando el frontend intenta cambiar el estado de un estudiante de "inactivo" a "activo" (reactivar), el backend retorna error 500.

## Endpoint afectado
`action=edit-student` en `auth.php` (método PUT)

## Cambios necesarios

### 1. Aceptar el campo `estado` en el body de la petición

El frontend envía el siguiente JSON en el body de la petición PUT:

```json
{
  "estudiante_id": 25,
  "nombre": "yessi",
  "apellido": "chali",
  "grado": "3°",
  "seccion": "A",
  "telefono": "12345678",
  "direccion": "antigua",
  "fecha_nacimiento": "2015-11-06",
  "estado": "activo"  // ← Este campo es el que falta procesar
}
```

### 2. Actualizar el código en `auth.php`

En el bloque `if ($action === 'edit-student')`, asegúrate de:

1. **Leer el campo `estado` del body:**
   ```php
   $estado = $_POST['estado'] ?? $_PUT['estado'] ?? null;
   // O si usas json_decode:
   $data = json_decode(file_get_contents('php://input'), true);
   $estado = $data['estado'] ?? null;
   ```

2. **Actualizar tanto la tabla `estudiantes` como `usuarios` si es necesario:**

   ```php
   if ($action === 'edit-student') {
       // Obtener datos del body (PUT request)
       $input = json_decode(file_get_contents('php://input'), true);
       
       $estudiante_id = $input['estudiante_id'] ?? null;
       $nombre = $input['nombre'] ?? null;
       $apellido = $input['apellido'] ?? null;
       $grado = $input['grado'] ?? null;
       $seccion = $input['seccion'] ?? null;
       $telefono = $input['telefono'] ?? '';
       $direccion = $input['direccion'] ?? '';
       $fecha_nacimiento = $input['fecha_nacimiento'] ?? null;
       $estado = $input['estado'] ?? null; // ← NUEVO CAMPO
       
       if (!$estudiante_id) {
           echo json_encode([
               'success' => false,
               'message' => 'estudiante_id es requerido'
           ]);
           exit;
       }
       
       // Actualizar tabla estudiantes
       $sql = "UPDATE estudiantes SET 
           nombre = ?,
           apellido = ?,
           grado = ?,
           seccion = ?,
           telefono = ?,
           direccion = ?,
           fecha_nacimiento = ?";
       
       $params = [$nombre, $apellido, $grado, $seccion, $telefono, $direccion, $fecha_nacimiento];
       $types = "sssssss";
       
       // Si se proporciona estado, actualizarlo
       if ($estado !== null) {
           $sql .= ", estado = ?";
           $params[] = $estado;
           $types .= "s";
       }
       
       $sql .= " WHERE id = ?";
       $params[] = $estudiante_id;
       $types .= "i";
       
       $stmt = $conn->prepare($sql);
       $stmt->bind_param($types, ...$params);
       
       if ($stmt->execute()) {
           // También actualizar el estado del usuario si es necesario
           // (opcional: si quieres que el estado del usuario coincida con el estudiante)
           if ($estado !== null) {
               // Obtener usuario_id del estudiante
               $sql_usuario = "SELECT usuario_id FROM estudiantes WHERE id = ?";
               $stmt_usuario = $conn->prepare($sql_usuario);
               $stmt_usuario->bind_param("i", $estudiante_id);
               $stmt_usuario->execute();
               $result_usuario = $stmt_usuario->get_result();
               if ($row = $result_usuario->fetch_assoc()) {
                   $usuario_id = $row['usuario_id'];
                   // Actualizar estado del usuario (opcional)
                   // $sql_update_usuario = "UPDATE usuarios SET estado = ? WHERE id = ?";
                   // $stmt_update = $conn->prepare($sql_update_usuario);
                   // $stmt_update->bind_param("si", $estado, $usuario_id);
                   // $stmt_update->execute();
               }
           }
           
           echo json_encode([
               'success' => true,
               'message' => 'Estudiante actualizado exitosamente'
           ]);
       } else {
           echo json_encode([
               'success' => false,
               'message' => 'Error al actualizar estudiante: ' . $conn->error
           ]);
       }
   }
   ```

### 3. Validar valores de estado

Asegúrate de que el estado solo acepte valores válidos:

```php
if ($estado !== null) {
    // Validar que el estado sea válido
    if (!in_array($estado, ['activo', 'inactivo'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Estado inválido. Debe ser "activo" o "inactivo"'
        ]);
        exit;
    }
}
```

## Valores esperados

- `estado`: `'activo'` o `'inactivo'` (string)

## Manejo de errores

Si ocurre un error, el backend debe retornar:

```json
{
  "success": false,
  "message": "Descripción clara del error"
}
```

## Prueba

Después de implementar, prueba con:

**URL:** `PUT https://hermanosfrios.alwaysdata.net/api/auth.php?action=edit-student`

**Body:**
```json
{
  "estudiante_id": 25,
  "nombre": "yessi",
  "apellido": "chali",
  "grado": "3°",
  "seccion": "A",
  "telefono": "12345678",
  "direccion": "antigua",
  "fecha_nacimiento": "2015-11-06",
  "estado": "activo"
}
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Estudiante actualizado exitosamente"
}
```

## Nota importante

El campo `estado` en el body debe actualizar el campo `estado` en la tabla `estudiantes` (no `usuarios`). El estado del estudiante es independiente del estado del usuario.

