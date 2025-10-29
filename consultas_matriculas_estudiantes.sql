-- =====================================================
-- CONSULTAS PARA VER MATERIAS MATRICULADAS DE ESTUDIANTES
-- =====================================================

-- =====================================================
-- CONSULTA 1: Por nombre de estudiante (RECOMENDADA)
-- Obtiene las materias donde están inscritos Fabricio Chali y Sostenes Chali
-- =====================================================
SELECT 
    u.id AS usuario_id,
    e.id AS estudiante_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo_estudiante,
    u.email AS email_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    CONCAT(u.nombre, ' ', u.apellido) IN ('fabricio chali', 'sostenes chali')
    AND i.estado = 'activo'  -- Solo inscripciones activas
ORDER BY 
    nombre_completo_estudiante, nombre_materia;


-- =====================================================
-- CONSULTA 2: Por apellido (si hay varios con mismo apellido)
-- Obtiene todas las materias de estudiantes con apellido "Chali"
-- =====================================================
SELECT 
    u.id AS usuario_id,
    e.id AS estudiante_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo_estudiante,
    u.email AS email_estudiante,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    u.apellido LIKE '%chali%'  -- Buscar por apellido
    AND i.estado = 'activo'
ORDER BY 
    nombre_completo_estudiante, nombre_materia;


-- =====================================================
-- CONSULTA 3: Por usuario_id
-- Si conoces el usuario_id de los estudiantes
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    u.id IN (21, 22)  -- ⚠️ Cambiar por los usuario_id de Fabricio y Sostenes
    AND i.estado = 'activo'
ORDER BY 
    u.id, nombre_materia;


-- =====================================================
-- CONSULTA 4: Por email
-- Si conoces los emails de los estudiantes
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
WHERE 
    u.email IN ('Fabricio@coleguio.com', 'sostenes@colegio.com')  -- ⚠️ Cambiar por los emails reales
    AND i.estado = 'activo'
ORDER BY 
    u.email, nombre_materia;


-- =====================================================
-- CONSULTA 5: Solo Fabricio Chali
-- Consulta específica para un estudiante
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    e.grado,
    e.seccion,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
    i.fecha_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    LOWER(CONCAT(u.nombre, ' ', u.apellido)) LIKE '%fabricio%chali%'
    AND i.estado = 'activo'
ORDER BY 
    nombre_materia;


-- =====================================================
-- CONSULTA 6: Solo Sostenes Chali
-- Consulta específica para un estudiante
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    e.grado,
    e.seccion,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
    i.fecha_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    LOWER(CONCAT(u.nombre, ' ', u.apellido)) LIKE '%sostenes%chali%'
    AND i.estado = 'activo'
ORDER BY 
    nombre_materia;


-- =====================================================
-- CONSULTA 7: Resumen por estudiante (con conteo)
-- Muestra cuántas materias tiene cada estudiante
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    e.grado,
    e.seccion,
    COUNT(DISTINCT m.id) AS total_materias_inscritas,
    GROUP_CONCAT(DISTINCT m.nombre ORDER BY m.nombre SEPARATOR ', ') AS materias_lista
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
WHERE 
    CONCAT(u.nombre, ' ', u.apellido) IN ('fabricio chali', 'sostenes chali')
    AND i.estado = 'activo'
GROUP BY 
    u.id, u.nombre, u.apellido, u.email, e.grado, e.seccion
ORDER BY 
    nombre_completo;


-- =====================================================
-- CONSULTA 8: Con información de asistencia
-- Muestra materias con estadísticas de asistencia
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion,
    COUNT(DISTINCT a.id) AS total_asistencias_registradas,
    COUNT(DISTINCT CASE WHEN a.estado = 'presente' THEN a.id END) AS asistencias_presente,
    COUNT(DISTINCT CASE WHEN a.estado = 'ausente' THEN a.id END) AS asistencias_ausente,
    COUNT(DISTINCT CASE WHEN a.estado = 'tardanza' THEN a.id END) AS asistencias_tardanza
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN asistencia a ON i.materia_id = a.materia_id AND i.estudiante_id = a.estudiante_id
WHERE 
    CONCAT(u.nombre, ' ', u.apellido) IN ('fabricio chali', 'sostenes chali')
    AND i.estado = 'activo'
GROUP BY 
    u.id, u.nombre, u.apellido, m.id, m.nombre, m.grado, m.seccion, i.fecha_inscripcion
ORDER BY 
    nombre_completo, nombre_materia;


-- =====================================================
-- CONSULTA 9: Todos los estudiantes Chali
-- Lista todos los estudiantes con apellido Chali y sus materias
-- =====================================================
SELECT 
    u.id AS usuario_id,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
    u.email AS email,
    e.grado,
    e.seccion,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
WHERE 
    LOWER(u.apellido) LIKE '%chali%'
    AND i.estado = 'activo'
ORDER BY 
    nombre_completo, nombre_materia;


-- =====================================================
-- CONSULTA 10: Verificar si están en la misma materia
-- Para ver qué materias comparten ambos estudiantes
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    COUNT(DISTINCT u.id) AS estudiantes_en_materia,
    GROUP_CONCAT(DISTINCT CONCAT(u.nombre, ' ', u.apellido) ORDER BY u.nombre SEPARATOR ', ') AS lista_estudiantes
FROM 
    materias m
    INNER JOIN inscripciones i ON m.id = i.materia_id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u ON e.usuario_id = u.id
WHERE 
    CONCAT(u.nombre, ' ', u.apellido) IN ('fabricio chali', 'sostenes chali')
    AND i.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion
HAVING 
    COUNT(DISTINCT u.id) >= 1  -- Cambiar a 2 para ver solo materias que comparten
ORDER BY 
    nombre_materia;


-- =====================================================
-- EJEMPLOS PRÁCTICOS:
-- =====================================================

-- Ejemplo 1: Ver todas las materias de Fabricio Chali
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN profesores p ON m.profesor_id = p.id
WHERE 
    LOWER(CONCAT(u.nombre, ' ', u.apellido)) LIKE '%fabricio%chali%'
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;

-- Ejemplo 2: Ver todas las materias de Sostenes Chali
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    i.fecha_inscripcion
FROM 
    usuarios u
    INNER JOIN estudiantes e ON u.id = e.usuario_id
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN materias m ON i.materia_id = m.id
WHERE 
    LOWER(CONCAT(u.nombre, ' ', u.apellido)) LIKE '%sostenes%chali%'
    AND i.estado = 'activo'
ORDER BY 
    m.nombre;

-- Ejemplo 3: Ver materias compartidas entre ambos
SELECT 
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    GROUP_CONCAT(DISTINCT CONCAT(u.nombre, ' ', u.apellido) SEPARATOR ' y ') AS estudiantes
FROM 
    materias m
    INNER JOIN inscripciones i ON m.id = i.materia_id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u ON e.usuario_id = u.id
WHERE 
    CONCAT(u.nombre, ' ', u.apellido) IN ('fabricio chali', 'sostenes chali')
    AND i.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion
HAVING 
    COUNT(DISTINCT u.id) = 2  -- Ambos estudiantes
ORDER BY 
    m.nombre;

