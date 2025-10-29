-- =====================================================
-- CONSULTAS CORRECTAS PARA VER MATERIAS CON PROFESOR Y ESTUDIANTES
-- Basadas en la estructura real de la base de datos
-- =====================================================

-- =====================================================
-- CONSULTA 1: Materias con profesor y lista de estudiantes matriculados
-- Muestra cada materia con su profesor y todos los estudiantes inscritos
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
    m.estado AS estado_materia,
    -- Información del profesor
    p.id AS profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    u_prof.id AS usuario_id_profesor,
    -- Información de estudiantes matriculados
    GROUP_CONCAT(
        DISTINCT CONCAT(e.nombre, ' ', e.apellido) 
        ORDER BY e.nombre 
        SEPARATOR ', '
    ) AS estudiantes_matriculados,
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, m.año_academico, m.estado,
    p.id, p.nombre, p.apellido, u_prof.email, u_prof.id
ORDER BY 
    nombre_profesor, nombre_materia;


-- =====================================================
-- CONSULTA 2: Materia específica con detalle de estudiantes
-- Muestra una materia con todos sus estudiantes matriculados en líneas separadas
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    -- Información de cada estudiante
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u_est.id AS usuario_id_estudiante,
    u_est.email AS email_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    m.estado = 'activo'
    AND (i.estado = 'activo' OR i.estado IS NULL)
ORDER BY 
    nombre_materia, nombre_estudiante;


-- =====================================================
-- CONSULTA 3: Materias de un profesor específico con sus estudiantes
-- Muestra las materias de un profesor y todos sus estudiantes
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u_est.email AS email_estudiante,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    u_prof.id = 27  -- ⚠️ Cambiar por el usuario_id del profesor logueado
    AND m.estado = 'activo'
ORDER BY 
    nombre_materia, nombre_estudiante;


-- =====================================================
-- CONSULTA 4: Resumen de materias por profesor
-- Muestra cada materia con conteo de estudiantes
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    u_prof.id AS usuario_id_profesor,
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes_inscritos,
    GROUP_CONCAT(
        DISTINCT CONCAT(e.nombre, ' ', e.apellido, ' (', e.grado, ' ', e.seccion, ')')
        ORDER BY e.nombre 
        SEPARATOR ' | '
    ) AS lista_estudiantes
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, m.año_academico,
    p.id, p.nombre, p.apellido, u_prof.email, u_prof.id
ORDER BY 
    nombre_profesor, nombre_materia;


-- =====================================================
-- CONSULTA 5: Para Fabricio Chali y Sostenes Chali
-- Muestra en qué materias están matriculados con sus profesores
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    u_prof.id AS usuario_id_profesor,
    -- Información del estudiante
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u_est.id AS usuario_id_estudiante,
    u_est.email AS email_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    i.fecha_inscripcion,
    i.estado AS estado_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    INNER JOIN inscripciones i ON m.id = i.materia_id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    (LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%fabricio%chali%'
     OR LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%sostenes%chali%')
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY 
    nombre_estudiante, nombre_materia;


-- =====================================================
-- CONSULTA 6: Todas las materias con su profesor y estudiantes (VISTA COMPLETA)
-- Muestra todas las materias activas con su información completa
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    CONCAT(m.grado, ' ', m.seccion) AS grado_seccion_materia,
    m.año_academico,
    -- Profesor asignado
    p.id AS profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.id AS usuario_id_profesor,
    u_prof.email AS email_profesor,
    -- Estudiantes matriculados (en una sola columna agrupada)
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes,
    GROUP_CONCAT(
        DISTINCT CONCAT(e.nombre, ' ', e.apellido, ' (ID:', e.id, ')')
        ORDER BY e.nombre 
        SEPARATOR ', '
    ) AS estudiantes_lista
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, m.año_academico,
    p.id, p.nombre, p.apellido, u_prof.id, u_prof.email
ORDER BY 
    nombre_profesor, nombre_materia;


-- =====================================================
-- CONSULTA 7: Materia específica por ID con detalle completo
-- Para ver una materia específica con todos sus detalles
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    m.año_academico,
    -- Profesor
    p.id AS profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    -- Estudiantes
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u_est.id AS usuario_id_estudiante,
    u_est.email AS email_estudiante,
    i.fecha_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
    LEFT JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    m.id = 3  -- ⚠️ Cambiar por el ID de la materia que quieres ver
    AND m.estado = 'activo'
ORDER BY 
    nombre_estudiante;


-- =====================================================
-- CONSULTA 8: Materias con profesor y estudiantes (formato expandido)
-- Una fila por cada estudiante matriculado
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    -- Profesor
    CONCAT(p.nombre, ' ', p.apellido) AS profesor_asignado,
    p.id AS profesor_id,
    u_prof.id AS usuario_id_profesor,
    u_prof.email AS email_profesor,
    -- Estudiante
    CONCAT(e.nombre, ' ', e.apellido) AS estudiante_matriculado,
    e.id AS estudiante_id,
    u_est.id AS usuario_id_estudiante,
    u_est.email AS email_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    i.fecha_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    INNER JOIN inscripciones i ON m.id = i.materia_id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    m.estado = 'activo'
    AND i.estado = 'activo'
ORDER BY 
    nombre_materia, nombre_estudiante;


-- =====================================================
-- CONSULTA 9: Por profesor específico (usuario_id 27 - Maestro Prueba)
-- Para ver qué materias tiene asignadas y sus estudiantes
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    u_prof.email AS email_profesor,
    COUNT(DISTINCT i.estudiante_id) AS estudiantes_inscritos,
    GROUP_CONCAT(
        DISTINCT CONCAT(e.nombre, ' ', e.apellido)
        ORDER BY e.nombre
        SEPARATOR ', '
    ) AS lista_estudiantes
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    u_prof.id = 27  -- Maestro Prueba
    AND m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, p.nombre, p.apellido, u_prof.email
ORDER BY 
    nombre_materia;

-- Resultado esperado: 0 materias (no tiene materias asignadas)


-- =====================================================
-- CONSULTA 10: Para Brandon Mendez (profesor_id 5, usuario_id 16)
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    COUNT(DISTINCT i.estudiante_id) AS estudiantes_inscritos,
    GROUP_CONCAT(
        DISTINCT CONCAT(e.nombre, ' ', e.apellido, ' (', e.grado, ' ', e.seccion, ')')
        ORDER BY e.nombre
        SEPARATOR ' | '
    ) AS estudiantes_matriculados
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id AND i.estado = 'activo'
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    u_prof.id = 16  -- Brandon Mendez
    AND m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, p.nombre, p.apellido
ORDER BY 
    nombre_materia;

-- Resultado esperado: 6 materias con sus estudiantes


-- =====================================================
-- CONSULTA 11: Materias con estudiantes Chali
-- Muestra las materias donde están inscritos Fabricio o Sostenes Chali
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    u_est.id AS usuario_id_estudiante,
    u_est.email AS email_estudiante,
    i.fecha_inscripcion
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    INNER JOIN inscripciones i ON m.id = i.materia_id
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN usuarios u_est ON e.usuario_id = u_est.id
WHERE 
    (LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%fabricio%chali%'
     OR LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%sostenes%chali%')
    AND i.estado = 'activo'
    AND m.estado = 'activo'
ORDER BY 
    nombre_materia, nombre_estudiante;


-- =====================================================
-- CONSULTA 12: Resumen completo del sistema
-- Muestra todas las materias con profesor y total de estudiantes
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    CONCAT(m.grado, ' ', m.seccion) AS grado_seccion,
    m.año_academico,
    m.estado AS estado_materia,
    -- Profesor
    p.id AS profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    u_prof.email AS email_profesor,
    -- Conteo de estudiantes
    COUNT(DISTINCT CASE WHEN i.estado = 'activo' THEN i.estudiante_id END) AS estudiantes_activos,
    COUNT(DISTINCT CASE WHEN i.estado = 'inactivo' THEN i.estudiante_id END) AS estudiantes_inactivos,
    COUNT(DISTINCT i.estudiante_id) AS total_inscripciones
FROM 
    materias m
    INNER JOIN profesores p ON m.profesor_id = p.id
    INNER JOIN usuarios u_prof ON p.usuario_id = u_prof.id
    LEFT JOIN inscripciones i ON m.id = i.materia_id
    LEFT JOIN estudiantes e ON i.estudiante_id = e.id
WHERE 
    m.estado = 'activo'
GROUP BY 
    m.id, m.nombre, m.grado, m.seccion, m.año_academico, m.estado,
    p.id, p.nombre, p.apellido, u_prof.email
ORDER BY 
    nombre_profesor, nombre_materia;

