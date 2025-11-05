# Instrucciones: Error "Estudiante no encontrado" al Actualizar Estado

## Problema
Cuando se intenta reactivar un estudiante (cambiar de "inactivo" a "activo"), el backend retorna error 500 con el mensaje "Estudiante no encontrado".

## Causa
El backend probablemente está validando que el estudiante existe **antes** de actualizarlo, pero está filtrando solo estudiantes activos en esa validación. Cuando el estudiante está inactivo, no lo encuentra y retorna el error.

## Solución

### En el endpoint `action=edit-student`

**❌ INCORRECTO (solo busca activos):**
```php
// Esto falla si el estudiante está inactivo
$sql = "SELECT id FROM estudiantes WHERE id = ? AND estado = 'activo'";
```

**✅ CORRECTO (busca todos, sin filtrar por estado):**
```php
// Buscar estudiante sin filtrar por estado
$sql = "SELECT id FROM estudiantes WHERE id = ?";
```

### Código completo corregido

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
    $estado = $input['estado'] ?? null;
    
    if (!$estudiante_id) {
        echo json_encode([
            'success' => false,
            'message' => 'estudiante_id es requerido'
        ]);
        exit;
    }
    
    // IMPORTANTE: Verificar que el estudiante existe SIN filtrar por estado
    $sql_check = "SELECT id FROM estudiantes WHERE id = ?";
    $stmt_check = $conn->prepare($sql_check);
    $stmt_check->bind_param("i", $estudiante_id);
    $stmt_check->execute();
    $result_check = $stmt_check->get_result();
    
    if ($result_check->num_rows === 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Estudiante no encontrado'
        ]);
        exit;
    }
    
    // Construir UPDATE SQL
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
    
    // Agregar estado si se proporciona
    if ($estado !== null) {
        // Validar que el estado sea válido
        if (!in_array($estado, ['activo', 'inactivo'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Estado inválido. Debe ser "activo" o "inactivo"'
            ]);
            exit;
        }
        
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

## Puntos críticos

1. **No filtrar por estado en la validación inicial:**
   ```php
   // ❌ INCORRECTO
   WHERE id = ? AND estado = 'activo'
   
   // ✅ CORRECTO
   WHERE id = ?
   ```

2. **Validar que el estudiante existe antes de actualizar** (pero sin filtrar por estado)

3. **Aceptar el campo `estado` en el UPDATE** para poder cambiar de inactivo a activo

## Prueba

**URL:** `PUT https://hermanosfrios.alwaysdata.net/api/auth.php?action=edit-student`

**Body:**
```json
{
  "estudiante_id": 12,
  "nombre": "JORDAN",
  "apellido": "LAPO",
  "grado": "3°",
  "seccion": "A",
  "telefono": "12324515",
  "direccion": "saa",
  "fecha_nacimiento": "2000-10-29",
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

## Verificación

Después de actualizar, verifica que:
1. El estudiante con `estudiante_id: 12` existe en la base de datos (incluso si está inactivo)
2. La consulta `SELECT id FROM estudiantes WHERE id = 12` retorna 1 fila
3. El UPDATE se ejecuta correctamente y cambia el estado a "activo"

