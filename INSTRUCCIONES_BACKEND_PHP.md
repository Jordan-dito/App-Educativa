# Instrucciones para actualizar el backend PHP

## Problema
El archivo `reforzamiento.php` en el servidor todavía intenta insertar los campos de archivo (`archivo_nombre`, `archivo_ruta`, `archivo_tipo`, `archivo_tamaño`) que ya fueron eliminados de la base de datos.

## Solución

Necesitas actualizar el archivo `reforzamiento.php` en el servidor, específicamente la parte del `INSERT` cuando `action=subir`.

### Código PHP corregido (ejemplo)

El INSERT debe ser así (SIN los campos de archivo):

```php
<?php
// ... código de conexión y validación ...

if ($action === 'subir') {
    // Validar campos requeridos
    $materia_id = $_POST['materia_id'] ?? null;
    $profesor_id = $_POST['profesor_id'] ?? null;
    $titulo = $_POST['titulo'] ?? null;
    $tipo_contenido = $_POST['tipo_contenido'] ?? 'texto';
    $año_academico = $_POST['año_academico'] ?? date('Y');
    
    if (!$materia_id || !$profesor_id || !$titulo) {
        echo json_encode(['success' => false, 'message' => 'Campos requeridos faltantes']);
        exit;
    }
    
    // Preparar campos opcionales
    $estudiante_id = !empty($_POST['estudiante_id']) ? intval($_POST['estudiante_id']) : null;
    $descripcion = !empty($_POST['descripcion']) ? $_POST['descripcion'] : null;
    $contenido = !empty($_POST['contenido']) ? $_POST['contenido'] : null;
    $url_externa = !empty($_POST['url_externa']) ? $_POST['url_externa'] : null;
    $fecha_vencimiento = !empty($_POST['fecha_vencimiento']) ? $_POST['fecha_vencimiento'] : null;
    $fecha_publicacion = date('Y-m-d');
    
    // IMPORTANTE: NO incluir archivo_nombre, archivo_ruta, archivo_tipo, archivo_tamaño
    
    // Construir el INSERT sin campos de archivo
    $sql = "INSERT INTO material_reforzamiento (
        materia_id,
        " . ($estudiante_id ? "estudiante_id, " : "") . "
        profesor_id,
        año_academico,
        titulo,
        " . ($descripcion ? "descripcion, " : "") . "
        tipo_contenido,
        " . ($contenido ? "contenido, " : "") . "
        " . ($url_externa ? "url_externa, " : "") . "
        fecha_publicacion,
        " . ($fecha_vencimiento ? "fecha_vencimiento, " : "") . "
        estado
    ) VALUES (?, " . 
        ($estudiante_id ? "?, " : "") . 
        "?, ?, ?, " . 
        ($descripcion ? "?, " : "") . 
        "?, " . 
        ($contenido ? "?, " : "") . 
        ($url_externa ? "?, " : "") . 
        "?, " . 
        ($fecha_vencimiento ? "?, " : "") . 
        "'activo')";
    
    $params = [];
    $params[] = $materia_id;
    if ($estudiante_id) $params[] = $estudiante_id;
    $params[] = $profesor_id;
    $params[] = $año_academico;
    $params[] = $titulo;
    if ($descripcion) $params[] = $descripcion;
    $params[] = $tipo_contenido;
    if ($contenido) $params[] = $contenido;
    if ($url_externa) $params[] = $url_externa;
    $params[] = $fecha_publicacion;
    if ($fecha_vencimiento) $params[] = $fecha_vencimiento;
    
    $stmt = $conn->prepare($sql);
    $stmt->execute($params);
    
    if ($stmt) {
        echo json_encode([
            'success' => true,
            'message' => 'Material subido exitosamente',
            'id' => $conn->lastInsertId()
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Error al insertar material: ' . $conn->error
        ]);
    }
}
?>
```

### Versión más simple con mysqli

Si usas mysqli, sería así:

```php
// ... conexión ...

$estudiante_id = !empty($_POST['estudiante_id']) ? intval($_POST['estudiante_id']) : null;
$descripcion = !empty($_POST['descripcion']) ? $_POST['descripcion'] : null;
$contenido = !empty($_POST['contenido']) ? $_POST['contenido'] : null;
$url_externa = !empty($_POST['url_externa']) ? $_POST['url_externa'] : null;
$fecha_vencimiento = !empty($_POST['fecha_vencimiento']) ? $_POST['fecha_vencimiento'] : null;

$sql = "INSERT INTO material_reforzamiento 
    (materia_id, estudiante_id, profesor_id, año_academico, titulo, descripcion, tipo_contenido, contenido, url_externa, fecha_publicacion, fecha_vencimiento, estado) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), ?, 'activo')";

$stmt = $mysqli->prepare($sql);
$stmt->bind_param("iiissssssss",
    $_POST['materia_id'],
    $estudiante_id,
    $_POST['profesor_id'],
    $_POST['año_academico'],
    $_POST['titulo'],
    $descripcion,
    $_POST['tipo_contenido'],
    $contenido,
    $url_externa,
    $fecha_vencimiento
);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Material guardado']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $mysqli->error]);
}
```

## Campos que NO debes incluir en el INSERT:
- ❌ `archivo_nombre`
- ❌ `archivo_ruta`
- ❌ `archivo_tipo`
- ❌ `archivo_tamaño`

## Campos que SÍ debes incluir:
- ✅ `materia_id`
- ✅ `estudiante_id` (opcional, puede ser NULL)
- ✅ `profesor_id`
- ✅ `año_academico`
- ✅ `titulo`
- ✅ `descripcion` (opcional)
- ✅ `tipo_contenido` ('texto' o 'link')
- ✅ `contenido` (opcional, solo para tipo 'texto')
- ✅ `url_externa` (opcional, solo para tipo 'link')
- ✅ `fecha_publicacion`
- ✅ `fecha_vencimiento` (opcional)
- ✅ `estado` ('activo')

## Pasos a seguir:
1. Abre el archivo `reforzamiento.php` en tu servidor
2. Busca la sección donde está el `INSERT INTO material_reforzamiento`
3. Elimina cualquier referencia a los campos de archivo
4. Asegúrate de que el INSERT solo incluya los campos listados arriba
5. Guarda y prueba nuevamente

---

# ⚠️ PROBLEMA CRÍTICO: El endpoint obtener_estudiante no retorna materiales

## Problema detectado
El endpoint `action=obtener_estudiante` está retornando `data: []` (lista vacía) aunque hay materiales en la base de datos.

## Solución: Actualizar la consulta SELECT

El endpoint `obtener_estudiante` debe retornar:
1. Materiales específicos del estudiante (`estudiante_id = X`)
2. Materiales generales para todos los reprobados (`estudiante_id IS NULL`)

### Código PHP correcto para obtener_estudiante:

```php
<?php
// ... conexión y validación ...

if ($action === 'obtener_estudiante') {
    $estudiante_id = $_GET['estudiante_id'] ?? null;
    $materia_id = $_GET['materia_id'] ?? null;
    $año_academico = $_GET['año_academico'] ?? date('Y');
    
    if (!$estudiante_id) {
        echo json_encode(['success' => false, 'message' => 'estudiante_id requerido']);
        exit;
    }
    
    // Construir la consulta SQL
    // IMPORTANTE: Buscar materiales específicos del estudiante O materiales generales (NULL)
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
        estado,
        fecha_creacion,
        fecha_actualizacion
    FROM material_reforzamiento
    WHERE estado = 'activo'
      AND año_academico = ?
      AND (estudiante_id = ? OR estudiante_id IS NULL)";
    
    $params = [$año_academico, $estudiante_id];
    $types = "si"; // string (año) e integer (estudiante_id)
    
    // Si se proporciona materia_id, filtrar por materia
    if ($materia_id) {
        $sql .= " AND materia_id = ?";
        $params[] = intval($materia_id);
        $types .= "i";
    }
    
    // Ordenar por fecha de publicación (más recientes primero)
    $sql .= " ORDER BY fecha_publicacion DESC";
    
    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $materiales = [];
    while ($row = $result->fetch_assoc()) {
        // Convertir año_academico a string si es necesario
        if (isset($row['año_academico'])) {
            $row['año_academico'] = (string)$row['año_academico'];
        }
        
        // Formatear fechas si es necesario
        if ($row['fecha_publicacion']) {
            $row['fecha_publicacion'] = date('Y-m-d', strtotime($row['fecha_publicacion']));
        }
        if ($row['fecha_vencimiento']) {
            $row['fecha_vencimiento'] = date('Y-m-d', strtotime($row['fecha_vencimiento']));
        }
        
        $materiales[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Material de reforzamiento obtenido correctamente',
        'data' => $materiales,
        'reprobado' => true, // Puedes calcular esto si es necesario
        'promedio' => null   // Puedes incluir el promedio si lo necesitas
    ]);
}
?>
```

### Versión con PDO (si usas PDO):

```php
if ($action === 'obtener_estudiante') {
    $estudiante_id = $_GET['estudiante_id'] ?? null;
    $materia_id = $_GET['materia_id'] ?? null;
    $año_academico = $_GET['año_academico'] ?? date('Y');
    
    if (!$estudiante_id) {
        echo json_encode(['success' => false, 'message' => 'estudiante_id requerido']);
        exit;
    }
    
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
      AND año_academico = :anio_academico
      AND (estudiante_id = :estudiante_id OR estudiante_id IS NULL)";
    
    if ($materia_id) {
        $sql .= " AND materia_id = :materia_id";
    }
    
    $sql .= " ORDER BY fecha_publicacion DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':anio_academico', $año_academico, PDO::PARAM_STR);
    $stmt->bindValue(':estudiante_id', $estudiante_id, PDO::PARAM_INT);
    
    if ($materia_id) {
        $stmt->bindValue(':materia_id', $materia_id, PDO::PARAM_INT);
    }
    
    $stmt->execute();
    $materiales = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Material de reforzamiento obtenido correctamente',
        'data' => $materiales
    ]);
}
```

## Puntos críticos de la consulta:

1. **Condición OR para estudiante_id:**
   ```sql
   AND (estudiante_id = ? OR estudiante_id IS NULL)
   ```
   Esto retorna tanto materiales específicos como generales.

2. **Filtro por estado:**
   ```sql
   WHERE estado = 'activo'
   ```
   Solo materiales activos.

3. **Filtro por año académico:**
   ```sql
   AND año_academico = ?
   ```

4. **Filtro opcional por materia:**
   ```sql
   AND materia_id = ?  -- Solo si se proporciona
   ```

## Verificación

Después de actualizar, prueba la URL directamente:
```
https://hermanosfrios.alwaysdata.net/api/reforzamiento.php?action=obtener_estudiante&estudiante_id=16&año_academico=2025&materia_id=12
```

Debería retornar materiales si existen en la base de datos para ese estudiante y materia (específicos o generales).

---

## 🔍 Diagnóstico: ¿Por qué data está vacío?

Si después de actualizar el código sigue retornando `data: []`, ejecuta las siguientes consultas SQL para diagnosticar:

### 1. Verificar que los materiales existen:

```sql
-- Ver todos los materiales recientes
SELECT id, materia_id, estudiante_id, año_academico, titulo, estado, fecha_creacion
FROM material_reforzamiento
WHERE materia_id IN (3, 12)  -- IDs de las materias reprobadas
ORDER BY fecha_creacion DESC;
```

### 2. Verificar materiales específicos para el estudiante:

```sql
-- Materiales que DEBERÍA ver el estudiante 16
SELECT id, materia_id, estudiante_id, año_academico, titulo, tipo_contenido, estado
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12  -- o 3 para programación
  AND (estudiante_id = 16 OR estudiante_id IS NULL);
```

### Posibles causas del problema:

1. **Año académico diferente:**
   - Verifica que `año_academico` en los materiales sea `'2025'`
   - Si se guardó como `2024` o otro año, no aparecerá

2. **Estado inactivo:**
   - Verifica que los materiales tengan `estado = 'activo'`
   - Si están como `'inactivo'`, no aparecerán

3. **Estudiante_id incorrecto:**
   - Si el material se guardó para otro estudiante (no NULL y no 16), no aparecerá
   - Verifica con: `SELECT estudiante_id FROM material_reforzamiento WHERE id = ?`

4. **Materia_id incorrecta:**
   - Verifica que `materia_id` coincida con la materia reprobada

5. **La consulta SQL no está usando OR correctamente:**
   - Asegúrate de que la condición sea: `(estudiante_id = ? OR estudiante_id IS NULL)`
   - NO debe ser: `estudiante_id = ? OR estudiante_id IS NULL` (sin paréntesis)

### Ejemplo de consulta de prueba directa en MySQL:

```sql
-- Esta consulta debería retornar resultados si hay materiales
SELECT *
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12
  AND (estudiante_id = 16 OR estudiante_id IS NULL);
```

Si esta consulta retorna resultados pero el endpoint PHP no, entonces el problema está en el código PHP.

---

## ⚠️ PROBLEMA CRÍTICO: Fecha de vencimiento incorrecta

### Síntoma detectado:
El material tiene `fecha_vencimiento` (2025-10-31) **ANTES** de `fecha_publicacion` (2025-11-03).

Esto significa que el material está vencido antes de ser publicado, y muchos backends filtran materiales vencidos.

### Solución rápida:

Ejecuta esta consulta SQL para corregir las fechas:

```sql
-- OPCIÓN 1: Eliminar fecha_vencimiento (material siempre visible)
UPDATE material_reforzamiento
SET fecha_vencimiento = NULL
WHERE fecha_vencimiento < fecha_publicacion
  AND estado = 'activo';

-- OPCIÓN 2: Corregir fecha_vencimiento (agregar 30 días desde publicación)
UPDATE material_reforzamiento
SET fecha_vencimiento = DATE_ADD(fecha_publicacion, INTERVAL 30 DAY)
WHERE fecha_vencimiento < fecha_publicacion
  AND estado = 'activo';
```

### Verificar si el backend filtra por fecha:

Si el backend PHP tiene un filtro como:
```php
AND (fecha_vencimiento IS NULL OR fecha_vencimiento >= CURDATE())
```

Entonces los materiales con `fecha_vencimiento` en el pasado NO aparecerán.

**Opciones:**
1. Corregir las fechas en la base de datos (usar el script `corregir_fecha_vencimiento.sql`)
2. O actualizar el backend para NO filtrar por fecha_vencimiento (si no lo necesitas)

### Consulta para verificar fechas incorrectas:

```sql
SELECT id, titulo, fecha_publicacion, fecha_vencimiento
FROM material_reforzamiento
WHERE fecha_vencimiento < fecha_publicacion
  AND estado = 'activo';
```

