# 📋 LISTA DE ENDPOINTS USADOS EN FLUTTER

Este documento lista **TODOS** los endpoints que la app Flutter está intentando usar. Debes verificar cuáles existen en tu backend PHP y cuáles faltan.

---

## 🔐 AUTENTICACIÓN (`api/auth.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/api/auth.php` | POST | `?action=login` | ✅ Probablemente existe | `auth_service.dart` |
| `/api/auth.php` | POST | `?action=register` | ✅ Probablemente existe | `auth_service.dart` |
| `/api/auth.php` | GET | `?action=profile` | ❓ Verificar | `auth_service.dart` |
| `/api/auth.php` | GET | `?action=teachers` | ✅ Probablemente existe | `auth_service.dart`, `teacher_api_service.dart` |
| `/api/auth.php` | GET | `?action=students` | ✅ Probablemente existe | `auth_service.dart` |
| `/api/auth.php` | PUT | `?action=update-profile&id={id}` | ❓ Verificar | `auth_service.dart` |
| `/api/auth.php` | DELETE | `?action=delete&id={id}` | ❓ Verificar | `auth_service.dart` |

---

## 📚 MATERIAS (`api/materias.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/api/materias.php` | GET | `?action=all` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | GET | `?action=all&id={id}` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | POST | `?action=create` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | PUT | `?action=edit` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | DELETE | `?action=delete` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | GET | `?action=all&profesor_id={teacherId}` | ❓ Verificar | `subject_api_service.dart` |
| `/api/materias.php` | GET | `?action=all&grado={grade}&nivel={level}` | ❓ Verificar | `subject_api_service.dart` |

---

## 👨‍🏫 PROFESORES (`api/auth.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/api/auth.php` | GET | `?action=teachers` | ✅ Probablemente existe | `teacher_api_service.dart` |
| `/api/auth.php` | GET | `?action=teachers&id={id}` | ❓ Verificar | `teacher_api_service.dart` |
| `/api/auth.php` | PUT | `?action=edit-teacher` | ❓ Verificar | `teacher_api_service.dart` |
| `/api/auth.php` | DELETE | `?action=delete-teacher&id={id}` | ❓ Verificar | `teacher_api_service.dart` |

---

## 📝 INSCRIPCIONES (`api/inscripciones.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/api/inscripciones.php` | GET | `?action=inactive` | ❓ Verificar | `enrollment_api_service.dart` |
| `/api/inscripciones.php` | GET | `?action=all` | ❓ Verificar | `enrollment_api_service.dart` |
| `/api/inscripciones.php` | POST | `?action=create` | ❓ Verificar | `enrollment_api_service.dart` |
| `/api/inscripciones.php` | PUT | `?action=update` | ❓ Verificar | `enrollment_api_service.dart` |
| `/api/inscripciones.php` | GET | `?action=student-enroll` | ❓ Verificar | `enrollment_api_service.dart` |
| `/api/inscripciones.php` | GET | `?action=estudiante_materias&usuario_id={userId}` | ❓ Verificar | `enrollment_api_service.dart` |

---

## 📊 ASISTENCIA (`api/asistencia.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter | **PRIORIDAD** |
|----------|--------|--------------|--------|-----------------|----------------|
| `/api/asistencia.php` | POST | `?action=tomar` | ❌ **FALTA** | `attendance_api_service.dart` | **🔥 ALTA** |
| `/api/asistencia.php` | GET | `?action=estudiantes_inscritos&materia_id={id}` | ❓ Verificar | `attendance_api_service.dart` | **🔥 ALTA** |

---

## ⚙️ CONFIGURACIÓN DE MATERIAS (`api/configuracion.php`)

| Endpoint | Método | Action/Query | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/api/configuracion.php` | POST | `?action=guardar` | ❓ Verificar | `attendance_api_service.dart` |
| `/api/configuracion.php` | GET | `?action=obtener&materia_id={id}&año_academico={year}` | ❓ Verificar | `attendance_api_service.dart` |
| `/api/configuracion.php` | GET | `?action=profesor&profesor_id={id}&año_academico={year}` | ❓ Verificar | `attendance_api_service.dart` |
| `/api/configuracion.php` | GET | `?action=verificar_dia&materia_id={id}&fecha={date}` | ❓ Verificar | `attendance_api_service.dart` |
| `/api/configuracion.php` | DELETE | `?action=eliminar&id={id}` | ❓ Verificar | `attendance_api_service.dart` |

---

## 👁️ VISTAS (`vista_estudiantes_materias.php`)

| Endpoint | Método | Query Params | Estado | Archivo Flutter |
|----------|--------|--------------|--------|-----------------|
| `/vista_estudiantes_materias.php` | GET | (sin params) | ✅ **EXISTE** | `student_subject_service.dart` |
| `/vista_estudiantes_materias.php` | GET | `?materia_id={id}` | ✅ **EXISTE** | `student_subject_service.dart` |
| `/vista_estudiantes_materias.php` | GET | `?profesor_id={id}` | ✅ **EXISTE** | `student_subject_service.dart` |

---

## 🔧 OTROS ENDPOINTS (PROBABLEMENTE NO EXISTEN)

Estos endpoints están en el código pero **probablemente NO existen** en el backend PHP:

| Endpoint | Método | Estado | Archivo Flutter |
|----------|--------|--------|-----------------|
| `/attendance-records` | POST | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/attendance-records/batch` | POST | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/attendance-records/subject/{id}/date/{date}` | GET | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/attendance-records/student/{id}/subject/{id}/summary` | GET | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/attendance-records/student/{id}/subject/{id}/history` | GET | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/attendance-records/subject/{id}/date/{date}/exists` | GET | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/subject-configurations/{id}` | PUT | ❌ No existe (REST, no PHP) | `attendance_api_service.dart` |
| `/api/test.php` | GET | ❓ Verificar | `auth_service.dart` |

---

## 🚨 ENDPOINT CRÍTICO QUE FALTA

### **⚠️ `POST /api/asistencia.php?action=tomar`**

Este endpoint es **CRÍTICO** porque es el que la pantalla "Tomar Asistencia" está intentando usar y está fallando.

**Formato esperado:**
```json
{
  "materia_id": 5,
  "fecha_clase": "2025-10-29",
  "profesor_id": 5,
  "asistencias": [
    {
      "estudiante_id": 15,
      "estado": "presente"
    },
    {
      "estudiante_id": 16,
      "estado": "ausente"
    },
    {
      "estudiante_id": 17,
      "estado": "tardanza"
    }
  ]
}
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Asistencia guardada correctamente",
  "data": {
    "registros_guardados": 3
  }
}
```

---

## 📋 CÓMO VERIFICAR LOS ENDPOINTS

### Opción 1: Usar Cursor para buscar en el proyecto backend

**Pregúntale a Cursor:**
```
¿Qué archivos PHP hay en el proyecto backend? 
¿Cuáles son todos los endpoints disponibles en api/asistencia.php?
¿Existe el endpoint api/asistencia.php?action=tomar?
```

### Opción 2: Verificar manualmente

1. Abre tu proyecto backend PHP
2. Busca los archivos en la carpeta `api/`:
   - `auth.php`
   - `materias.php`
   - `inscripciones.php`
   - `asistencia.php` ⚠️ **¿Existe este?**
   - `configuracion.php`
3. Revisa cada archivo para ver qué acciones (`action`) están implementadas

### Opción 3: Probar los endpoints directamente

Usa Postman o curl para probar cada endpoint:
```bash
# Ejemplo: Probar el endpoint de asistencia
curl -X POST https://hermanosfrios.alwaysdata.net/api/asistencia.php?action=tomar \
  -H "Content-Type: application/json" \
  -d '{"materia_id": 5, "fecha_clase": "2025-10-29", "profesor_id": 5, "asistencias": []}'
```

---

## ✅ CHECKLIST PARA EL BACKEND

Marca los endpoints que **confirmes que existen**:

### Autenticación
- [ ] `POST /api/auth.php?action=login`
- [ ] `POST /api/auth.php?action=register`
- [ ] `GET /api/auth.php?action=profile`
- [ ] `GET /api/auth.php?action=teachers`
- [ ] `GET /api/auth.php?action=students`

### Materias
- [ ] `GET /api/materias.php?action=all`
- [ ] `GET /api/materias.php?action=all&profesor_id={id}`
- [ ] `POST /api/materias.php?action=create`
- [ ] `PUT /api/materias.php?action=edit`
- [ ] `DELETE /api/materias.php?action=delete`

### Asistencia **🔥 CRÍTICO**
- [ ] `POST /api/asistencia.php?action=tomar` ⚠️ **ESTE FALTA**
- [ ] `GET /api/asistencia.php?action=estudiantes_inscritos&materia_id={id}`

### Configuración
- [ ] `POST /api/configuracion.php?action=guardar`
- [ ] `GET /api/configuracion.php?action=obtener`
- [ ] `GET /api/configuracion.php?action=profesor`
- [ ] `DELETE /api/configuracion.php?action=eliminar`

### Inscripciones
- [ ] `GET /api/inscripciones.php?action=all`
- [ ] `POST /api/inscripciones.php?action=create`
- [ ] `PUT /api/inscripciones.php?action=update`

---

## 💡 RECOMENDACIÓN

**Prioridad 1:** Crear el endpoint `POST /api/asistencia.php?action=tomar` porque es el que está causando el error actual.

**Prioridad 2:** Verificar que existan todos los demás endpoints marcados como "🔥 ALTA".

**Prioridad 3:** Los endpoints marcados como "❓ Verificar" pueden no ser críticos si no se usan en las funcionalidades actuales.

