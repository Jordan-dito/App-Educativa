-- ============================================
-- SCRIPT DE DIAGNÓSTICO: Verificar materiales
-- ============================================

USE hermanosfrios_sistema;

-- 1. Ver TODOS los materiales existentes (sin filtros)
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado,
    fecha_publicacion,
    fecha_vencimiento
FROM material_reforzamiento
ORDER BY fecha_creacion DESC;

-- 2. Ver materiales para el estudiante 16 y materia 12 (sociales)
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado,
    fecha_publicacion,
    fecha_vencimiento
FROM material_reforzamiento
WHERE materia_id = 12
  AND año_academico = '2025'
ORDER BY fecha_creacion DESC;

-- 3. Ver materiales específicos del estudiante 16 en materia 12
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado
FROM material_reforzamiento
WHERE materia_id = 12
  AND estudiante_id = 16
  AND año_academico = '2025';

-- 4. Ver materiales GENERALES (estudiante_id IS NULL) para materia 12
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado
FROM material_reforzamiento
WHERE materia_id = 12
  AND estudiante_id IS NULL
  AND año_academico = '2025';

-- 5. Ver materiales que debería ver el estudiante 16 (específicos O generales)
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado,
    fecha_publicacion
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12
  AND (estudiante_id = 16 OR estudiante_id IS NULL)
ORDER BY fecha_publicacion DESC;

-- 6. Ver materiales para materia 3 (programación) y estudiante 16
SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    tipo_contenido,
    estado
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 3
  AND (estudiante_id = 16 OR estudiante_id IS NULL)
ORDER BY fecha_publicacion DESC;

-- 7. Verificar si hay materiales con estado 'inactivo'
SELECT 
    id,
    materia_id,
    estudiante_id,
    titulo,
    estado
FROM material_reforzamiento
WHERE materia_id IN (3, 12)
  AND año_academico = '2025'
  AND estado = 'inactivo';

-- 8. Verificar el año académico de los materiales recientes
SELECT 
    id,
    materia_id,
    estudiante_id,
    año_academico,
    titulo,
    fecha_creacion
FROM material_reforzamiento
WHERE materia_id IN (3, 12)
ORDER BY fecha_creacion DESC
LIMIT 10;

-- 9. CONTAR materiales por materia y tipo
SELECT 
    materia_id,
    CASE 
        WHEN estudiante_id IS NULL THEN 'GENERAL'
        ELSE CONCAT('ESPECÍFICO (estudiante ', estudiante_id, ')')
    END AS tipo_material,
    COUNT(*) as total,
    SUM(CASE WHEN estado = 'activo' THEN 1 ELSE 0 END) as activos
FROM material_reforzamiento
WHERE materia_id IN (3, 12)
  AND año_academico = '2025'
GROUP BY materia_id, estudiante_id;

