-- ============================================
-- SCRIPT PARA PROBAR REFORZAMIENTO
-- Materia: 14 ("2026", 5° D)
-- Profesor: 7 ("Maestro Prueba")
-- ============================================

-- 1. Actualizar fecha_fin de la configuración de materia 14 a HOY
-- Esto hace que el ciclo termine hoy para poder probar
UPDATE `configuracion_materia` 
SET `fecha_fin` = CURDATE()
WHERE `id` = 5 AND `materia_id` = 14;

-- 2. Crear/verificar un estudiante en grado 5° D (si no existe)
-- Usaremos el estudiante ID 21 (laura looez) que está en 10° C, pero la actualizaremos a 5° D
-- O podemos crear uno nuevo. Voy a usar uno existente y actualizarlo.

-- Opción A: Actualizar estudiante existente a 5° D
UPDATE `estudiantes`
SET `grado` = '5°', `seccion` = 'D'
WHERE `id` = 21;  -- laura looez

-- 3. Inscribir al estudiante en la materia 14 (si no está inscrito)
INSERT INTO `inscripciones` (`estudiante_id`, `materia_id`, `fecha_inscripcion`, `estado`)
VALUES (21, 14, CURDATE(), 'activo')
ON DUPLICATE KEY UPDATE `estado` = 'activo';

-- 4. Crear una nota REPROBADA (< 60) para ese estudiante en la materia 14
INSERT INTO `notas` (
    `estudiante_id`, 
    `materia_id`, 
    `profesor_id`, 
    `año_academico`, 
    `nota_1`, 
    `nota_2`, 
    `nota_3`, 
    `nota_4`, 
    `estado`
)
VALUES (
    21,  -- estudiante_id (laura looez)
    14,  -- materia_id (2026, 5° D)
    7,   -- profesor_id (Maestro Prueba)
    '2025',  -- año_academico
    45.00,   -- nota_1
    50.00,   -- nota_2
    40.00,   -- nota_3
    55.00,   -- nota_4
    'activo'
)
ON DUPLICATE KEY UPDATE
    `nota_1` = 45.00,
    `nota_2` = 50.00,
    `nota_3` = 40.00,
    `nota_4` = 55.00,
    `estado` = 'activo';

-- ============================================
-- INFORMACIÓN PARA PROBAR:
-- ============================================
-- ESTUDIANTE:
--   - Email: iswbdje@gmail.com
--   - Password: (del dump, pero puedes usar: password)
--   - Estudiante ID: 21
--   - Nombre: laura looez
--   - Grado: 5° (actualizado)
--   - Sección: D (actualizado)
--
-- PROFESOR:
--   - Email: maestro@colegio.com
--   - Password: (del dump, pero puedes usar: password)
--   - Profesor ID: 7
--   - Nombre: Maestro Prueba
--
-- MATERIA:
--   - ID: 14
--   - Nombre: "2026"
--   - Grado: 5°
--   - Sección: D
--   - Fecha fin: HOY (actualizada)
--
-- NOTA:
--   - Promedio calculado: (45+50+40+55)/4 = 47.50 (REPROBADO)
-- ============================================

