-- =====================================================
-- CONSULTA SIMPLE Y CORRECTA
-- Muestra materias con su profesor y estudiantes matriculados
-- LISTA PARA COPIAR Y PEGAR DIRECTAMENTE
-- =====================================================

SELECT 
    m.id AS materia_id,
    m.nombre AS nombre_materia,
    m.grado AS grado_materia,
    m.seccion AS seccion_materia,
    m.año_academico,
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

