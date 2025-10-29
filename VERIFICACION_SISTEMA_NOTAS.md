# ✅ Verificación del Sistema de Notas

## 📋 **1. Modelo Grade (`lib/models/grade_model.dart`)** ✅

### Lógica de Aprobado/Reprobado:
```dart
bool get aprobado {
  if (promedio == null) return false;
  return promedio! >= 60.0;  // ✅ 60 = Aprobado
}

String get estadoTexto => aprobado ? 'Aprobado' : 'Reprobado';

String get estadoTextoCompleto {
  if (promedio == null) return 'Sin calificar';
  return aprobado ? 'Aprobado' : 'Reprobado';
}
```

### ✅ Campos del Modelo:
- `id`, `estudianteId`, `materiaId`, `profesorId`
- `anioAcademico`
- `nota1`, `nota2`, `nota3`, `nota4` (opcionales, double?)
- `promedio` (calculado)
- `nombreEstudiante`, `nombreMateria`, `nombreProfesor` (para visualización)

---

## 🔧 **2. Servicio GradesApiService (`lib/services/grades_api_service.dart`)** ✅

### ✅ Endpoints Implementados:

1. **`saveGrade()`** - Guardar/actualizar notas de un estudiante
   - URL: `api/notas.php?action=guardar`
   - Método: POST
   - ✅ Envía las 4 notas opcionales

2. **`getStudentGradeInMatter()`** - Obtener notas de un estudiante en una materia
   - URL: `api/notas.php?action=obtener_estudiante&estudiante_id={id}&materia_id={id}`
   - Método: GET
   - ✅ Para vista de estudiante

3. **`getMatterGrades()`** - Profesor obtiene todas las notas de una materia
   - URL: `api/notas.php?action=obtener_materia&materia_id={id}&profesor_id={id}`
   - Método: GET
   - ✅ Para vista de profesor

4. **`getAllStudentGrades()`** - Estudiante obtiene todas sus notas
   - URL: `api/notas.php?action=obtener_todas&estudiante_id={id}`
   - Método: GET
   - ✅ Para lista completa del estudiante

---

## 👨‍🏫 **3. Pantallas de Profesor** ✅

### 3.1 `teacher_grades_list_screen.dart` - Lista de Materias ✅

#### ✅ Es Dinámico:
```dart
// Obtiene el usuario logueado
final user = await UserService.getCurrentUser();

// Busca el profesor correspondiente por email
final allTeachers = await _teacherService.getAllTeachers();
final userEmail = user.email.toLowerCase();
final teacher = allTeachers.firstWhere((t) => t.email.toLowerCase() == userEmail);

// Carga SOLO las materias asignadas a este profesor
final subjects = await _subjectService.getSubjectsByTeacher(teacher.id.toString());
```

**✅ Verificación:**
- ✅ Cada profesor ve SOLO sus materias
- ✅ No hay datos hardcodeados
- ✅ Filtra por `teacherId` real del usuario logueado

### 3.2 `teacher_students_grades_screen.dart` - Lista de Estudiantes ✅

#### ✅ Es Dinámico:
```dart
// Carga estudiantes inscritos en la materia específica
final students = await _attendanceService.getInscribedStudents(materiaId);

// Carga notas de todos los estudiantes en esta materia
final grades = await _gradesService.getMatterGrades(
  materiaId: int.parse(widget.subject.id!),
  profesorId: widget.profesorId,
  anioAcademico: DateTime.now().year.toString(),
);
```

**✅ Verificación:**
- ✅ Muestra solo estudiantes inscritos en la materia seleccionada
- ✅ Cada estudiante tiene su botón "Calificar" o "Editar" según si tiene notas
- ✅ Muestra promedio y estado (Aprobado/Reprobado) visual
- ✅ Usa `aprobado` del modelo (>=60)

### 3.3 `teacher_grades_form_screen.dart` - Formulario de Notas ✅

#### ✅ Validaciones:
```dart
bool _canSave() {
  // Al menos una nota debe tener valor
  if (n1 == null && n2 == null && n3 == null && n4 == null) {
    return false;
  }
  
  // Todas las notas deben estar entre 0-100
  if ((n1 != null && (n1 < 0 || n1 > 100)) || ...) {
    return false;
  }
  return true;
}
```

#### ✅ Cálculo de Promedio en Tiempo Real:
```dart
void _calculateAverage() {
  final notes = [nota1, nota2, nota3, nota4];
  final validNotes = notes.where((n) => n != null).toList();
  
  if (validNotes.isNotEmpty) {
    _calculatedAverage = validNotes.reduce((a, b) => a! + b!)! / validNotes.length;
  }
}
```

#### ✅ Lógica de Aprobado/Reprobado:
```dart
// Muestra color verde si >= 60, rojo si < 60
color: _calculatedAverage! >= 60 ? Colors.green : Colors.red
label: _calculatedAverage! >= 60 ? 'Aprobado' : 'Reprobado'
```

**✅ Verificación:**
- ✅ Formulario válido con las 4 notas (0-100)
- ✅ Botón "Guardar" deshabilitado si falta validación
- ✅ Promedio se calcula automáticamente
- ✅ Muestra estado Aprobado/Reprobado con colores
- ✅ Guarda en el backend usando el servicio API

---

## 👨‍🎓 **4. Pantallas de Estudiante** ⚠️

### ❌ **NO HAN SIDO CREADAS AÚN**

**Faltan:**
1. `student_grades_list_screen.dart` - Lista de materias del estudiante
2. `student_materia_grades_screen.dart` - Detalle de notas en una materia
3. `student_all_grades_screen.dart` - Vista general de todas las notas

---

## 🔗 **5. Navegación en Dashboard** ⚠️

### ❌ **NO ESTÁ CONECTADO**

**En `dashboard_screen.dart` línea 66-72:**
```dart
DashboardItem(
  title: 'Calificaciones',
  icon: Icons.grade,
  color: Colors.red,
  roles: ['admin', 'profesor'],
),
```

**Pero en `_navigateToModule()` NO hay el caso "Calificaciones"**

---

## ✅ **Resumen de Verificación**

### ✅ **Funciona y es Dinámico:**
1. ✅ Modelo `Grade` con lógica 60 = Aprobado
2. ✅ Servicio `GradesApiService` completo
3. ✅ Pantalla de profesor: lista de materias (dinámico)
4. ✅ Pantalla de profesor: lista de estudiantes (dinámico)
5. ✅ Formulario de calificación (validación 0-100)
6. ✅ Cálculo de promedio en tiempo real
7. ✅ Estado visual Aprobado/Reprobado

### ⚠️ **Falta Implementar:**
1. ❌ Pantallas de estudiante para ver sus notas
2. ❌ Conectar "Calificaciones" en el dashboard
3. ❌ Agregar opción "Ver Mis Notas" en dashboard de estudiante

---

## 🎯 **Lo que funciona cuando un PROFESOR entra:**

1. **Profesor inicia sesión** → Obtiene su `userId` y `email`
2. **Busca profesor por email** → Obtiene su `profesorId`
3. **Carga materias** → Solo las que tiene asignadas con ese `profesorId`
4. **Selecciona materia** → Ve solo los estudiantes inscritos en esa materia
5. **Califica estudiante** → Formulario con 4 notas (0-100)
6. **Guarda** → Backend calcula promedio
7. **Ve estado** → Visual verde (aprobado) o rojo (reprobado) según promedio >= 60

**✅ TODO ES DINÁMICO, NO HAY DATOS HARDCODEADOS**

---

## 🎯 **Lo que NO funciona todavía:**

### Estudiante:
- No puede ver sus notas
- No hay pantallas para estudiantes
- No hay navegación en el dashboard

---

## 📝 **Siguiente Paso Recomendado:**

1. Crear pantallas de estudiante
2. Agregar navegación en el dashboard
3. Probar con datos reales del servidor

