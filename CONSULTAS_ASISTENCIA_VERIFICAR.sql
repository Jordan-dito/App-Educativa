-- =====================================================
-- CONSULTAS PARA VERIFICAR ASISTENCIA GUARDADA
-- =====================================================

-- =====================================================
-- CONSULTA 1: Ver todas las asistencias guardadas
-- =====================================================
SELECT 
    a.id AS asistencia_id,
    a.materia_id,
    m.nombre AS nombre_materia,
    a.estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    a.fecha_clase,
    a.estado AS estado_asistencia,
    a.profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    a.fecha_registro
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
    INNER JOIN estudiantes e ON a.estudiante_id = e.id
    INNER JOIN profesores p ON a.profesor_id = p.id
ORDER BY 
    a.fecha_clase DESC, m.nombre, e.nombre;


-- =====================================================
-- CONSULTA 2: Asistencias de una materia específica en una fecha
-- Para verificar si ya se tomó asistencia
-- =====================================================
SELECT 
    a.id AS asistencia_id,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    a.fecha_clase,
    COUNT(DISTINCT a.estudiante_id) AS total_estudiantes_con_asistencia,
    COUNT(DISTINCT CASE WHEN a.estado = 'presente' THEN a.estudiante_id END) AS presentes,
    COUNT(DISTINCT CASE WHEN a.estado = 'ausente' THEN a.estudiante_id END) AS ausentes,
    COUNT(DISTINCT CASE WHEN a.estado = 'tardanza' THEN a.estudiante_id END) AS tardanzas,
    MIN(a.fecha_registro) AS primera_registro,
    MAX(a.fecha_registro) AS ultimo_registro
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
WHERE 
    m.id = 3  -- ⚠️ Cambiar por el ID de la materia
    AND a.fecha_clase = '2025-10-29'  -- ⚠️ Cambiar por la fecha a verificar
GROUP BY 
    a.id, m.id, m.nombre, a.fecha_clase;


-- =====================================================
-- CONSULTA 3: Detalle de asistencias por materia y fecha
-- Muestra cada estudiante con su estado de asistencia
-- =====================================================
SELECT 
    a.id AS asistencia_id,
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado,
    m.seccion,
    a.fecha_clase,
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    e.grado AS grado_estudiante,
    e.seccion AS seccion_estudiante,
    a.estado AS estado_asistencia,
    a.profesor_id,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor,
    a.fecha_registro
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
    INNER JOIN estudiantes e ON a.estudiante_id = e.id
    INNER JOIN profesores p ON a.profesor_id = p.id
WHERE 
    m.id = 3  -- ⚠️ Cambiar por el ID de la materia
    AND a.fecha_clase = '2025-10-29'  -- ⚠️ Cambiar por la fecha
ORDER BY 
    e.nombre;


-- =====================================================
-- CONSULTA 4: Verificar si existe asistencia para materia y fecha
-- Similar a lo que debería hacer el método hasAttendanceForDate
-- =====================================================
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 1 
        ELSE 0 
    END AS existe_asistencia,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT a.estudiante_id) AS estudiantes_registrados
FROM 
    asistencia a
WHERE 
    a.materia_id = 3  -- ⚠️ Cambiar por el ID de la materia
    AND a.fecha_clase = '2025-10-29';  -- ⚠️ Cambiar por la fecha


-- =====================================================
-- CONSULTA 5: Comparar estudiantes inscritos vs asistencias registradas
-- Para ver si falta registrar asistencia de algún estudiante
-- =====================================================
SELECT 
    i.estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    i.materia_id,
    m.nombre AS nombre_materia,
    CASE 
        WHEN a.id IS NOT NULL THEN '✅ Registrado'
        ELSE '❌ NO registrado'
    END AS estado_asistencia,
    a.estado AS tipo_asistencia,
    a.fecha_registro
FROM 
    inscripciones i
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN asistencia a ON i.estudiante_id = a.estudiante_id 
                            AND i.materia_id = a.materia_id 
                            AND a.fecha_clase = '2025-10-29'  -- ⚠️ Cambiar por la fecha
WHERE 
    i.materia_id = 3  -- ⚠️ Cambiar por el ID de la materia
    AND i.estado = 'activo'
ORDER BY 
    CASE 
        WHEN a.id IS NULL THEN 0 
        ELSE 1 
    END,
    e.nombre;


-- =====================================================
-- CONSULTA 6: Últimas asistencias guardadas (ordenadas por fecha)
-- Para ver qué se guardó recientemente
-- =====================================================
SELECT 
    a.id AS asistencia_id,
    m.nombre AS nombre_materia,
    CONCAT(e.nombre, ' ', e.apellido) AS estudiante,
    a.fecha_clase,
    a.estado AS estado_asistencia,
    a.fecha_registro,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
    INNER JOIN estudiantes e ON a.estudiante_id = e.id
    INNER JOIN profesores p ON a.profesor_id = p.id
ORDER BY 
    a.fecha_registro DESC
LIMIT 20;


-- =====================================================
-- CONSULTA 7: Asistencias por materia (resumen)
-- =====================================================
SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    COUNT(DISTINCT a.fecha_clase) AS total_fechas_con_asistencia,
    MIN(a.fecha_clase) AS primera_fecha,
    MAX(a.fecha_clase) AS ultima_fecha,
    COUNT(DISTINCT a.estudiante_id) AS estudiantes_con_registros,
    COUNT(*) AS total_registros_asistencia,
    COUNT(CASE WHEN a.estado = 'presente' THEN 1 END) AS total_presentes,
    COUNT(CASE WHEN a.estado = 'ausente' THEN 1 END) AS total_ausentes,
    COUNT(CASE WHEN a.estado = 'tardanza' THEN 1 END) AS total_tardanzas
FROM 
    materias m
    LEFT JOIN asistencia a ON m.id = a.materia_id
WHERE 
    m.id = 3  -- ⚠️ Cambiar por el ID de la materia o quitar WHERE para ver todas
GROUP BY 
    m.id, m.nombre
ORDER BY 
    m.nombre;


-- =====================================================
-- CONSULTA 8: Verificar asistencia de Fabricio y Sostenes Chali
-- =====================================================
SELECT 
    a.id AS asistencia_id,
    m.nombre AS nombre_materia,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    a.fecha_clase,
    a.estado AS estado_asistencia,
    a.fecha_registro,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesor
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
    INNER JOIN estudiantes e ON a.estudiante_id = e.id
    INNER JOIN profesores p ON a.profesor_id = p.id
WHERE 
    LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%fabricio%chali%'
       OR LOWER(CONCAT(e.nombre, ' ', e.apellido)) LIKE '%sostenes%chali%'
ORDER BY 
    a.fecha_clase DESC, m.nombre;


-- =====================================================
-- CONSULTA 9: Estudiantes inscritos en materia 3 pero SIN asistencia en fecha específica
-- Para detectar si falta registrar a alguien
-- =====================================================
SELECT 
    e.id AS estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    e.grado,
    e.seccion,
    i.materia_id,
    m.nombre AS nombre_materia,
    '2025-10-29' AS fecha_clase_esperada,
    '❌ NO tiene asistencia registrada' AS estado
FROM 
    inscripciones i
    INNER JOIN estudiantes e ON i.estudiante_id = e.id
    INNER JOIN materias m ON i.materia_id = m.id
    LEFT JOIN asistencia a ON i.estudiante_id = a.estudiante_id 
                            AND i.materia_id = a.materia_id 
                            AND a.fecha_clase = '2025-10-29'
WHERE 
    i.materia_id = 3  -- ⚠️ Cambiar por el ID de la materia
    AND i.estado = 'activo'
    AND a.id IS NULL  -- Solo los que NO tienen asistencia
ORDER BY 
    e.nombre;


-- =====================================================
-- CONSULTA 10: Verificar duplicados de asistencia
-- Por si se guardó dos veces para el mismo estudiante, materia y fecha
-- =====================================================
SELECT 
    a.materia_id,
    m.nombre AS nombre_materia,
    a.estudiante_id,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    a.fecha_clase,
    COUNT(*) AS veces_registrado,
    GROUP_CONCAT(a.id ORDER BY a.fecha_registro SEPARATOR ', ') AS ids_asistencia,
    GROUP_CONCAT(a.estado ORDER BY a.fecha_registro SEPARATOR ', ') AS estados,
    GROUP_CONCAT(a.fecha_registro ORDER BY a.fecha_registro SEPARATOR ' | ') AS fechas_registro
FROM 
    asistencia a
    INNER JOIN materias m ON a.materia_id = m.id
    INNER JOIN estudiantes e ON a.estudiante_id = e.id
GROUP BY 
    a.materia_id, a.estudiante_id, a.fecha_clase
HAVING 
    COUNT(*) > 1  -- Solo duplicados
ORDER BY 
    a.fecha_clase DESC, m.nombre;

