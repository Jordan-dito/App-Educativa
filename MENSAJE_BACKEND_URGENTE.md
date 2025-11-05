# 🔴 URGENTE: Error "Estudiante no encontrado" al Reactivar

## Problema
Cuando se intenta reactivar un estudiante inactivo (cambiar estado de "inactivo" a "activo"), el backend retorna:
```json
{
  "success": false,
  "message": "Estudiante no encontrado"
}
```

## Causa Raíz
El backend está validando que el estudiante existe **ANTES** de actualizarlo, pero está filtrando solo estudiantes con `estado = 'activo'`. Como el estudiante está inactivo, no lo encuentra.

## 🔍 Dónde buscar el problema

Busca en el archivo `auth.php` en la sección `if ($action === 'edit-student')`:

### 1. Validación de existencia del estudiante

**❌ INCORRECTO - NO HACER ESTO:**
```php
// Esto falla si el estudiante está inactivo
$sql = "SELECT id FROM estudiantes WHERE id = ? AND estado = 'activo'";
$sql = "SELECT * FROM estudiantes WHERE id = ? AND estado = 'activo'";
$sql = "SELECT id FROM estudiantes e 
        INNER JOIN usuarios u ON e.usuario_id = u.id 
        WHERE e.id = ? AND e.estado = 'activo' AND u.estado = 'activo'";
```

**✅ CORRECTO - HACER ESTO:**
```php
// Buscar estudiante SIN filtrar por estado
$sql = "SELECT id FROM estudiantes WHERE id = ?";
```

### 2. Verificar TODAS las consultas SELECT antes del UPDATE

Busca cualquier consulta que valide la existencia del estudiante. Debe ser así:

```php
// ✅ CORRECTO
$sql_check = "SELECT id FROM estudiantes WHERE id = ?";
$stmt_check = $conn->prepare($sql_check);
$stmt_check->bind_param("i", $estudiante_id);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

if ($result_check->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Estudiante no encontrado']);
    exit;
}
```

## 🛠️ Solución Completa

Reemplaza TODA la sección `if ($action === 'edit-student')` con esto:

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
    
    // ⚠️ IMPORTANTE: Verificar existencia SIN filtrar por estado
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

## 📋 Checklist de Verificación

Antes de probar, verifica que:

- [ ] La consulta de validación NO tiene `AND estado = 'activo'`
- [ ] La consulta de validación NO tiene `AND u.estado = 'activo'` en un JOIN
- [ ] El campo `estado` se lee del body: `$estado = $input['estado'] ?? null;`
- [ ] El campo `estado` se agrega al UPDATE si se proporciona
- [ ] El estado se valida que sea 'activo' o 'inactivo'

## 🧪 Prueba Directa

Prueba con este estudiante inactivo:

**URL:** `PUT https://hermanosfrios.alwaysdata.net/api/auth.php?action=edit-student`

**Body:**
```json
{
  "estudiante_id": 23,
  "nombre": "prueba10",
  "apellido": "vbsgzxvbx",
  "grado": "3°",
  "seccion": "A",
  "telefono": "12345678",
  "direccion": "fdffddffd",
  "fecha_nacimiento": "2009-11-02",
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

## 🔍 Comandos SQL para Verificar

Ejecuta esto en MySQL para verificar que el estudiante existe:

```sql
-- Verificar que el estudiante existe (debe retornar 1 fila incluso si está inactivo)
SELECT id, nombre, apellido, estado 
FROM estudiantes 
WHERE id = 23;

-- Si el estudiante existe pero está inactivo, deberías ver:
-- id: 23, estado: 'inactivo'
```

## ⚠️ Si el problema persiste

1. Verifica los logs del servidor para ver el error exacto
2. Asegúrate de que la tabla `estudiantes` tiene el campo `estado`
3. Verifica que el `estudiante_id` que se envía coincide con un ID real en la base de datos

