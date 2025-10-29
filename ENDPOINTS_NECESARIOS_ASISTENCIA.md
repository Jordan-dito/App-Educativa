# 📋 ENDPOINTS NECESARIOS PARA ASISTENCIA

## ✅ Endpoint que YA EXISTE y funciona:
- `POST /api/asistencia.php?action=tomar` ✅ **Ya funciona**

---

## ❌ Endpoints que FALTAN (necesarios para que la app funcione):

### 1. **Verificar si existe asistencia**
```
GET /api/asistencia.php?action=verificar&materia_id=3&fecha_clase=2025-10-29
```

**¿Para qué sirve?**
- Cuando el profesor abre "Tomar Asistencia", la app verifica si ya hay asistencia guardada para esa materia y fecha

**Respuesta esperada:**
```json
{
  "success": true,
  "existe": true,
  "count": 2
}
```

**O si NO existe:**
```json
{
  "success": true,
  "existe": false,
  "count": 0
}
```

---

### 2. **Listar asistencias de una fecha**
```
GET /api/asistencia.php?action=listar&materia_id=3&fecha_clase=2025-10-29
```

**¿Para qué sirve?**
- Si ya existe asistencia, la app carga los estados guardados (presente/ausente/tardanza) de cada estudiante

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Asistencias obtenidas correctamente",
  "data": [
    {
      "estudiante_id": 15,
      "fecha_clase": "2025-10-29",
      "estado": "presente"
    },
    {
      "estudiante_id": 16,
      "fecha_clase": "2025-10-29",
      "estado": "presente"
    }
  ],
  "total": 2
}
```

---

## 📝 RESUMEN

**Endpoints necesarios en total:**
1. ✅ `POST /api/asistencia.php?action=tomar` - **YA EXISTE**
2. ❌ `GET /api/asistencia.php?action=verificar` - **FALTA**
3. ❌ `GET /api/asistencia.php?action=listar` - **FALTA**
4. ✅ `GET /api/asistencia.php?action=estudiantes_inscritos` - **YA EXISTE**

---

## 🔧 QUÉ PEDIR AL BACKEND

Puedes decirle al desarrollador del backend:

"Necesito agregar dos endpoints en `api/asistencia.php`:

1. **`action=verificar`**: 
   - Recibe: `materia_id` y `fecha_clase` por GET
   - Retorna: si existe asistencia para esa materia y fecha

2. **`action=listar`**: 
   - Recibe: `materia_id` y `fecha_clase` por GET  
   - Retorna: lista de asistencias guardadas para esa materia y fecha

Estos endpoints son necesarios para que la app Flutter pueda:
- Detectar si ya se tomó asistencia
- Cargar los estados guardados cuando el profesor vuelve a abrir la pantalla"

---

## 📊 CÓDIGO SQL DE REFERENCIA

Si quieren ver cómo hacer las consultas, pueden usar estas como referencia:

**Para verificar:**
```sql
SELECT COUNT(*) as total
FROM asistencia
WHERE materia_id = 3 AND fecha_clase = '2025-10-29';
```

**Para listar:**
```sql
SELECT 
    a.estudiante_id,
    a.fecha_clase,
    a.estado
FROM asistencia a
WHERE a.materia_id = 3 AND a.fecha_clase = '2025-10-29'
ORDER BY a.estudiante_id;
```

