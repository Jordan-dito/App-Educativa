-- ============================================
-- CONSULTA DE PRUEBA: Verificar que el material se encuentra
-- ============================================

USE hermanosfrios_sistema;

-- Esta es EXACTAMENTE la consulta que el backend PHP debería estar ejecutando
-- para el estudiante 16, materia 12, año 2025

SELECT 
    id,
    materia_id,
    estudiante_id,
    profesor_id,
    año_academico,
    titulo,
    descripcion,
    tipo_contenido,
    contenido,
    url_externa,
    fecha_publicacion,
    fecha_vencimiento,
    estado
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12
  AND (estudiante_id = 16 OR estudiante_id IS NULL)
ORDER BY fecha_publicacion DESC;

-- Resultado esperado: Debería retornar el material con ID 15

-- ============================================
-- Verificación adicional: Contar materiales que debería ver
-- ============================================

SELECT 
    COUNT(*) as total_materiales,
    COUNT(CASE WHEN estudiante_id = 16 THEN 1 END) as especificos_estudiante_16,
    COUNT(CASE WHEN estudiante_id IS NULL THEN 1 END) as materiales_generales
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 12
  AND (estudiante_id = 16 OR estudiante_id IS NULL);

-- Resultado esperado: total_materiales = 1

-- ============================================
-- Verificar también para materia 3 (programación)
-- ============================================

SELECT 
    id,
    materia_id,
    estudiante_id,
    titulo,
    estado
FROM material_reforzamiento
WHERE estado = 'activo'
  AND año_academico = '2025'
  AND materia_id = 3
  AND (estudiante_id = 16 OR estudiante_id IS NULL)
ORDER BY fecha_publicacion DESC;

