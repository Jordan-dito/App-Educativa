-- =====================================================
-- CONSULTAS PARA FERNANDO CHALI
-- Email: fernando@colegio.com
-- Usuario ID: 20
-- Estudiante ID: 14
-- =====================================================

-- VERIFICAR ESTUDIANTE_ID CORRECTO
SELECT 
    e.id AS estudiante_id,
    e.usuario_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u.email
FROM estudiantes e
INNER JOIN usuarios u ON e.usuario_id = u.id
WHERE u.email = 'fernando@colegio.com';

-- VERIFICAR INSCRIPCIONES DEL ESTUDIANTE_ID 14
SELECT 
    i.id,
    i.estudiante_id,
    i.materia_id,
    m.nombre AS nombre_materia,
    i.estado AS estado_inscripcion,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante
FROM inscripciones i
INNER JOIN estudiantes e ON i.estudiante_id = e.id
INNER JOIN materias m ON i.materia_id = m.id
WHERE e.usuario_id = 20 OR e.id = 14;

-- CORREGIR INSCRIPCIONES: CAMBIAR estudiante_id de 20 a 14
-- Esto es porque las inscripciones están con el usuario_id en lugar del estudiante_id
UPDATE inscripciones 
SET estudiante_id = 14 
WHERE estudiante_id = 20 
AND materia_id IN (6, 10, 5);

-- VERIFICAR DESPUÉS DE LA CORRECCIÓN
SELECT 
    i.id,
    i.estudiante_id,
    m.nombre AS nombre_materia,
    i.estado AS estado_inscripcion,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante
FROM inscripciones i
INNER JOIN estudiantes e ON i.estudiante_id = e.id
INNER JOIN materias m ON i.materia_id = m.id
WHERE i.estudiante_id = 14
AND i.estado = 'activo';

