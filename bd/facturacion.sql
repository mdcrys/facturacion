-- phpMyAdmin SQL Dump
-- version 4.0.9
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-04-2021 a las 02:01:57
-- Versión del servidor: 5.5.34
-- Versión de PHP: 5.4.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `facturacion`
--
CREATE DATABASE IF NOT EXISTS `facturacion` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `facturacion`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `actualizar_precio_producto`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto`(n_cantidad int, n_precio decimal(10,2), codigo int)
BEGIN
    	DECLARE nueva_existencia int;
        DECLARE nuevo_total  decimal(10,2);
        DECLARE nuevo_precio decimal(10,2);
        
        DECLARE cant_actual int;
        DECLARE pre_actual decimal(10,2);
        
        DECLARE actual_existencia int;
        DECLARE actual_precio decimal(10,2);
                
        SELECT precio,existencia INTO actual_precio,actual_existencia FROM producto WHERE codproducto = codigo;
        SET nueva_existencia = actual_existencia + n_cantidad;
        SET nuevo_total = (actual_existencia * actual_precio) + (n_cantidad * n_precio);
        SET nuevo_precio = nuevo_total / nueva_existencia;
        
        UPDATE producto SET existencia = nueva_existencia, precio = nuevo_precio WHERE codproducto = codigo;
        
        SELECT nueva_existencia,nuevo_precio;
        
    END$$

DROP PROCEDURE IF EXISTS `add_detalle_temp`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp`(IN `codigo` INT, IN `cantidad` INT, IN `token_user` VARCHAR(50))
BEGIN
		DECLARE precio_actual decimal(10,2);
		SELECT precio INTO precio_actual FROM producto WHERE codproducto = codigo;
		
		INSERT INTO detalle_temp(token_user, codproducto, cantidad, precio_venta) VALUES(token_user, codigo, cantidad,precio_actual);
		
		SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.precio_venta FROM detalle_temp tmp 
		INNER JOIN producto p
		ON tmp.codproducto = p.codproducto
		WHERE tmp.token_user = token_user;
		
END$$

DROP PROCEDURE IF EXISTS `anular_factura`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `anular_factura`(IN `no_factura` INT)
BEGIN
		DECLARE existe_factura int;
		DECLARE registros int;
		DECLARE	a int;
		
		DECLARE cod_producto int;
		DECLARE cant_producto int;
		DECLARE	existencia_actual int;
		DECLARE	nueva_existencia int;
		
	

		SET existe_factura = (SELECT COUNT(*) FROM factura WHERE nofactura = no_factura and estatus = 1);
		
		IF existe_factura > 0 THEN
			CREATE TEMPORARY TABLE tbl_tmp(
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
				
				SET a = 1;
				
				SET registros = (SELECT COUNT(*) FROM detallefactura WHERE nofactura = no_factura);
				
				IF registros > 0 THEN
					
					INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detallefactura WHERE nofactura = no_factura;

					WHILE a <= registros DO
							SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
							SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
							SET nueva_existencia = existencia_actual + cant_producto;
							UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
							
							SET a=a+1;
					END WHILE;
					
					UPDATE factura SET estatus = 2 WHERE nofactura = no_factura;
					DROP TABLE tbl_tmp;
					SELECt * FROM factura WHERE nofactura = no_factura;
				END IF;

		ELSE
			SELECT 0 factura;
		END IF;
	END$$

DROP PROCEDURE IF EXISTS `dataDashboard`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dataDashboard`()
BEGIN

		DECLARE usuarios int;
		DECLARE clientes int;
		DECLARE proveedores int;
		DECLARE productos int;
		DECLARE ventas int;

		SELECT COUNT(*) INTO  usuarios from usuario WHERE status !=10;
        SELECT COUNT(*) INTO  clientes from cliente WHERE estatus !=10;
        SELECT COUNT(*) INTO  proveedores from proveedor WHERE estatus !=10;
		SELECT COUNT(*) INTO  productos from producto WHERE estatus !=10;
        SELECT COUNT(*) INTO  ventas from factura WHERE fecha > CURDATE() AND estatus != 10;
		
		SELECT usuarios,clientes,proveedores,productos,ventas;
		
	END$$

DROP PROCEDURE IF EXISTS `del_detalle_temp`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp`(id_detalle int, token varchar(50))
BEGIN
		DELETE FROM detalle_temp WHERE correlativo = id_detalle;

		SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.precio_venta FROM detalle_temp tmp 
		INNER JOIN producto p
		ON tmp.codproducto = p.codproducto
		WHERE tmp.token_user = token;
	END$$

DROP PROCEDURE IF EXISTS `procesar_venta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta`(IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50))
BEGIN
		DECLARE factura INT;

		DECLARE registros INT;

		DECLARE total DECIMAL(10,2);

		DECLARE nueva_existencia int;
		DECLARE	existencia_actual int;
		DECLARE tmp_cod_producto int;
		DECLARE	tmp_cant_producto int;
		DECLARE a int;
		SET a = 1;
		
		CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
        	id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            cod_prod BIGINT,
            cant_prod int);
	
		SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);

		IF registros > 0 THEN
			INSERT INTO tbl_tmp_tokenuser(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE token_user = token;

			INSERT INTO factura(usuario,codcliente) VALUES(cod_usuario, cod_cliente);
			SET factura = LAST_INSERT_ID();

			INSERT INTO detallefactura(nofactura,codproducto,cantidad,precio_venta) SELECT(factura) as nofactura, codproducto,cantidad,precio_venta FROM detalle_temp WHERE 
token_user = token;
		WHILE a <= registros DO
			SELECT cod_prod,cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;
			SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = tmp_cod_producto;

			SET nueva_existencia = existencia_actual - tmp_cant_producto;
			UPDATE producto SET existencia = nueva_existencia WHERE codproducto = tmp_cod_producto;

			SET a=a+1;
		END WHILE;

		SET total = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);
		UPDATE factura SET totalfactura = total WHERE nofactura = factura;
		DELETE FROM detalle_temp WHERE token_user = token;
		TRUNCATE TABLE tbl_tmp_tokenuser;
		SELECT * FROM factura WHERE nofactura = factura;
	
	ELSE
	
	SELECT 0;
	END IF;
		
	END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE IF NOT EXISTS `cliente` (
  `idcliente` int(11) NOT NULL AUTO_INCREMENT,
  `nit` int(11) DEFAULT NULL,
  `nombre` varchar(80) DEFAULT NULL,
  `telefono` int(11) DEFAULT NULL,
  `direccion` text,
  `dateadd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idcliente`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- RELACIONES PARA LA TABLA `cliente`:
--   `usuario_id`
--       `usuario` -> `idusuario`
--

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idcliente`, `nit`, `nombre`, `telefono`, `direccion`, `dateadd`, `usuario_id`, `estatus`) VALUES
(1, 111, 'Puerto el sol', 31262, 'Puerto el sol', '0000-00-00 00:00:00', 1, 1),
(2, 222334456, 'Pruweb', 23423, 'el mercado', '0000-00-00 00:00:00', 1, 1),
(3, 12341234, 'qwer', 1234, 'qewrqwer', '0000-00-00 00:00:00', 1, 1),
(4, 2147483647, 'ertewrtertwert', 2147483647, 'wertwert', '0000-00-00 00:00:00', 1, 1),
(5, 1414141, 'EJEMPLO', 1231234, 'LA CACOLO', '0000-00-00 00:00:00', 3, 1),
(6, 123, 'prueba', 123456, 'latacunga', '0000-00-00 00:00:00', 1, 1),
(7, 123, 'prueba 2', 1, 'prueba 3', '0000-00-00 00:00:00', 1, 0),
(8, 1234, 'Juan Perez', 9999, 'Quito', '2020-04-03 14:57:38', 1, 1),
(9, 12345, 'Leonardo Dicarpio', 666, 'El aviador', '2020-04-03 14:58:39', 1, 1),
(10, 1233456, 'Kelly', 9999, 'Archidona', '2020-04-03 15:05:51', 1, 1),
(12, 0, 'jemplo', 999, 'ejemplo', '0000-00-00 00:00:00', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--
-- Creación: 31-03-2020 a las 21:25:20
--

DROP TABLE IF EXISTS `configuracion`;
CREATE TABLE IF NOT EXISTS `configuracion` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `nit` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `telefono` bigint(20) NOT NULL,
  `email` varchar(200) NOT NULL,
  `direccion` text NOT NULL,
  `iva` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `iva`) VALUES
(1, '23452345', 'MDCRYS', 'JUAN y ASOCIADOS', 234234, 'mdcrys@mail.com', 'calzada la paz', '12.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `detallefactura`;
CREATE TABLE IF NOT EXISTS `detallefactura` (
  `correlativo` bigint(11) NOT NULL AUTO_INCREMENT,
  `nofactura` bigint(11) DEFAULT NULL,
  `codproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`correlativo`),
  KEY `codproducto` (`codproducto`),
  KEY `nofactura` (`nofactura`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=34 ;

--
-- RELACIONES PARA LA TABLA `detallefactura`:
--   `codproducto`
--       `producto` -> `codproducto`
--

--
-- Volcado de datos para la tabla `detallefactura`
--

INSERT INTO `detallefactura` (`correlativo`, `nofactura`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(1, 1, 1, 1, '18.23'),
(2, 1, 2, 1, '1500.00'),
(3, 1, 3, 1, '4.33'),
(4, 2, 1, 1, '18.23'),
(5, 2, 2, 1, '1500.00'),
(6, 2, 3, 1, '4.33'),
(7, 3, 1, 1, '18.23'),
(8, 3, 3, 1, '4.33'),
(10, 4, 8, 1, '2.00'),
(11, 4, 10, 1, '2000.00'),
(13, 5, 1, 1, '18.23'),
(14, 6, 11, 1, '1.00'),
(15, 6, 13, 1, '1.00'),
(17, 7, 1, 1, '18.23'),
(18, 8, 1, 1, '18.23'),
(19, 9, 3, 1, '4.33'),
(20, 10, 1, 1, '18.23'),
(21, 11, 1, 1, '18.23'),
(22, 12, 1, 1, '18.23'),
(23, 13, 1, 1, '18.23'),
(24, 14, 1, 1, '18.23'),
(25, 15, 1, 1, '18.23'),
(26, 16, 1, 1, '18.23'),
(27, 16, 2, 1, '1500.00'),
(29, 17, 1, 1, '18.23'),
(30, 17, 2, 8, '1500.00'),
(32, 18, 1, 95, '18.23'),
(33, 18, 2, 90, '1500.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--
-- Creación: 04-04-2020 a las 02:56:31
--

DROP TABLE IF EXISTS `detalle_temp`;
CREATE TABLE IF NOT EXISTS `detalle_temp` (
  `correlativo` int(11) NOT NULL AUTO_INCREMENT,
  `token_user` varchar(50) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  PRIMARY KEY (`correlativo`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Volcado de datos para la tabla `detalle_temp`
--

INSERT INTO `detalle_temp` (`correlativo`, `token_user`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(1, 'c4ca4238a0b923820dcc509a6f75849b', 1, 1, '18.23'),
(2, 'c4ca4238a0b923820dcc509a6f75849b', 2, 1, '1500.00'),
(3, 'c4ca4238a0b923820dcc509a6f75849b', 14, 1, '50.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `entradas`;
CREATE TABLE IF NOT EXISTS `entradas` (
  `correlativo` int(11) NOT NULL AUTO_INCREMENT,
  `codproducto` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  PRIMARY KEY (`correlativo`),
  KEY `codproducto` (`codproducto`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=35 ;

--
-- RELACIONES PARA LA TABLA `entradas`:
--   `codproducto`
--       `producto` -> `codproducto`
--

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`correlativo`, `codproducto`, `fecha`, `cantidad`, `precio`, `usuario_id`) VALUES
(1, 1, '0000-00-00 00:00:00', 150, '110.00', 1),
(2, 2, '0000-00-00 00:00:00', 100, '1500.00', 1),
(3, 3, '0000-00-00 00:00:00', 0, '7.00', 1),
(4, 4, '0000-00-00 00:00:00', 0, '7.00', 1),
(5, 5, '0000-00-00 00:00:00', 0, '2.00', 1),
(6, 6, '0000-00-00 00:00:00', 0, '2.00', 1),
(7, 7, '0000-00-00 00:00:00', 4, '4.00', 1),
(8, 8, '0000-00-00 00:00:00', 1, '2.00', 1),
(9, 9, '0000-00-00 00:00:00', 100, '1500.00', 1),
(10, 10, '2020-03-22 19:57:27', 8, '2000.00', 1),
(11, 11, '2020-03-22 20:53:46', 1, '1.00', 1),
(12, 12, '2020-03-22 20:54:03', 1, '2.00', 1),
(13, 13, '2020-03-22 21:03:01', 1, '1.00', 1),
(14, 10, '2020-03-25 19:25:52', 1, '13.00', 1),
(15, 10, '2020-03-28 01:48:15', 1, '8.00', 1),
(16, 10, '2020-03-28 01:52:33', 1, '8.00', 1),
(18, 1, '2020-03-28 04:55:23', 100, '10.00', 1),
(19, 1, '2020-03-28 05:03:08', 100, '10.00', 1),
(20, 1, '2020-03-28 05:04:57', 100, '10.00', 1),
(21, 1, '2020-03-28 05:08:40', 100, '10.00', 1),
(22, 1, '2020-03-28 05:09:25', 100, '10.00', 1),
(23, 1, '2020-03-28 05:13:09', 3, '1.00', 1),
(24, 1, '2020-03-29 02:31:26', 2, '5.00', 1),
(25, 1, '2020-03-29 02:51:57', 100, '140.00', 1),
(26, 1, '2020-03-29 02:57:19', 5, '12.00', 1),
(27, 1, '2020-03-29 02:57:44', 50, '10.00', 1),
(28, 1, '2020-03-29 02:59:57', 100, '0.00', 1),
(29, 1, '2020-03-29 03:00:15', 100, '1.00', 1),
(30, 3, '2020-03-29 03:02:47', 5, '5.00', 1),
(31, 4, '2020-03-29 03:09:41', 100, '3.00', 1),
(32, 3, '2020-03-29 03:17:59', 1, '1.00', 1),
(33, 12, '2020-06-12 02:49:54', 4, '1.00', 1),
(34, 14, '2020-06-12 02:51:37', 1, '50.00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `factura`;
CREATE TABLE IF NOT EXISTS `factura` (
  `nofactura` bigint(11) NOT NULL AUTO_INCREMENT,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario` int(11) DEFAULT NULL,
  `codcliente` int(11) DEFAULT NULL,
  `totalfactura` decimal(10,2) DEFAULT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`nofactura`),
  KEY `usuario` (`usuario`),
  KEY `codcliente` (`codcliente`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- RELACIONES PARA LA TABLA `factura`:
--   `usuario`
--       `usuario` -> `idusuario`
--   `codcliente`
--       `cliente` -> `idcliente`
--

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `estatus`) VALUES
(1, '2020-04-05 18:49:20', 1, 1, NULL, 1),
(2, '2020-04-05 18:59:38', 1, 1, '1522.56', 1),
(3, '2020-04-05 20:39:12', 1, 6, '22.56', 1),
(4, '2020-04-05 20:41:22', 1, 1, '2002.00', 1),
(5, '2020-04-05 21:08:09', 1, 1, '18.23', 1),
(6, '2020-04-06 00:13:06', 1, 10, '2.00', 2),
(7, '2020-04-06 00:14:24', 1, 6, '18.23', 2),
(8, '2020-04-06 00:15:09', 1, 6, '18.23', 2),
(9, '2020-04-06 00:28:19', 1, 6, '4.33', 1),
(10, '2020-04-06 00:30:32', 1, 6, '18.23', 1),
(11, '2020-04-06 00:36:58', 1, 6, '18.23', 2),
(12, '2020-04-06 00:38:32', 1, 6, '18.23', 2),
(13, '2020-04-06 00:40:56', 1, 6, '18.23', 2),
(14, '2020-04-06 00:44:26', 1, 6, '18.23', 2),
(15, '2020-04-06 00:55:20', 1, 6, '18.23', 2),
(16, '2020-04-11 01:11:24', 1, 6, '1518.23', 1),
(17, '2020-04-11 01:14:15', 1, 6, '12018.23', 1),
(18, '2020-04-11 01:16:24', 1, 6, '136731.85', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `producto`;
CREATE TABLE IF NOT EXISTS `producto` (
  `codproducto` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(100) DEFAULT NULL,
  `proveedor` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `existencia` int(11) DEFAULT NULL,
  `date_add` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1',
  `foto` text,
  PRIMARY KEY (`codproducto`),
  KEY `proveedor` (`proveedor`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;

--
-- RELACIONES PARA LA TABLA `producto`:
--   `proveedor`
--       `proveedor` -> `codproveedor`
--   `usuario_id`
--       `usuario` -> `idusuario`
--

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `descripcion`, `proveedor`, `precio`, `existencia`, `date_add`, `usuario_id`, `estatus`, `foto`) VALUES
(1, 'Mouse usb', 11, '18.23', 895, '0000-00-00 00:00:00', 1, 1, 'img_producto.png'),
(2, 'MOnitor lcd', 3, '1500.00', 90, '0000-00-00 00:00:00', 1, 1, 'img_producto.png'),
(3, 'Hamburguesa', 14, '4.33', 3, '0000-00-00 00:00:00', 1, 1, 'img_producto.png'),
(4, 'Hamburguesa', 14, '3.00', 100, '0000-00-00 00:00:00', 1, 1, 'img_producto.png'),
(5, 'asd', 7, '2.00', 0, '0000-00-00 00:00:00', 1, 0, 'img_producto.png'),
(6, 'asd', 7, '2.00', 0, '0000-00-00 00:00:00', 1, 0, 'img_producto.png'),
(7, 'sdf', 7, '4.00', 4, '0000-00-00 00:00:00', 1, 0, 'img_producto.png'),
(8, 'Hamburguesa', 14, '2.00', 0, '0000-00-00 00:00:00', 1, 0, 'img_e03588853160592b76ee792e9ff03be7.jpg'),
(9, NULL, 12, '1500.00', 100, '2020-03-22 19:56:24', 1, 0, 'img_producto.png'),
(10, 'lapto hp 500', 9, '2000.00', 7, '2020-03-22 19:57:27', 1, 1, 'img_e1ad022637e78daac861b39632564bea.jpg'),
(11, 'asd', 7, '1.00', 0, '2020-03-22 20:53:46', 1, 1, 'img_producto.png'),
(12, 'tacos', 3, '1.40', 5, '2020-03-22 20:54:03', 1, 1, 'img_producto.png'),
(13, 'asd', 7, '1.00', 0, '2020-03-22 21:03:01', 1, 1, 'img_producto.png'),
(14, 'Teclado', 7, '50.00', 1, '2020-06-12 02:51:37', 1, 1, 'img_producto.png');

--
-- Disparadores `producto`
--
DROP TRIGGER IF EXISTS `entradas_A_I`;
DELIMITER //
CREATE TRIGGER `entradas_A_I` AFTER INSERT ON `producto`
 FOR EACH ROW BEGIN
		INSERT INTO entradas (codproducto, cantidad, precio, usuario_id)
		VALUES (new.codproducto, new.existencia, new.precio, new.usuario_id);
    END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `proveedor`;
CREATE TABLE IF NOT EXISTS `proveedor` (
  `codproveedor` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` bigint(11) DEFAULT NULL,
  `direccion` text,
  `date_add` datetime NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`codproveedor`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`codproveedor`, `proveedor`, `contacto`, `telefono`, `direccion`, `date_add`, `usuario_id`, `estatus`) VALUES
(1, 'Puerto el Sol', 'Henny / Carmem', 31262, 'Puerto el Sol', '0000-00-00 00:00:00', 0, 1),
(2, 'CASIO', 'Jorge Herrera', 56, 'Calzada Las Flores', '0000-00-00 00:00:00', 0, 0),
(3, 'Omega', 'Julio Estrada', 982877489, 'Avenida Elena Zona 4, Guatemala', '0000-00-00 00:00:00', 0, 1),
(4, 'Dell Compani', 'Roberto Estrada', 2147483647, 'Guatemala, Guatemala', '0000-00-00 00:00:00', 0, 1),
(5, 'Olimpia S.A', 'Elena Franco Morales', 564535676, '5ta. Avenida Zona 4 Ciudad', '0000-00-00 00:00:00', 0, 1),
(6, 'Oster', 'Fernando Guerra', 78987678, 'Calzada La Paz, Guatemala', '0000-00-00 00:00:00', 0, 1),
(7, 'ACELTECSA S.A', 'Ruben PÃ©rez', 789879889, 'Colonia las Victorias', '0000-00-00 00:00:00', 0, 1),
(8, 'Sony', 'Julieta Contreras', 89476787, 'Antigua Guatemala', '0000-00-00 00:00:00', 0, 1),
(9, 'VAIO', 'Felix Arnoldo Rojas', 476378276, 'Avenida las Americas Zona 13', '0000-00-00 00:00:00', 0, 1),
(10, 'SUMAR', 'Oscar Maldonado', 788376787, 'Colonia San Jose, Zona 5 Guatemala', '0000-00-00 00:00:00', 0, 1),
(11, 'HP', 'Angel Cardona', 2147483647, '5ta. calle zona 4 Guatemala', '0000-00-00 00:00:00', 0, 1),
(12, 'JC', '', 999999, 'archidona', '0000-00-00 00:00:00', 1, 1),
(13, 'JC2', 'Juan ', 88888, 'Municipio de Ar', '0000-00-00 00:00:00', 1, 1),
(14, 'Macdonalds', 'Mac', 912, 'La Paz', '0000-00-00 00:00:00', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `rol`;
CREATE TABLE IF NOT EXISTS `rol` (
  `idrol` int(11) NOT NULL AUTO_INCREMENT,
  `rol` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idrol`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Operaciones'),
(2, 'Administrador'),
(3, 'Bodeguero'),
(4, 'Cocinero');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--
-- Creación: 16-01-2020 a las 04:06:02
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `idusuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `usuario` varchar(15) DEFAULT NULL,
  `clave` varchar(100) DEFAULT NULL,
  `rol` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idusuario`),
  KEY `rol` (`rol`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- RELACIONES PARA LA TABLA `usuario`:
--   `rol`
--       `rol` -> `idrol`
--

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `rol`, `status`) VALUES
(1, 'Carlos Estrada', 'carlos@hotmail.es', 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, 1),
(3, '$Maria', 'maria@gmail.com', 'mary', '202cb962ac59075b964b07152d234b70', 2, 1),
(19, 'carla', 'carla@gmail.com', 'karla', '202cb962ac59075b964b07152d234b70', 1, 1),
(20, 'mauro', 'mauro@gmail.com', 'mauro', '202cb962ac59075b964b07152d234b70', 1, 1),
(21, 'JUAN CARLOS ', 'm@gmail.com', 'm', 'fcea920f7412b5da7be0cf42b8c93759', 4, 1),
(22, 'nuevo', 'nuevo@gmail.com', 'nuevo', 'e10adc3949ba59abbe56e057f20f883e', 1, 1);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`);

--
-- Filtros para la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD CONSTRAINT `detallefactura_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `factura_ibfk_2` FOREIGN KEY (`codcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`proveedor`) REFERENCES `proveedor` (`codproveedor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`rol`) REFERENCES `rol` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
