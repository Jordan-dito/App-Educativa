# Verificación Completa del Backend PHP

## ✅ Estado Actual:
- Material ID 15 existe en la base de datos
- `estudiante_id` = 16 ✅
- `materia_id` = 12 ✅
- `año_academico` = 2025 ✅
- `estado` = 'activo' ✅
- `fecha_vencimiento` = 2025-12-03 (corregida) ✅

## 🔍 Verificación del Backend PHP

### Paso 1: Probar la consulta SQL directamente

Ejecuta esta consulta en phpMyAdmin para confirmar que encuentra el material:

```sql
SELECT *
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12
  AND (estudiante_id = 16 OR estudiante_id IS NULL)
ORDER BY fecha_publicacion DESC;
```

**Si esta consulta retorna el material ID 15, entonces el problema está en el código PHP.**

---

### Paso 2: Verificar el endpoint PHP

Abre el archivo `reforzamiento.php` y busca la sección `if ($action === 'obtener_estudiante')`.

#### La consulta SQL debe ser exactamente así:

```php
$sql = "SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    descripcion,
    tipo_contenido,
    contenido,
    url_externa,
    fecha_publicacion,
    fecha_vencimiento,
    estado
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = ?
  AND (estudiante_id = ? OR estudiante_id IS NULL)";
```

**⚠️ CRÍTICO:** La condición `(estudiante_id = ? OR estudiante_id IS NULL)` DEBE tener paréntesis.

#### Si también filtra por materia_id (cuando se proporciona):

```php
if ($materia_id) {
    $sql .= " AND materia_id = ?";
    $params[] = intval($materia_id);
    $types .= "i";
}
```

#### El código completo debería verse así (con mysqli):

```php
if ($action === 'obtener_estudiante') {
    $estudiante_id = $_GET['estudiante_id'] ?? null;
    $materia_id = $_GET['materia_id'] ?? null;
    $año_academico = $_GET['año_academico'] ?? date('Y');
    
    if (!$estudiante_id) {
        echo json_encode(['success' => false, 'message' => 'estudiante_id requerido']);
        exit;
    }
    
    // Construir SQL base
    $sql = "SELECT 
        id,
        materia_id,
        estudiante_id,
        profesor_id,
        año_academico,
        titulo,
        descripcion,
        tipo_contenido,
        contenido,
        url_externa,
        fecha_publicacion,
        fecha_vencimiento,
        estado
    FROM material_reforzamiento
    WHERE estado = 'activo'
      AND año_academico = ?
      AND (estudiante_id = ? OR estudiante_id IS NULL)";
    
    $params = [$año_academico, $estudiante_id];
    $types = "si"; // string para año, integer para estudiante_id
    
    // Agregar filtro de materia si se proporciona
    if ($materia_id) {
        $sql .= " AND materia_id = ?";
        $params[] = intval($materia_id);
        $types .= "i";
    }
    
    $sql .= " ORDER BY fecha_publicacion DESC";
    
    // Preparar y ejecutar
    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $materiales = [];
    while ($row = $result->fetch_assoc()) {
        // Convertir año a string
        if (isset($row['año_academico'])) {
            $row['año_academico'] = (string)$row['año_academico'];
        }
        $materiales[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Material de reforzamiento obtenido correctamente',
        'data' => $materiales
    ]);
}
```

---

### Paso 3: Probar el endpoint directamente en el navegador

Abre esta URL en tu navegador:

```
https://hermanosfrios.alwaysdata.net/api/reforzamiento.php?action=obtener_estudiante&estudiante_id=16&año_academico=2025&materia_id=12
```

**Respuesta esperada:**
```json
{
    "success": true,
    "message": "Material de reforzamiento obtenido correctamente",
    "data": [
        {
            "id": "15",
            "materia_id": "12",
            "estudiante_id": "16",
            "profesor_id": "11",
            "año_academico": "2025",
            "titulo": "ewewewe",
            "descripcion": "eewewweew",
            "tipo_contenido": "texto",
            "contenido": "ewweweewew",
            "url_externa": null,
            "fecha_publicacion": "2025-11-03",
            "fecha_vencimiento": "2025-12-03",
            "estado": "activo"
        }
    ]
}
```

Si retorna `data: []`, entonces hay un problema en el código PHP.

---

### Paso 4: Verificar filtros adicionales

Revisa si el backend tiene algún filtro adicional que esté excluyendo el material, como:

```php
// ❌ MAL - Esto excluiría materiales vencidos
AND fecha_vencimiento >= CURDATE()

// ✅ BIEN - Permite materiales sin fecha de vencimiento O no vencidos
AND (fecha_vencimiento IS NULL OR fecha_vencimiento >= CURDATE())
```

O si tiene algún filtro de fecha de publicación:

```php
// Esto sería incorrecto si quieres ver materiales antiguos
AND fecha_publicacion >= CURDATE()
```

---

### Paso 5: Verificar tipos de datos

Asegúrate de que los parámetros se están pasando correctamente:

- `año_academico` debe ser string: `'2025'` no `2025` (aunque ambos funcionan en MySQL)
- `estudiante_id` debe ser integer: `16` no `'16'`
- `materia_id` debe ser integer: `12` no `'12'`

---

## Checklist de Verificación:

- [ ] La consulta SQL directa en phpMyAdmin retorna el material
- [ ] El código PHP tiene la condición `(estudiante_id = ? OR estudiante_id IS NULL)` con paréntesis
- [ ] No hay filtros adicionales que excluyan el material
- [ ] El endpoint retorna `data` con el material al probarlo en el navegador
- [ ] Los tipos de datos en `bind_param` son correctos (`si` o `sii`)

Si todos estos puntos están correctos y aún no funciona, revisa los logs del servidor PHP o agrega `error_log()` en el código para debug.

---

## 🐛 Debug adicional para PHP

Si después de verificar todo sigue sin funcionar, agrega este código de debug temporal en el PHP:

```php
// Al inicio del if ($action === 'obtener_estudiante')
error_log("DEBUG obtener_estudiante: estudiante_id=$estudiante_id, materia_id=$materia_id, año=$año_academico");

// Después de preparar la consulta
error_log("DEBUG SQL: " . $sql);
error_log("DEBUG Params: " . print_r($params, true));
error_log("DEBUG Types: " . $types);

// Después de ejecutar
if ($stmt->error) {
    error_log("ERROR SQL: " . $stmt->error);
}

// Después de obtener resultados
error_log("DEBUG Materiales encontrados: " . $result->num_rows);
```

Luego revisa los logs del servidor PHP para ver qué está pasando.

