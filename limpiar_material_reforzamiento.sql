-- ============================================
-- SCRIPT PARA LIMPIAR MATERIAL DE REFORZAMIENTO
-- Elimina materiales existentes y campos de archivo
-- ============================================

USE hermanosfrios_sistema;

-- 1. BORRAR TODOS LOS MATERIALES EXISTENTES
-- ⚠️ CUIDADO: Esta consulta elimina TODOS los materiales de la tabla
DELETE FROM material_reforzamiento;

-- Verificar que se borraron (debe mostrar 0 registros)
SELECT COUNT(*) AS materiales_restantes FROM material_reforzamiento;

-- 2. REINICIAR EL AUTO_INCREMENT
-- Esto hace que el próximo ID sea 1 nuevamente
ALTER TABLE material_reforzamiento AUTO_INCREMENT = 1;

-- ============================================
-- 3. ELIMINAR CAMPOS DE ARCHIVO (si solo usas texto y link)
-- ============================================

-- Eliminar campo archivo_nombre
ALTER TABLE material_reforzamiento 
DROP COLUMN archivo_nombre;

-- Eliminar campo archivo_ruta
ALTER TABLE material_reforzamiento 
DROP COLUMN archivo_ruta;

-- Eliminar campo archivo_tipo
ALTER TABLE material_reforzamiento 
DROP COLUMN archivo_tipo;

-- Eliminar campo archivo_tamaño
ALTER TABLE material_reforzamiento 
DROP COLUMN archivo_tamaño;

-- ============================================
-- 4. OPCIONAL: Actualizar enum de tipo_contenido
-- Elimina 'imagen' y 'pdf', deja solo 'texto', 'link', 'video'
-- ============================================

-- Primero actualizar cualquier registro que tenga 'imagen' o 'pdf' a 'texto' (si los hubiera)
-- (Ya borramos todos, pero por si acaso quedan)
UPDATE material_reforzamiento 
SET tipo_contenido = 'texto' 
WHERE tipo_contenido IN ('imagen', 'pdf');

-- Modificar el enum para quitar 'imagen' y 'pdf'
ALTER TABLE material_reforzamiento 
MODIFY COLUMN tipo_contenido ENUM('texto', 'link', 'video') NOT NULL DEFAULT 'texto';

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Ver estructura actualizada de la tabla
DESCRIBE material_reforzamiento;

-- Verificar que los campos se eliminaron correctamente
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'hermanosfrios_sistema' 
AND TABLE_NAME = 'material_reforzamiento'
ORDER BY ORDINAL_POSITION;

