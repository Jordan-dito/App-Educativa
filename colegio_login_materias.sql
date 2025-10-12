-- Base de datos optimizada para Inicio de Sesión y Materias
-- Estructura normalizada sin redundancias

CREATE DATABASE IF NOT EXISTS colegio_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE colegio_db;

-- ==============================================
-- TABLA DE USUARIOS (ENTIDAD ÚNICA PARA LOGIN)
-- ==============================================

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol ENUM('admin', 'profesor', 'estudiante') NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==============================================
-- TABLA DE ESTUDIANTES
-- ==============================================

CREATE TABLE estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    grado VARCHAR(10) NOT NULL,
    seccion VARCHAR(5) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_nacimiento DATE,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==============================================
-- TABLA DE PROFESORES
-- ==============================================

CREATE TABLE profesores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_contratacion DATE,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==============================================
-- TABLA DE MATERIAS
-- ==============================================

CREATE TABLE materias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    grado VARCHAR(10) NOT NULL,
    seccion VARCHAR(5) NOT NULL,
    profesor_id INT NOT NULL,
    año_academico YEAR NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE
);

-- ==============================================
-- TABLA DE INSCRIPCIONES (ESTUDIANTES EN MATERIAS)
-- ==============================================

CREATE TABLE inscripciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    materia_id INT NOT NULL,
    fecha_inscripcion DATE DEFAULT (CURRENT_DATE),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE,
    UNIQUE KEY estudiante_materia_unico (estudiante_id, materia_id)
);

-- ==============================================
-- CLAVES FORÁNEAS (DESPUÉS DE CREAR TODAS LAS TABLAS)
-- ==============================================

-- Agregar claves foráneas a estudiantes y profesores
ALTER TABLE estudiantes 
ADD CONSTRAINT fk_estudiantes_usuario 
FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE;

ALTER TABLE profesores 
ADD CONSTRAINT fk_profesores_usuario 
FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE;

-- ==============================================
-- ÍNDICES PARA RENDIMIENTO
-- ==============================================

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_estudiantes_usuario ON estudiantes(usuario_id);
CREATE INDEX idx_profesores_usuario ON profesores(usuario_id);
CREATE INDEX idx_estudiantes_grado ON estudiantes(grado);
CREATE INDEX idx_materias_profesor ON materias(profesor_id);
CREATE INDEX idx_materias_grado_seccion ON materias(grado, seccion);
CREATE INDEX idx_inscripciones_estudiante ON inscripciones(estudiante_id);
CREATE INDEX idx_inscripciones_materia ON inscripciones(materia_id);

-- ==============================================
-- DATOS DE PRUEBA
-- ==============================================

-- Insertar usuarios para inicio de sesión
INSERT INTO usuarios (email, password, rol) VALUES
('admin@colegio.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('miguel@colegio.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'profesor'),
('laura@colegio.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'profesor'),
('ana@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'estudiante'),
('pedro@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'estudiante');

-- Insertar estudiantes (con referencia a usuarios)
INSERT INTO estudiantes (usuario_id, nombre, apellido, grado, seccion, telefono, direccion, fecha_nacimiento) VALUES
(4, 'Ana', 'Martínez', '1°', 'A', '123456789', 'Calle 123', '2015-03-15'),
(5, 'Pedro', 'Rodríguez', '2°', 'B', '987654321', 'Avenida 456', '2014-07-22');

-- Insertar profesores (con referencia a usuarios)
INSERT INTO profesores (usuario_id, nombre, apellido, telefono, direccion, fecha_contratacion) VALUES
(2, 'Miguel', 'Torres', '111222333', 'Calle Profesores 123', '2020-02-15'),
(3, 'Laura', 'Jiménez', '222333444', 'Calle Academia 321', '2018-03-05');

-- Insertar materias
INSERT INTO materias (nombre, grado, seccion, profesor_id, año_academico) VALUES
('Matemáticas', '1°', 'A', 2, 2024),
('Historia', '1°', 'A', 1, 2024),
('Matemáticas', '2°', 'B', 2, 2024);

-- Inscribir estudiantes en materias
INSERT INTO inscripciones (estudiante_id, materia_id) VALUES
(1, 1), (1, 2), -- Ana en Matemáticas e Historia
(2, 3); -- Pedro en Matemáticas

-- ==============================================
-- VISTA PARA ESTUDIANTES CON SUS MATERIAS
-- ==============================================

CREATE VIEW vista_estudiantes_materias AS
SELECT 
    est.id as estudiante_id,
    CONCAT(est.nombre, ' ', est.apellido) as nombre_estudiante,
    est.grado,
    est.seccion,
    mat.nombre as nombre_materia,
    CONCAT(prof.nombre, ' ', prof.apellido) as nombre_profesor,
    ins.estado as estado_inscripcion
FROM estudiantes est
JOIN inscripciones ins ON est.id = ins.estudiante_id
JOIN materias mat ON ins.materia_id = mat.id
JOIN profesores prof ON mat.profesor_id = prof.id
WHERE ins.estado = 'activo';

-- ==============================================
-- MOSTRAR INFORMACIÓN
-- ==============================================

SHOW TABLES;
SELECT 'Usuarios para inicio de sesión:' as info;
SELECT id, email, rol FROM usuarios;
SELECT 'Estudiantes:' as info;
SELECT id, usuario_id, nombre, apellido, grado, seccion FROM estudiantes;
SELECT 'Profesores:' as info;
SELECT id, usuario_id, nombre, apellido FROM profesores;
SELECT 'Materias creadas:' as info;
SELECT COUNT(*) as total_materias FROM materias;
SELECT 'Inscripciones:' as info;
SELECT COUNT(*) as total_inscripciones FROM inscripciones;
