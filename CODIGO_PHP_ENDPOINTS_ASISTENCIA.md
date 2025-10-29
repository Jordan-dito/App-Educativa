# 📝 CÓDIGO PHP PARA ENDPOINTS DE ASISTENCIA

Estos son los endpoints que necesitas agregar o verificar en tu archivo `api/asistencia.php`.

---

## 🔍 ENDPOINT 1: Verificar si existe asistencia

**Acción:** `action=verificar`

```php
case 'verificar':
    header('Content-Type: application/json');
    
    try {
        // Obtener parámetros
        $materia_id = isset($_GET['materia_id']) ? intval($_GET['materia_id']) : 0;
        $fecha_clase = isset($_GET['fecha_clase']) ? $_GET['fecha_clase'] : '';
        
        if ($materia_id <= 0 || empty($fecha_clase)) {
            echo json_encode([
                'success' => false,
                'message' => 'Parámetros incompletos. Se requiere materia_id y fecha_clase'
            ]);
            exit;
        }
        
        // Validar formato de fecha
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fecha_clase)) {
            echo json_encode([
                'success' => false,
                'message' => 'Formato de fecha inválido. Use YYYY-MM-DD'
            ]);
            exit;
        }
        
        // Consultar si existe asistencia
        $stmt = $conn->prepare("
            SELECT COUNT(*) as total
            FROM asistencia
            WHERE materia_id = ? AND fecha_clase = ?
        ");
        $stmt->bind_param("is", $materia_id, $fecha_clase);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        
        $existe = $row['total'] > 0;
        
        echo json_encode([
            'success' => true,
            'existe' => $existe,
            'count' => (int)$row['total'],
            'materia_id' => $materia_id,
            'fecha_clase' => $fecha_clase
        ]);
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error al verificar asistencia: ' . $e->getMessage()
        ]);
    }
    break;
```

---

## 📋 ENDPOINT 2: Listar asistencias de una fecha

**Acción:** `action=listar`

```php
case 'listar':
    header('Content-Type: application/json');
    
    try {
        // Obtener parámetros
        $materia_id = isset($_GET['materia_id']) ? intval($_GET['materia_id']) : 0;
        $fecha_clase = isset($_GET['fecha_clase']) ? $_GET['fecha_clase'] : '';
        
        if ($materia_id <= 0 || empty($fecha_clase)) {
            echo json_encode([
                'success' => false,
                'message' => 'Parámetros incompletos. Se requiere materia_id y fecha_clase'
            ]);
            exit;
        }
        
        // Validar formato de fecha
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fecha_clase)) {
            echo json_encode([
                'success' => false,
                'message' => 'Formato de fecha inválido. Use YYYY-MM-DD'
            ]);
            exit;
        }
        
        // Consultar asistencias
        $stmt = $conn->prepare("
            SELECT 
                a.id as asistencia_id,
                a.materia_id,
                a.estudiante_id,
                a.fecha_clase,
                a.estado,
                a.profesor_id,
                a.fecha_registro,
                CONCAT(e.nombre, ' ', e.apellido) as nombre_estudiante,
                m.nombre as nombre_materia
            FROM asistencia a
            INNER JOIN estudiantes e ON a.estudiante_id = e.id
            INNER JOIN materias m ON a.materia_id = m.id
            WHERE a.materia_id = ? AND a.fecha_clase = ?
            ORDER BY e.nombre ASC
        ");
        $stmt->bind_param("is", $materia_id, $fecha_clase);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $asistencias = [];
        while ($row = $result->fetch_assoc()) {
            $asistencias[] = [
                'asistencia_id' => (int)$row['asistencia_id'],
                'materia_id' => (int)$row['materia_id'],
                'estudiante_id' => (int)$row['estudiante_id'],
                'fecha_clase' => $row['fecha_clase'],
                'estado' => $row['estado'],
                'profesor_id' => (int)$row['profesor_id'],
                'fecha_registro' => $row['fecha_registro'],
                'nombre_estudiante' => $row['nombre_estudiante'],
                'nombre_materia' => $row['nombre_materia']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Asistencias obtenidas correctamente',
            'data' => $asistencias,
            'total' => count($asistencias),
            'materia_id' => $materia_id,
            'fecha_clase' => $fecha_clase
        ]);
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error al obtener asistencias: ' . $e->getMessage()
        ]);
    }
    break;
```

---

## 📋 ENDPOINT 3: Listar TODAS las asistencias (sin filtros)

**Acción:** `action=listar_todas` (opcional, para debugging)

```php
case 'listar_todas':
    header('Content-Type: application/json');
    
    try {
        // Consultar todas las asistencias
        $stmt = $conn->prepare("
            SELECT 
                a.id as asistencia_id,
                a.materia_id,
                a.estudiante_id,
                a.fecha_clase,
                a.estado,
                a.profesor_id,
                a.fecha_registro,
                CONCAT(e.nombre, ' ', e.apellido) as nombre_estudiante,
                m.nombre as nombre_materia,
                CONCAT(p.nombre, ' ', p.apellido) as nombre_profesor
            FROM asistencia a
            INNER JOIN estudiantes e ON a.estudiante_id = e.id
            INNER JOIN materias m ON a.materia_id = m.id
            INNER JOIN profesores p ON a.profesor_id = p.id
            ORDER BY a.fecha_clase DESC, a.fecha_registro DESC
            LIMIT 100
        ");
        $stmt->execute();
        $result = $stmt->get_result();
        
        $asistencias = [];
        while ($row = $result->fetch_assoc()) {
            $asistencias[] = [
                'asistencia_id' => (int)$row['asistencia_id'],
                'materia_id' => (int)$row['materia_id'],
                'estudiante_id' => (int)$row['estudiante_id'],
                'fecha_clase' => $row['fecha_clase'],
                'estado' => $row['estado'],
                'profesor_id' => (int)$row['profesor_id'],
                'fecha_registro' => $row['fecha_registro'],
                'nombre_estudiante' => $row['nombre_estudiante'],
                'nombre_materia' => $row['nombre_materia'],
                'nombre_profesor' => $row['nombre_profesor']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Asistencias obtenidas correctamente',
            'data' => $asistencias,
            'total' => count($asistencias)
        ]);
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error al obtener asistencias: ' . $e->getMessage()
        ]);
    }
    break;
```

---

## 🔗 ESTRUCTURA COMPLETA DEL ARCHIVO

Tu archivo `api/asistencia.php` debería tener una estructura similar a esta:

```php
<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php'; // Ajusta la ruta según tu estructura

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'tomar':
        // Tu código existente para guardar asistencia
        break;
        
    case 'estudiantes_inscritos':
        // Tu código existente para obtener estudiantes
        break;
        
    case 'verificar':
        // Código nuevo - ver arriba
        break;
        
    case 'listar':
        // Código nuevo - ver arriba
        break;
        
    case 'listar_todas':
        // Código opcional - ver arriba
        break;
        
    default:
        echo json_encode([
            'success' => false,
            'message' => 'Acción no especificada o inválida'
        ]);
        break;
}
?>
```

---

## ✅ PRUEBAS

### Prueba 1: Verificar asistencia
```bash
curl "https://hermanosfrios.alwaysdata.net/api/asistencia.php?action=verificar&materia_id=3&fecha_clase=2025-10-29"
```

Respuesta esperada:
```json
{
  "success": true,
  "existe": true,
  "count": 2,
  "materia_id": 3,
  "fecha_clase": "2025-10-29"
}
```

### Prueba 2: Listar asistencias
```bash
curl "https://hermanosfrios.alwaysdata.net/api/asistencia.php?action=listar&materia_id=3&fecha_clase=2025-10-29"
```

Respuesta esperada:
```json
{
  "success": true,
  "message": "Asistencias obtenidas correctamente",
  "data": [
    {
      "asistencia_id": 4,
      "materia_id": 3,
      "estudiante_id": 15,
      "fecha_clase": "2025-10-29",
      "estado": "presente",
      "profesor_id": 7,
      "fecha_registro": "2025-10-29 17:56:25",
      "nombre_estudiante": "fabricio chali",
      "nombre_materia": "programación"
    },
    {
      "asistencia_id": 5,
      "materia_id": 3,
      "estudiante_id": 16,
      "fecha_clase": "2025-10-29",
      "estado": "presente",
      "profesor_id": 7,
      "fecha_registro": "2025-10-29 17:56:25",
      "nombre_estudiante": "sostenes chali",
      "nombre_materia": "programación"
    }
  ],
  "total": 2,
  "materia_id": 3,
  "fecha_clase": "2025-10-29"
}
```

---

## 📝 NOTAS IMPORTANTES

1. **Validación de parámetros**: Ambos endpoints validan que `materia_id` y `fecha_clase` estén presentes.
2. **Formato de fecha**: Se valida que la fecha tenga el formato `YYYY-MM-DD`.
3. **Prevención SQL Injection**: Se usan prepared statements con `bind_param`.
4. **Manejo de errores**: Los endpoints devuelven respuestas JSON consistentes con `success` y `message`.

---

## 🐛 DEBUGGING

Si algo no funciona, verifica:

1. **Conexión a la base de datos**: Asegúrate de que `require_once '../config/database.php'` esté configurado correctamente.
2. **Nombres de tablas**: Verifica que las tablas `asistencia`, `estudiantes`, `materias`, y `profesores` existan.
3. **Permisos**: Asegúrate de que el usuario de la base de datos tenga permisos SELECT en estas tablas.
4. **Logs**: Revisa los logs del servidor PHP para ver errores específicos.

