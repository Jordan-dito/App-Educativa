-- =====================================================
-- CONSULTAS PARA VER MATERIAS INSCRITAS DE UN ESTUDIANTE
-- =====================================================

-- =====================================================
-- CONSULTA 1: Materias inscritas por usuario_id
-- Obtiene todas las materias donde está inscrito un estudiante
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    p.nombre AS nombre_profesor,
    p.apellido AS apellido_profesor,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo_profesor
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN profesores p ON m.profesor_id = p.id
WHERE 
    e.usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante (ej: 21)
    AND i.estado = 'activo'
ORDER BY 
    m.nombre, m.grado, m.seccion;


-- =====================================================
-- CONSULTA 2: Materias inscritas por usuario_id (VERSIÓN SIMPLIFICADA)
-- Solo muestra información básica de las materias
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(m.nombre, ' - ', m.grado, ' ', m.seccion) AS materia_completa,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    e.usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- CONSULTA 3: Materias inscritas con información del profesor
-- Incluye datos del profesor asignado
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    CASE 
        WHEN i.estado = 'activo' THEN 'Inscrito'
        ELSE 'No inscrito'
    END AS estado_texto
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    e.usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY 
    m.grado, m.seccion, m.nombre;


-- =====================================================
-- CONSULTA 4: Materias inscritas con conteo de estudiantes
-- Muestra cuántos estudiantes están en cada materia
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    (SELECT COUNT(*) 
     FROM inscripciones i2 
     WHERE i2.materia_id = m.id 
     AND i2.estado = 'activo') AS total_estudiantes
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    e.usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- CONSULTA 5: Usando la vista (si existe)
-- Usa la vista vista_estudiantes_materias si está disponible
-- =====================================================
SELECT 
    materia_id,
    nombre_materia,
    grado,
    seccion,
    nombre_profesor,
    estado_inscripcion
FROM 
    vista_estudiantes_materias
WHERE 
    estudiante_id = (
        SELECT id 
        FROM estudiantes 
        WHERE usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante
    )
    AND estado_inscripcion = 'activo'
ORDER BY 
    nombre_materia;


-- =====================================================
-- CONSULTA 6: Por email del estudiante (alternativa)
-- Si conoces el email pero no el usuario_id
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u ON e.usuario_id = u.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    u.email = ? -- Reemplazar ? con el email del estudiante (ej: 'pedro@email.com')
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- EJEMPLOS DE USO:
-- =====================================================

-- Ejemplo 1: Buscar materias del usuario_id 21
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    i.fecha_inscripcion
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    e.usuario_id = 21
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;

-- Ejemplo 2: Buscar materias por email
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion
FROM 
    inscripciones i
    INNER JOIN materias m ON i.materia_id = m.id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u ON e.usuario_id = u.id
WHERE 
    u.email = 'pedro@email.com'
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- CONSULTA PARA VER TODAS LAS MATERIAS (incluyendo no inscritas)
-- Útil para mostrar opciones disponibles
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CASE 
        WHEN i.id IS NOT NULL THEN 'Inscrito'
        ELSE 'No inscrito'
    END AS estado_inscripcion,
    i.fecha_inscripcion
FROM 
    materias m
    LEFT JOIN inscripciones i ON m.id = i.materia_id 
        AND i.estudiante_id = (
            SELECT id 
            FROM estudiantes 
            WHERE usuario_id = ? -- Reemplazar ? con el usuario_id del estudiante
        )
WHERE 
    m.estado = 'activo'
ORDER BY 
    m.nombre;

