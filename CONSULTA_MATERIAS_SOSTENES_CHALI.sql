-- =====================================================
-- CONSULTAS PARA VERIFICAR MATERIAS INSCRITAS
-- Estudiante: Sostenes Chali
-- =====================================================

-- CONSULTA 1: Simple - Materias activas donde está inscrito Sostenes Chali
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM inscripciones i
INNER JOIN materias m ON i.materia_id = m.id
INNER JOIN profesores p ON m.profesor_id = p.id
INNER JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    e.id = 16  -- estudiante_id de Sostenes Chali
    AND i.estado = 'activo'
ORDER BY m.nombre;

-- =====================================================

-- CONSULTA 2: Completa - Con información adicional del estudiante
SELECT 
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    m.estado AS estado_materia
FROM inscripciones i
INNER JOIN estudiantes e ON i.estudiante_id = e.id
INNER JOIN materias m ON i.materia_id = m.id
INNER JOIN profesores p ON m.profesor_id = p.id
INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
WHERE 
    LOWER(CONCAT(e.nombre, ' ', e.apellido)) = 'sostenes chali'
    AND i.estado = 'activo'
ORDER BY m.nombre;

-- =====================================================

-- CONSULTA 3: Por usuario_id (usando el email o usuario_id)
SELECT 
    u.id AS usuario_id,
    u.email AS email_estudiante,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM usuarios u
INNER JOIN estudiantes e ON u.id = e.usuario_id
INNER JOIN inscripciones i ON e.id = i.estudiante_id
INNER JOIN materias m ON i.materia_id = m.id
INNER JOIN profesores p ON m.profesor_id = p.id
WHERE 
    u.id = 22  -- usuario_id de Sostenes Chali
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY m.nombre;

-- =====================================================

-- CONSULTA 4: Usando email (si conoces el email)
SELECT 
    u.email,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM usuarios u
INNER JOIN estudiantes e ON u.id = e.usuario_id
INNER JOIN inscripciones i ON e.id = i.estudiante_id
INNER JOIN materias m ON i.materia_id = m.id
INNER JOIN profesores p ON m.profesor_id = p.id
WHERE 
    u.email = 'sostenes@colegio.com'
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY m.nombre;

-- =====================================================

-- CONSULTA 5: Conteo total de materias inscritas
SELECT 
    COUNT(*) AS total_materias_activas
FROM inscripciones i
INNER JOIN estudiantes e ON i.estudiante_id = e.id
INNER JOIN materias m ON i.materia_id = m.id
WHERE 
    e.id = 16  -- estudiante_id de Sostenes Chali
    AND i.estado = 'activo'
    AND m.estado = 'activo';

-- =====================================================

-- CONSULTA 6: Materias inscritas Y no inscritas (comparación)
-- Muestra todas las materias activas y marca si está inscrito o no
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    CASE 
        WHEN i.estudiante_id IS NOT NULL THEN 'INSCRITO'
        ELSE 'NO INSCRITO'
    END AS estado_inscripcion,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion_detalle
FROM materias m
INNER JOIN profesores p ON m.profesor_id = p.id
LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estudiante_id = 16 AND i.estado = 'activo'
WHERE m.estado = 'activo'
ORDER BY 
    CASE WHEN i.estudiante_id IS NOT NULL THEN 0 ELSE 1 END,
    m.nombre;

