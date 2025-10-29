-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysql-hermanosfrios.alwaysdata.net
-- Generation Time: Oct 28, 2025 at 12:57 AM
-- Server version: 10.11.14-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hermanosfrios_sistema`
--

-- --------------------------------------------------------

--
-- Table structure for table `asistencia`
--

CREATE TABLE `asistencia` (
  `id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `estudiante_id` int(11) NOT NULL,
  `fecha_clase` date NOT NULL,
  `estado` enum('presente','ausente','tardanza') NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `fecha_registro` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `configuracion_materia`
--

CREATE TABLE `configuracion_materia` (
  `id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `año_academico` year(4) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `dias_clase` varchar(50) NOT NULL,
  `hora_clase` time DEFAULT NULL,
  `meta_asistencia` decimal(5,2) DEFAULT 80.00,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `configuracion_materia`
--

INSERT INTO `configuracion_materia` (`id`, `materia_id`, `año_academico`, `fecha_inicio`, `fecha_fin`, `dias_clase`, `hora_clase`, `meta_asistencia`, `estado`, `fecha_creacion`) VALUES
(1, 1, '2025', '2025-10-27', '2026-02-24', 'lunes,martes,miercoles,jueves,viernes', '08:00:00', 60.00, 'activo', '2025-10-26 22:52:50'),
(2, 2, '2025', '2025-10-26', '2026-02-23', 'lunes,martes', '09:00:00', 80.00, 'activo', '2025-10-26 23:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `estudiantes`
--

CREATE TABLE `estudiantes` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `grado` varchar(10) NOT NULL,
  `seccion` varchar(5) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `estudiantes`
--

INSERT INTO `estudiantes` (`id`, `usuario_id`, `nombre`, `apellido`, `grado`, `seccion`, `telefono`, `direccion`, `fecha_nacimiento`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 4, 'Ana', 'Martínez', '1°', 'A', '123456789', 'Calle 123', '2015-03-15', 'inactivo', '2025-10-07 01:51:00', '2025-10-19 06:57:22'),
(2, 5, 'Pedro', 'Rodríguez', '2°', 'B', '987654321', 'Avenida 456', '2014-07-22', 'activo', '2025-10-07 01:51:00', '2025-10-07 01:51:00'),
(3, 6, 'Juan', 'Pérez', '10', 'A', '1234567890', 'Calle 123, Ciudad', '2005-03-15', 'inactivo', '2025-10-12 05:56:36', '2025-10-19 07:04:42'),
(5, 8, 'Robert', 'Juan', '1°', 'A', '1234567890', 'kjdkshhsdjshdsdhds', '2009-10-15', 'inactivo', '2025-10-12 17:14:35', '2025-10-20 03:22:56'),
(6, 9, 'Luisa', 'asaaand', 'Preescolar', 'A', '0990122698', 'fddfddfdff', '2009-10-15', 'activo', '2025-10-12 17:29:07', '2025-10-12 17:29:07'),
(7, 10, 'Juan', 'Pérez', '10', 'A', '1234567890', 'Calle 123, Ciudad', '2005-03-15', 'inactivo', '2025-10-12 17:32:14', '2025-10-19 07:11:15'),
(8, 11, 'quevedo', 'hajmdbd', '1°', 'A', '0990122698', 'dssfsffff', '2010-10-15', 'inactivo', '2025-10-12 17:45:09', '2025-10-20 03:18:33'),
(9, 12, 'Mike', 'Towers', '1°', 'A', '0990122459', 'fffddfdffddf', '2010-10-15', 'inactivo', '2025-10-12 17:53:35', '2025-10-20 03:18:44'),
(10, 15, 'ray', 'hernades', '3°', 'D', '47603192', '3ra calle 1-85 colonia los llanos jocotenango', '2008-04-12', 'activo', '2025-10-13 15:39:32', '2025-10-23 16:42:04'),
(11, 17, 'Enrique', 'chali', '1°', 'B', '30828253', 'dfscdsas', '2008-09-16', 'activo', '2025-10-14 04:45:52', '2025-10-20 19:20:10'),
(12, 18, 'JORDAN', 'LAPO', '1°', 'A', '12324515', 'saa', '2000-10-29', 'activo', '2025-10-23 07:09:13', '2025-10-23 07:09:13'),
(13, 19, 'Dilan', 'Chalí', '1°', 'A', '47603192', 'antigua', '2005-10-05', 'activo', '2025-10-23 16:45:12', '2025-10-23 16:45:12'),
(14, 20, 'fernando', 'chali', '3°', 'A', '30828253', 'los llanos', '2015-10-26', 'activo', '2025-10-23 18:18:23', '2025-10-23 18:18:23'),
(15, 21, 'fabricio', 'chali', '3°', 'B', '59004008', 'jocotenango los llanos', '2010-10-26', 'activo', '2025-10-24 02:41:09', '2025-10-24 02:41:09'),
(16, 22, 'sostenes', 'chali', '3°', 'B', '30828283', 'jocotenango', '2009-10-26', 'activo', '2025-10-24 02:55:15', '2025-10-24 02:55:15'),
(17, 23, 'lupita', 'mutx', '2°', 'A', '30828253', 'victorias', '2010-04-14', 'activo', '2025-10-24 04:05:28', '2025-10-24 04:05:28'),
(18, 24, 'gerson', 'sec', '3°', 'A', '33008649', 'sumpango', '2013-10-29', 'activo', '2025-10-26 15:05:56', '2025-10-26 15:05:56'),
(19, 25, 'luis', 'angel', '3°', 'B', '78945645', 'los llanos', '2014-10-23', 'activo', '2025-10-26 16:31:41', '2025-10-26 16:31:41'),
(20, 28, 'Stiven', 'Lima', '3°', 'A', '12345678', 'Mani', '2025-10-26', 'activo', '2025-10-26 22:04:04', '2025-10-26 22:04:04');

-- --------------------------------------------------------

--
-- Table structure for table `inscripciones`
--

CREATE TABLE `inscripciones` (
  `id` int(11) NOT NULL,
  `estudiante_id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `fecha_inscripcion` date DEFAULT curdate(),
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inscripciones`
--

INSERT INTO `inscripciones` (`id`, `estudiante_id`, `materia_id`, `fecha_inscripcion`, `estado`, `fecha_creacion`) VALUES
(4, 11, 3, '2025-10-23', 'inactivo', '2025-10-23 06:31:30'),
(5, 2, 3, '2025-10-23', 'inactivo', '2025-10-23 06:33:51'),
(6, 12, 2, '2025-10-23', 'inactivo', '2025-10-23 07:09:32'),
(7, 10, 2, '2025-10-23', 'inactivo', '2025-10-23 16:48:28'),
(8, 10, 3, '2025-10-23', 'inactivo', '2025-10-23 16:53:07'),
(9, 14, 3, '2025-10-23', 'inactivo', '2025-10-23 18:19:03'),
(10, 14, 2, '2025-10-23', 'inactivo', '2025-10-23 18:19:51'),
(11, 15, 2, '2025-10-24', 'inactivo', '2025-10-24 02:41:48'),
(12, 15, 3, '2025-10-24', 'activo', '2025-10-24 02:42:18'),
(13, 16, 2, '2025-10-24', 'activo', '2025-10-24 02:55:58'),
(14, 16, 3, '2025-10-24', 'activo', '2025-10-24 02:56:13'),
(15, 16, 5, '2025-10-24', 'activo', '2025-10-24 03:57:48'),
(16, 15, 5, '2025-10-24', 'inactivo', '2025-10-24 04:01:36'),
(17, 17, 3, '2025-10-24', 'inactivo', '2025-10-24 04:12:01'),
(18, 12, 3, '2025-10-25', 'inactivo', '2025-10-25 00:56:08'),
(19, 10, 10, '2025-10-25', 'activo', '2025-10-25 17:43:21'),
(20, 10, 5, '2025-10-25', 'activo', '2025-10-25 17:45:03'),
(21, 10, 8, '2025-10-25', 'activo', '2025-10-25 17:45:11'),
(25, 10, 9, '2025-10-25', 'activo', '2025-10-25 17:45:36'),
(29, 10, 6, '2025-10-25', 'activo', '2025-10-25 17:46:11'),
(35, 10, 11, '2025-10-25', 'activo', '2025-10-25 17:48:51'),
(36, 19, 11, '2025-10-26', 'activo', '2025-10-26 16:32:56'),
(37, 19, 6, '2025-10-26', 'activo', '2025-10-26 16:38:19'),
(38, 19, 5, '2025-10-26', 'activo', '2025-10-26 16:38:56'),
(39, 16, 12, '2025-10-26', 'activo', '2025-10-26 16:45:02'),
(40, 20, 6, '2025-10-26', 'activo', '2025-10-26 22:05:47'),
(41, 20, 10, '2025-10-26', 'activo', '2025-10-26 22:07:28'),
(42, 20, 5, '2025-10-26', 'activo', '2025-10-26 22:07:35'),
(43, 10, 12, '2025-10-27', 'activo', '2025-10-27 15:57:55');

-- --------------------------------------------------------

--
-- Table structure for table `materias`
--

CREATE TABLE `materias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `grado` varchar(10) NOT NULL,
  `seccion` varchar(5) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `año_academico` year(4) NOT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `materias`
--

INSERT INTO `materias` (`id`, `nombre`, `grado`, `seccion`, `profesor_id`, `año_academico`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'Matemáticas', '1°', 'A', 2, '2024', 'inactivo', '2025-10-07 01:51:01', '2025-10-20 21:58:13'),
(2, 'HistoriaAA', '1°', 'A', 1, '2024', 'activo', '2025-10-07 01:51:01', '2025-10-20 21:59:14'),
(3, 'programación', '2°', 'A', 5, '2024', 'activo', '2025-10-07 01:51:01', '2025-10-23 18:22:38'),
(4, 'CARNAÑ', '1°', 'A', 2, '2025', 'inactivo', '2025-10-16 03:21:06', '2025-10-20 21:58:13'),
(5, 'ciencias naturales', '3°', 'A', 5, '2025', 'activo', '2025-10-24 03:56:21', '2025-10-24 03:56:21'),
(6, 'matemática', '3°', 'A', 5, '2025', 'activo', '2025-10-24 04:06:41', '2025-10-24 04:06:41'),
(7, 'matema', '3°', 'A', 5, '2025', 'inactivo', '2025-10-24 04:07:02', '2025-10-24 04:07:08'),
(8, 'ingles', '3°', 'A', 5, '2025', 'activo', '2025-10-24 04:07:49', '2025-10-24 04:07:49'),
(9, 'prueba', '1°', 'A', 2, '2025', 'activo', '2025-10-25 00:49:51', '2025-10-25 00:49:51'),
(10, 'gastonomia', '1°', 'A', 5, '2025', 'activo', '2025-10-25 17:36:44', '2025-10-27 15:46:52'),
(11, 'contabilidad', '3°', 'C', 2, '2025', 'activo', '2025-10-25 17:48:23', '2025-10-25 17:48:23'),
(12, 'sociales', '3°', 'C', 2, '2025', 'activo', '2025-10-26 16:43:09', '2025-10-26 16:43:09');

-- --------------------------------------------------------

--
-- Table structure for table `profesores`
--

CREATE TABLE `profesores` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `profesores`
--

INSERT INTO `profesores` (`id`, `usuario_id`, `nombre`, `apellido`, `telefono`, `direccion`, `fecha_contratacion`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 2, 'María Elena', 'González López', '0987654321', 'Avenida Principal 456', '2020-01-15', 'activo', '2025-10-07 01:51:01', '2025-10-20 21:32:52'),
(2, 3, 'Laura', 'Jiménez', '222333444', 'Calle Academia 321', '2018-03-05', 'activo', '2025-10-07 01:51:01', '2025-10-07 01:51:01'),
(3, 13, 'María', 'García', '11111111', 'fgfg', '2024-01-15', 'activo', '2025-10-12 18:29:57', '2025-10-20 21:47:17'),
(4, 14, 'paulo', 'londra', '0990122698', 'hsdjdshdsjdhd', '2025-10-01', 'activo', '2025-10-12 18:39:31', '2025-10-12 18:39:31'),
(5, 16, 'Brandon', 'Mendez', '3353260100', '1ra calle 1-07 pastores', '1992-04-01', 'activo', '2025-10-13 15:43:58', '2025-10-13 15:43:58'),
(7, 27, 'Maestro ', 'Prueba', '555-1234', 'Calle Principal 123', '2025-10-26', 'activo', '2025-10-26 22:00:43', '2025-10-26 22:00:43'),
(8, 29, 'Lisbeth', 'dddd', '12345678', 'dssdsddsds', '2025-10-02', 'activo', '2025-10-26 22:06:20', '2025-10-26 22:06:20');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol` enum('admin','profesor','estudiante') NOT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id`, `email`, `password`, `rol`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'admin@colegio.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'activo', '2025-10-07 01:51:00', '2025-10-07 01:51:00'),
(2, 'miguel@colegio.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'profesor', 'activo', '2025-10-07 01:51:00', '2025-10-07 01:51:00'),
(3, 'laura@colegio.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'profesor', 'activo', '2025-10-07 01:51:00', '2025-10-07 01:51:00'),
(4, 'ana@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'estudiante', 'inactivo', '2025-10-07 01:51:00', '2025-10-19 06:57:22'),
(5, 'pedro@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'estudiante', 'activo', '2025-10-07 01:51:00', '2025-10-07 01:51:00'),
(6, 'juan.perez@estudiante.com', '$2y$10$0QGNTjpshBi66vh8P76IlOO5f8237mwfnNJcPt5q5wdTABWDf3KeC', 'estudiante', 'inactivo', '2025-10-12 05:56:36', '2025-10-19 07:04:42'),
(8, '2645353@gmail.com', '$2y$10$79O1yDGhC0WNjuUNxjNkOOD7lbmvlMAkXBA3dL2quQQzShdzxv6vq', 'estudiante', 'inactivo', '2025-10-12 17:14:35', '2025-10-20 03:22:56'),
(9, '1245@gmail.com', '$2y$10$XHLciDM0vNip5HFDSYgpk.iKJY9Wc7N0TEROwkPJwxZCcfIPkAUZC', 'estudiante', 'activo', '2025-10-12 17:29:07', '2025-10-12 17:29:07'),
(10, 'hola@estudiante.com', '$2y$10$38oRPyqRTT6fZ2Ts7XYEBe.h18VA./35DGyYvuRoS1Wcq/S69b6TC', 'estudiante', 'inactivo', '2025-10-12 17:32:14', '2025-10-19 07:11:15'),
(11, '123@gmail.com', '$2y$10$7y5cE5ukr4NAi.zsRQ7NkeVS9DzQQmOvLabERyhemP/N0yp.32z86', 'estudiante', 'inactivo', '2025-10-12 17:45:09', '2025-10-20 03:18:33'),
(12, 'adksd@gmail.com', '$2y$10$s.nIMDFiJmosCgfXS8QJLuXTsx7UhLj.9KrF65mz44Jz.Rpp4eT2e', 'estudiante', 'inactivo', '2025-10-12 17:53:35', '2025-10-20 03:18:44'),
(13, 'maria.garcia@colegio.edu', '$2y$10$LVMN/MaS9c6tten1TK40dO3VVHAUEDDz9xr.YBv37Jogai1gkLSTy', 'profesor', 'activo', '2025-10-12 18:29:57', '2025-10-12 18:29:57'),
(14, 'nieve@gmail.com', '$2y$10$WrxyQ3VRk.jnn1F63bro4uiQ1VHPNVZo/TfDqDEICK30Fm7sQCHjS', 'profesor', 'activo', '2025-10-12 18:39:31', '2025-10-12 18:39:31'),
(15, 'Brandon@coleguio.com', '$2y$10$ltHE2.atNLJw6Xyr0M.oNOb.Ra14CUcMcQE1BlyRwMKukG5x4hX5.', 'estudiante', 'activo', '2025-10-13 15:39:32', '2025-10-13 15:39:32'),
(16, 'mendez@gmail.com', '$2y$10$FCTVTk/iGq4uBUTUJkJX4OiGLd9Z8Eq7qg5ayaMDB3fNfew09mMwq', 'profesor', 'activo', '2025-10-13 15:43:58', '2025-10-13 15:43:58'),
(17, 'enrique14mutz@gmail.com', '$2y$10$jXoFSs0fJN0W8h./WYe6TOQd6tGz3hOX1MEjkZlVq.6/47Sp19paS', 'estudiante', 'activo', '2025-10-14 04:45:52', '2025-10-14 04:45:52'),
(18, 'jordanmalave18@gmail.com', '$2y$10$mqR6drE0Lpx8TEM8W3uZN.87poSCVJQHoxj6vH79xfBXso1up7XC6', 'estudiante', 'activo', '2025-10-23 07:09:13', '2025-10-23 07:09:13'),
(19, 'dilan@colegio.com', '$2y$10$n7eMzVXjgfvLFaKKOXAFpOHU07TVFZf.bZSE8RCQmBQ84xlHyCrTq', 'estudiante', 'activo', '2025-10-23 16:45:12', '2025-10-23 16:45:12'),
(20, 'fernando@colegio.com', '$2y$10$Xh8s63rNNR9Qz1v6Se4XDuoNQDo42kPh/HDSZlGNnUBLqnavL0Llq', 'estudiante', 'activo', '2025-10-23 18:18:23', '2025-10-23 18:18:23'),
(21, 'Fabricio@colegio.com', '$2y$10$HtJ7sPRrJjnF0YSiJbPgCuRpcULALfsea9JTWGOc534klq6EvMxWK', 'estudiante', 'activo', '2025-10-24 02:41:09', '2025-10-24 02:41:09'),
(22, 'sostenes@colegio.com', '$2y$10$oyJQ3aVq8VY2uYw7mKJDpukMh5hBO77ZRCiNeewCL9JRKSn4.97nm', 'estudiante', 'activo', '2025-10-24 02:55:15', '2025-10-24 02:55:15'),
(23, 'lupita@colegio.com', '$2y$10$xaN2HBtPlicwarQgFt0PFeh2lfaKGrHCKMk9H51XHQDKaCaS2wYiW', 'estudiante', 'activo', '2025-10-24 04:05:28', '2025-10-24 04:05:28'),
(24, 'gerson@colegio.com', '$2y$10$dxpwrpLVv4vamQjr2IrlsurwcsQHGjDH55Q8SOC3dFQGcjITcoz/O', 'estudiante', 'activo', '2025-10-26 15:05:56', '2025-10-26 15:05:56'),
(25, 'luis@colegio.com', '$2y$10$H7SpvCjlPX0mBEqXZWtN8OGc8hHhtOtTlZfZO8rnwyapD2H0vXEfy', 'estudiante', 'activo', '2025-10-26 16:31:41', '2025-10-26 16:31:41'),
(27, 'maestro@colegio.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'profesor', 'activo', '2025-10-26 22:00:43', '2025-10-26 22:00:43'),
(28, 'pruebastiven@gmail.com', '$2y$10$qSnCDkgl2rMdCqwVVzp2.Og1oALELNDe6ldlVBFi6OV8B5zT3Bwt.', 'estudiante', 'activo', '2025-10-26 22:04:04', '2025-10-26 22:04:04'),
(29, 'lisbet@gmail.com', '$2y$10$J9KGkVlgzwgu31CBL6Gt0eN9pZWndaIAtaK35giHnmtGHHGCWdrqi', 'profesor', 'activo', '2025-10-26 22:06:20', '2025-10-26 22:06:20');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vista_estudiantes_materias`
-- (See below for the actual view)
--
CREATE TABLE `vista_estudiantes_materias` (
`estudiante_id` int(11)
,`nombre_estudiante` varchar(101)
,`grado` varchar(10)
,`seccion` varchar(5)
,`nombre_materia` varchar(100)
,`nombre_profesor` varchar(101)
,`estado_inscripcion` enum('activo','inactivo')
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `asistencia`
--
ALTER TABLE `asistencia`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `asistencia_unica` (`materia_id`,`estudiante_id`,`fecha_clase`),
  ADD KEY `profesor_id` (`profesor_id`),
  ADD KEY `idx_asistencia_materia_fecha` (`materia_id`,`fecha_clase`),
  ADD KEY `idx_asistencia_estudiante` (`estudiante_id`);

--
-- Indexes for table `configuracion_materia`
--
ALTER TABLE `configuracion_materia`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `materia_año_unico` (`materia_id`,`año_academico`),
  ADD KEY `idx_configuracion_materia` (`materia_id`);

--
-- Indexes for table `estudiantes`
--
ALTER TABLE `estudiantes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_estudiantes_usuario` (`usuario_id`),
  ADD KEY `idx_estudiantes_grado` (`grado`);

--
-- Indexes for table `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `estudiante_materia_unico` (`estudiante_id`,`materia_id`),
  ADD KEY `idx_inscripciones_estudiante` (`estudiante_id`),
  ADD KEY `idx_inscripciones_materia` (`materia_id`);

--
-- Indexes for table `materias`
--
ALTER TABLE `materias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_materias_profesor` (`profesor_id`),
  ADD KEY `idx_materias_grado_seccion` (`grado`,`seccion`);

--
-- Indexes for table `profesores`
--
ALTER TABLE `profesores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_profesores_usuario` (`usuario_id`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_usuarios_email` (`email`),
  ADD KEY `idx_usuarios_rol` (`rol`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `asistencia`
--
ALTER TABLE `asistencia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `configuracion_materia`
--
ALTER TABLE `configuracion_materia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `estudiantes`
--
ALTER TABLE `estudiantes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `inscripciones`
--
ALTER TABLE `inscripciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `materias`
--
ALTER TABLE `materias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `profesores`
--
ALTER TABLE `profesores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

-- --------------------------------------------------------

--
-- Structure for view `vista_estudiantes_materias`
--
DROP TABLE IF EXISTS `vista_estudiantes_materias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`342080`@`%` SQL SECURITY DEFINER VIEW `vista_estudiantes_materias`  AS SELECT `est`.`id` AS `estudiante_id`, concat(`est`.`nombre`,' ',`est`.`apellido`) AS `nombre_estudiante`, `est`.`grado` AS `grado`, `est`.`seccion` AS `seccion`, `mat`.`nombre` AS `nombre_materia`, concat(`prof`.`nombre`,' ',`prof`.`apellido`) AS `nombre_profesor`, `ins`.`estado` AS `estado_inscripcion` FROM (((`estudiantes` `est` join `inscripciones` `ins` on(`est`.`id` = `ins`.`estudiante_id`)) join `materias` `mat` on(`ins`.`materia_id` = `mat`.`id`)) join `profesores` `prof` on(`mat`.`profesor_id` = `prof`.`id`)) WHERE `ins`.`estado` = 'activo' ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `asistencia`
--
ALTER TABLE `asistencia`
  ADD CONSTRAINT `asistencia_ibfk_1` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `asistencia_ibfk_2` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `asistencia_ibfk_3` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `configuracion_materia`
--
ALTER TABLE `configuracion_materia`
  ADD CONSTRAINT `configuracion_materia_ibfk_1` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `estudiantes`
--
ALTER TABLE `estudiantes`
  ADD CONSTRAINT `fk_estudiantes_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `materias`
--
ALTER TABLE `materias`
  ADD CONSTRAINT `materias_ibfk_1` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `profesores`
--
ALTER TABLE `profesores`
  ADD CONSTRAINT `fk_profesores_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
