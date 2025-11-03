-- ============================================
-- SCRIPT PARA CORREGIR FECHAS DE VENCIMIENTO
-- ============================================

USE hermanosfrios_sistema;

-- 1. Ver materiales con fechas de vencimiento incorrectas
-- (fecha_vencimiento antes de fecha_publicacion)
SELECT 
    id,
    materia_id,
    estudiante_id,
    titulo,
    fecha_publicacion,
    fecha_vencimiento,
    DATEDIFF(fecha_vencimiento, fecha_publicacion) as dias_diferencia,
    CASE 
        WHEN fecha_vencimiento < fecha_publicacion THEN '❌ VENCIDO ANTES DE PUBLICAR'
        WHEN fecha_vencimiento < CURDATE() THEN '⚠️ YA VENCIDO'
        ELSE '✅ VIGENTE'
    END as estado_fecha
FROM material_reforzamiento
WHERE fecha_vencimiento IS NOT NULL
ORDER BY fecha_publicacion DESC;

-- 2. Ver materiales que están vencidos HOY
SELECT 
    id,
    materia_id,
    estudiante_id,
    titulo,
    fecha_publicacion,
    fecha_vencimiento,
    DATEDIFF(CURDATE(), fecha_vencimiento) as dias_vencido
FROM material_reforzamiento
WHERE fecha_vencimiento IS NOT NULL
  AND fecha_vencimiento < CURDATE()
  AND estado = 'activo';

-- 3. OPCIÓN 1: Eliminar fecha_vencimiento de materiales con fecha incorrecta
-- Esto permite que se muestren siempre (sin fecha de vencimiento)
UPDATE material_reforzamiento
SET fecha_vencimiento = NULL
WHERE fecha_vencimiento < fecha_publicacion
  AND estado = 'activo';

-- 4. OPCIÓN 2: Corregir fecha_vencimiento agregando 30 días desde fecha_publicacion
-- (Solo para materiales con fecha_vencimiento anterior a fecha_publicacion)
UPDATE material_reforzamiento
SET fecha_vencimiento = DATE_ADD(fecha_publicacion, INTERVAL 30 DAY)
WHERE fecha_vencimiento < fecha_publicacion
  AND estado = 'activo';

-- 5. OPCIÓN 3: Actualizar fecha_vencimiento de un material específico
-- Reemplaza el ID 15 con el ID del material que quieres corregir
UPDATE material_reforzamiento
SET fecha_vencimiento = DATE_ADD(fecha_publicacion, INTERVAL 30 DAY)
WHERE id = 15;

-- 6. Verificar corrección
SELECT 
    id,
    titulo,
    fecha_publicacion,
    fecha_vencimiento,
    DATEDIFF(fecha_vencimiento, fecha_publicacion) as dias_para_vencer
FROM material_reforzamiento
WHERE id = 15;

