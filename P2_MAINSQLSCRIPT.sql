
use pro2;


DROP PROCEDURE RegistrarEstudiante;
DROP PROCEDURE CrearCarrera;
DROP PROCEDURE CrearCurso;
DROP PROCEDURE HabilitarCurso;
DROP PROCEDURE AgregarHorario;
DROP PROCEDURE AsignarCurso;

DELIMITER $$
CREATE PROCEDURE RegistrarEstudiante(IN `Pcarnet` INT,
									IN `Pnombres` VARCHAR(45),
									IN `Papellidos` VARCHAR(45),
									IN `PfechaNac` DATE,
									IN `Pemail` VARCHAR(45),
									IN `Ptelefono` INT,
									IN `Pdireccion` VARCHAR(45),
									IN `Pdpi` VARCHAR(20),
									IN `Pidcarrera` INT)
                                    
BEGIN 
IF EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
	SELECT 'Ya se ha registrado un estudiante con ese carnet.';
ELSEIF NOT EXISTS (SELECT '#' FROM carrera WHERE idcarrera = Pidcarrera) THEN
    SELECT 'No existe la carrera que intenta asociarse.';
ELSEIF Pemail NOT RLIKE '^[^@]+@[^@]+\.[^@]{2,}$' THEN	 
	SELECT 'El correo no tiene un formato aceptado.';
ELSE
	INSERT INTO estudiante(carnet, nombres, apellidos,fechaNac,email,telefono, direccion,dpi, idcarrera)
	values(Pcarnet, Pnombres, Papellidos, PfechaNac, Pemail, Ptelefono, Pdireccion, Pdpi, Pidcarrera);
END IF;
END $$

DELIMITER $$
CREATE PROCEDURE CrearCarrera(IN `Pnombre` VARCHAR(45))

BEGIN 

DECLARE carrera_count INT;
SELECT COUNT(idcarrera) INTO carrera_count FROM carrera;

IF carrera_count = 0 THEN
INSERT INTO carrera(idcarrera, nombre)
values(carrera_count, 'Area Comun');
SELECT COUNT(idcarrera) INTO carrera_count FROM carrera;
END IF;

IF EXISTS (SELECT '#' FROM carrera WHERE nombre = Pnombre) THEN
	SELECT 'Ya esta registrada esa carrera.';
ELSEIF Pnombre NOT REGEXP '^[A-Za-z\s]*$' THEN	 
	SELECT 'Formato de carrera incorrecto, solo se permiten letras.';
ELSE
	INSERT INTO carrera(idcarrera, nombre)
	values(carrera_count, Pnombre);
END IF;
END $$

DELIMITER $$
CREATE PROCEDURE RegistrarDocente(IN `PcodigoSiif` INT,
									IN `Pnombres` VARCHAR(45),
									IN `Papellidos` VARCHAR(45),
									IN `PfechaNac` DATE,
									IN `Pemail` VARCHAR(45),
									IN `Ptelefono` INT,
									IN `Pdireccion` VARCHAR(45),
									IN `Pdpi` VARCHAR(20))
                                    
BEGIN 
IF EXISTS (SELECT '#' FROM docente WHERE codigoSIIF = PcodigoSiif) THEN
	SELECT 'Ya se ha registrado un docente con ese SIIF.';
ELSEIF Pemail NOT RLIKE '^[^@]+@[^@]+\.[^@]{2,}$' THEN	 
	SELECT 'El correo no tiene un formato aceptado.';
ELSE
	INSERT INTO docente(codigoSIIF, nombres, apellidos,fechaNac,email,telefono, direccion,dpi)
	values(PcodigoSiif, Pnombres, Papellidos, PfechaNac, Pemail, Ptelefono, Pdireccion, Pdpi);
END IF;
END $$



DELIMITER $$
CREATE PROCEDURE CrearCurso(IN `Pidcurso` INT,
									IN `Pnombre` VARCHAR(45),
									IN `PcreditosN` INT,
									IN `PcreditosO` INT,
									IN `Pcarrera` INT,
                                    IN `Pobligatorio` TINYINT)
                                    
BEGIN 
IF EXISTS (SELECT '#' FROM curso WHERE idcurso = Pidcurso) THEN
	SELECT 'Ya se ha registrado un curso con ese codigo';
ELSEIF NOT EXISTS (SELECT '#' FROM carrera WHERE idcarrera = Pcarrera) THEN
    SELECT 'No existe la carrera que intenta asociarse al curso.';
ELSEIF PcreditosN <= 0 AND PcreditosO <=0 THEN
SELECT 'La cantidad de creditos necesarios y que otorga deben ser positivos y diferentes a cero.';
ELSEIF Pobligatorio != 0 AND Pobligatorio != 1 THEN
SELECT 'El campo obligatorio debe ser 1=obligatorio o 0=no obligatorio';
ELSE
	INSERT INTO curso(idcurso, nombre, creditosNecesarios,creditosOtorga,obligatorio,carrera_idcarrera)
	values(Pidcurso, Pnombre, PcreditosN, PcreditosO, Pobligatorio, Pcarrera);
END IF;
END $$



DELIMITER $$
CREATE PROCEDURE HabilitarCurso(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(2),
									IN `Pdocente` INT,
									IN `PcupoMaximo` INT,
                                    IN `Pseccion` VARCHAR(45))
                                    
BEGIN 
IF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) THEN
	SELECT 'Ya se ha registrado una seccion para este curso en este periodo.';
ELSE
	INSERT INTO cursoHabilitado(ciclo, cupoMaximo, seccion,año,curso_idcurso,docente_codigoSIIF,numAsignados,numDesasignados)
	values(Pciclo, PcupoMaximo, Pseccion, YEAR(CURDATE()), Pidcurso, Pdocente,0,0);
END IF;
END $$



DELIMITER $$
CREATE PROCEDURE AgregarHorario(IN `Pidcurso` INT,
									IN `Pdia` INT,
									IN `Phorario` VARCHAR(45))
                                    
BEGIN 
IF NOT EXISTS (SELECT '#' FROM cursoHabilitado WHERE idcursoHabilitado = Pidcurso) THEN
    SELECT 'Este curso no esta habilitado para asignar horario';
ELSE
	INSERT INTO horario(cursoHabilitado_idcursoHabilitado, cursoHabilitado_curso_idcurso, dia,horario)
	values(Pidcurso, '0775', Pdia, Phorario);
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE AsignarCurso(IN `Pidcurso` INT,
									IN `Pciclo` INT,
									IN `Pseccion` VARCHAR(45),
                                    IN `Pcarnet` VARCHAR(45))
                                    
BEGIN 



IF NOT EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
    SELECT 'El usuario que se intenta asignar no existe en la DB.';
ELSEIF Pciclo!='1S' OR Pciclo!='2S' OR Pciclo!='VJ' OR Pciclo!='VD' THEN
SELECT 'No son ciclos validos, admitidos: 1S, 2S, VJ, VD';
ELSEIF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) THEN

	SELECT v.id_usuario, SUM(d.cantidad) AS TOTAL
	FROM ventas v
	INNER JOIN detalle_ventas d ON d.id_venta = v.id_venta
	GROUP BY v.id_usuario ORDER BY TOTAL ASC;
    
	INSERT INTO asignacion(estudiante_carnet, cursoHabilitado_idcursoHabilitado,cursoHabilitado_curso_idcurso)
	values(Pidcurso, '0775', Pdia, Phorario);
END IF;
END $$


SELECT idcursoHabilitado FROM cursoHabilitado WHERE curso_idcurso = '774' AND ciclo = '1S' AND año = '2022' AND seccion = 'A';

	SELECT h.idcursoHabilitado
	FROM cursoHabilitado h
	INNER JOIN asignacion a ON a.cursoHabilitado_idcursoHabilitado = h.idcursoHabilitado
	GROUP BY h.idcursoHabilitado;

CALL CrearCarrera('IngenieriaEnCienciasYSistemas');
CALL RegistrarEstudiante('201907774', 'Dyllan','Garcia', '2000-03-19', 'dyllangm@193gmail.com', '43362920', '1st st 34-34 h5', '3058184570301', '1');
CALL CrearCarrera('IngenieriaIndustrial');

CALL RegistrarDocente('12345678', 'Jose','Perez Lopez', '1990-03-19', 'joseP@193gmail.com', '53362920', '1st st 34-34 h5', '5678384570301');
CALL CrearCurso('0779', 'Bases 1','150', '5', '1', '0');
CALL HabilitarCurso('0774', '2S','12345678', '90', 'A');
CALL AgregarHorario('2', '6','9:00-10:40');

SELECT * FROM carrera;
SELECT * FROM cursoHabilitado;
SELECT * FROM horario;
SELECT * FROM asignacion;
SELECT * FROM curso;
SELECT * FROM estudiante;
SELECT * FROM docente;