# 📝 ENDPOINT PHP PARA ASISTENCIA DE ESTUDIANTES

## 🎯 Endpoint necesario para que estudiantes vean su asistencia

Los estudiantes necesitan un endpoint que liste sus asistencias en una materia específica.

---

## ✅ ENDPOINT REQUERIDO

### `GET /api/asistencia.php?action=listar_estudiante`

**Parámetros:**
- `estudiante_id` (requerido): ID del estudiante
- `materia_id` (requerido): ID de la materia

**Ejemplo:**
```
GET /api/asistencia.php?action=listar_estudiante&estudiante_id=15&materia_id=3
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Asistencias del estudiante obtenidas correctamente",
  "data": [
    {
      "id": 10,
      "estudiante_id": 15,
      "materia_id": 3,
      "fecha_clase": "2025-10-29",
      "estado": "presente",
      "profesor_id": 7,
      "fecha_registro": "2025-10-29 18:24:37"
    },
    {
      "id": 11,
      "estudiante_id": 15,
      "materia_id": 3,
      "fecha_clase": "2025-10-28",
      "estado": "ausente",
      "profesor_id": 7,
      "fecha_registro": "2025-10-28 18:20:15"
    }
  ],
  "total": 2
}
```

---

## 📝 CÓDIGO PHP PARA AGREGAR

Agrega esto en tu `api/asistencia.php`:

```php
case 'listar_estudiante':
    header('Content-Type: application/json');
    
    try {
        // Obtener parámetros
        $estudiante_id = isset($_GET['estudiante_id']) ? intval($_GET['estudiante_id']) : 0;
        $materia_id = isset($_GET['materia_id']) ? intval($_GET['materia_id']) : 0;
        
        if ($estudiante_id <= 0 || $materia_id <= 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Parámetros incompletos. Se requiere estudiante_id y materia_id'
            ]);
            exit;
        }
        
        // Consultar asistencias del estudiante en la materia
        $stmt = $conn->prepare("
            SELECT 
                a.id,
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
            WHERE a.estudiante_id = ? AND a.materia_id = ?
            ORDER BY a.fecha_clase DESC
        ");
        $stmt->bind_param("ii", $estudiante_id, $materia_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $asistencias = [];
        while ($row = $result->fetch_assoc()) {
            $asistencias[] = [
                'id' => (int)$row['id'],
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
            'message' => 'Asistencias del estudiante obtenidas correctamente',
            'data' => $asistencias,
            'total' => count($asistencias),
            'estudiante_id' => $estudiante_id,
            'materia_id' => $materia_id
        ]);
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error al obtener asistencias del estudiante: ' . $e->getMessage()
        ]);
    }
    break;
```

---

## 📊 CONSULTA SQL DE REFERENCIA

Si quieres verificar manualmente:

```sql
SELECT 
    a.id,
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
WHERE a.estudiante_id = 15  -- ⚠️ Cambiar por el estudiante_id
  AND a.materia_id = 3      -- ⚠️ Cambiar por el materia_id
ORDER BY a.fecha_clase DESC;
```

---

## ✅ VERIFICACIÓN

Una vez agregado, prueba el endpoint:

```bash
curl "https://hermanosfrios.alwaysdata.net/api/asistencia.php?action=listar_estudiante&estudiante_id=15&materia_id=3"
```

Debería retornar todas las asistencias de ese estudiante en esa materia.

---

## 📋 RESUMEN

**Sí, los estudiantes ven su información correspondiente a sus materias:**

1. ✅ **Dinámico**: Obtiene `estudiante_id` del `usuario_id` del estudiante logueado
2. ✅ **Filtrado**: Solo muestra materias donde el estudiante está inscrito (activo)
3. ✅ **Asistencia**: Muestra solo las asistencias del estudiante en sus materias
4. ✅ **Individual**: Cada estudiante ve solo SU asistencia, no la de otros

**Falta agregar:**
- Endpoint `action=listar_estudiante` en `api/asistencia.php` para que funcione completamente

