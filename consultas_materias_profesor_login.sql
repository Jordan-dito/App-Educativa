-- =====================================================
-- CONSULTAS PARA VER MATERIAS DE CONFIGURAR ASISTENCIA
-- Según el usuario logueado (profesor)
-- =====================================================

-- =====================================================
-- CONSULTA 1: Por usuario_id (RECOMENDADA)
-- Obtiene las materias que debe ver un profesor según su usuario_id
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    m.estado AS estado_materia,
    m.fecha_creacion,
    p.id AS profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u.id AS usuario_id,
    u.email AS email_profesor,
    (SELECT COUNT(*) 
     FROM inscripciones i 
     WHERE i.materia_id = m.id 
     AND i.estado = 'activo') AS total_estudiantes_inscritos
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND m.estado = 'activo'  -- Solo materias activas
ORDER BY 
    m.nombre, m.grado, m.seccion;


-- =====================================================
-- CONSULTA 2: Por email del profesor
-- Si conoces el email del profesor logueado
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    m.estado AS estado_materia,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u.email AS email_profesor,
    (SELECT COUNT(*) 
     FROM inscripciones i 
     WHERE i.materia_id = m.id 
     AND i.estado = 'activo') AS estudiantes_inscritos
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.email = 'maestro@colegio.com'  -- ⚠️ Cambiar por el email del profesor logueado
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- CONSULTA 3: Con información completa de estudiantes
-- Muestra cada materia con sus estudiantes inscritos
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    u.email AS email_profesor,
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS estudiante,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND m.estado = 'activo'
ORDER BY 
    m.nombre, e.nombre;


-- =====================================================
-- CONSULTA 4: Resumen por profesor (conteo)
-- Muestra estadísticas de materias del profesor
-- =====================================================
SELECT 
    u.id AS usuario_id,
    u.email AS email_profesor,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    p.id AS profesor_id,
    COUNT(DISTINCT m.id) AS total_materias_asignadas,
    COUNT(DISTINCT CASE WHEN m.estado = 'activo' THEN m.id END) AS materias_activas,
    COUNT(DISTINCT CASE WHEN m.estado = 'inactivo' THEN m.id END) AS materias_inactivas,
    SUM((SELECT COUNT(*) 
         FROM inscripciones i 
         WHERE i.materia_id = m.id 
         AND i.estado = 'activo')) AS total_estudiantes_total
FROM 
    usuarios u
    INNER JOIN profesores p ON u.id = p.usuario_id
    LEFT JOIN materias m ON p.id = m.profesor_id
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
GROUP BY 
    u.id, u.email, p.nombre, p.apellido, p.id;


-- =====================================================
-- CONSULTA 5: Solo materias activas (simplificada)
-- Versión simple para verificar rápidamente
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    CONCAT(m.grado, ' ', m.seccion) AS grado_seccion,
    m.año_academico
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;


-- =====================================================
-- EJEMPLOS PRÁCTICOS PARA DIFERENTES PROFESORES:
-- =====================================================

-- Ejemplo 1: Para el profesor con usuario_id 16 (Brandon Mendez)
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    (SELECT COUNT(*) 
     FROM inscripciones i 
     WHERE i.materia_id = m.id 
     AND i.estado = 'activo') AS estudiantes_inscritos
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 16  -- Brandon Mendez
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;

-- Resultado esperado: 6 materias
-- - programación (2° A)
-- - ciencias naturales (3° A)
-- - matemática (3° A)
-- - ingles (3° A)
-- - gastonomia (1° A)


-- Ejemplo 2: Para el profesor con usuario_id 27 (Maestro Prueba)
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 27  -- Maestro Prueba
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;

-- Resultado esperado: 0 materias (no tiene materias asignadas)


-- Ejemplo 3: Para el profesor con usuario_id 2 (María Elena González)
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 2  -- María Elena González
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;

-- Resultado esperado: 3 materias
-- - prueba (1° A)
-- - contabilidad (3° C)
-- - sociales (3° C)


-- =====================================================
-- CONSULTA 6: Verificar usuario logueado y sus materias
-- Consulta completa para debug
-- =====================================================
SELECT 
    'Usuario Logueado' AS tipo,
    u.id AS id,
    u.email AS identificador,
    u.rol AS rol,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    p.id AS profesor_id,
    COUNT(DISTINCT m.id) AS materias_asignadas
FROM 
    usuarios u
    LEFT JOIN profesores p ON u.id = p.usuario_id
    LEFT JOIN materias m ON p.id = m.profesor_id AND m.estado = 'activo'
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND u.rol = 'profesor'
GROUP BY 
    u.id, u.email, u.rol, p.nombre, p.apellido, p.id


UNION ALL

SELECT 
    'Materias Asignadas' AS tipo,
    m.id AS id,
    m.nombre AS identificador,
    CONCAT(m.grado, ' ', m.seccion) AS rol,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    m.profesor_id AS profesor_id,
    (SELECT COUNT(*) 
     FROM inscripciones i 
     WHERE i.materia_id = m.id 
     AND i.estado = 'activo') AS materias_asignadas
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    u.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND m.estado = 'activo'
ORDER BY 
    tipo, id;


-- =====================================================
-- CONSULTA 7: Por nombre de profesor
-- Si conoces el nombre del profesor
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u.email AS email_profesor,
    u.id AS usuario_id
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u ON p.usuario_id = u.id
WHERE 
    CONCAT(p.nombre, ' ', p.apellido) LIKE '%Maestro Prueba%'  -- ⚠️ Cambiar por el nombre del profesor
    AND m.estado = 'activo'
ORDER BY 
    m.nombre;

