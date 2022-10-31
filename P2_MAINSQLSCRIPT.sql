
use pro2;


DROP PROCEDURE RegistrarEstudiante;
DROP PROCEDURE CrearCarrera;
DROP PROCEDURE CrearCurso;
DROP PROCEDURE HabilitarCurso;
DROP PROCEDURE AgregarHorario;
DROP PROCEDURE AsignarCurso;
DROP PROCEDURE DesasignarCurso;
DROP PROCEDURE IngresarNota;
DROP PROCEDURE GenerarActa;
DROP PROCEDURE ConsultarPensum;
DROP PROCEDURE ConsultarEstudiante;
DROP PROCEDURE ConsultarDocente;
DROP PROCEDURE ConsultarAsignados;
DROP PROCEDURE ConsultarActas;
DROP PROCEDURE ConsultarDesasignacion;


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
ELSEIF PcreditosN NOT RLIKE '^[0-9]+$' THEN	 
	SELECT 'Numero de creditos necesarios no valido, solo enteros.';
ELSEIF PcreditosO NOT RLIKE '^[0-9]+$' THEN	 
	SELECT 'Numero de creditos que otorga no valido, solo enteros.';
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
ELSEIF PcupoMaximo NOT RLIKE '^[0-9]+$' THEN	 
	SELECT 'Cupo maximo no valido, solo enteros.';
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
ELSEIF Pdia NOT RLIKE '^[1-7]+$' THEN	 
	SELECT 'Dia fuera de rango unicamente de 1 a 7';
ELSE
	INSERT INTO horario(cursoHabilitado_idcursoHabilitado, dia,horario)
	values(Pidcurso, Pdia, Phorario);
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE AsignarCurso(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
									IN `Pseccion` VARCHAR(45),
                                    IN `Pcarnet` VARCHAR(45))
                                    
BEGIN 

DECLARE idCursoH INT;
DECLARE cupoMax INT;
DECLARE asignadosActuales INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = YEAR(CURDATE()) AND seccion = Pseccion;

SELECT cupoMaximo INTO cupoMax FROM cursoHabilitado WHERE idcursoHabilitado = idCursoH;
SELECT numAsignados INTO asignadosActuales FROM cursoHabilitado WHERE idcursoHabilitado = idCursoH;
 
IF NOT EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
    SELECT 'El usuario que se intenta asignar no existe en la DB.';
ELSEIF EXISTS (SELECT '#' FROM asignacion WHERE cursoHabilitado_idcursoHabilitado = idCursoH AND estudiante_carnet = Pcarnet) THEN
    SELECT 'Este usuario ya ser asignó a ese curso habilitado.';
ELSEIF asignadosActuales>=cupoMax THEN 
SELECT 'El cupo para este curso habilitado se ha llenado.';
ELSEIF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) THEN
	INSERT INTO asignacion(estudiante_carnet, cursoHabilitado_idcursoHabilitado,cursoHabilitado_curso_idcurso)
	values(Pcarnet, idCursoH, Pidcurso);
	UPDATE cursoHabilitado 
    SET
    numAsignados = numAsignados + 1
    WHERE
    idcursoHabilitado = idCursoH;
ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE DesasignarCurso(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
									IN `Pseccion` VARCHAR(45),
                                    IN `Pcarnet` VARCHAR(45))
                                    
BEGIN 

DECLARE idCursoH INT;
DECLARE cupoMax INT;
DECLARE asignadosActuales INT;
DECLARE creditosNec INT;
DECLARE creditosEst INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = YEAR(CURDATE()) AND seccion = Pseccion;

SELECT cupoMaximo INTO cupoMax FROM cursoHabilitado WHERE idcursoHabilitado = idCursoH;
SELECT numAsignados INTO asignadosActuales FROM cursoHabilitado WHERE idcursoHabilitado = idCursoH;
SELECT creditosNecesarios INTO creditosNec FROM curso WHERE idcurso = Pidcurso;
SELECT creditosAprobados INTO creditosEst FROM estudiante WHERE carnet = Pcarnet;
 
IF NOT EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
    SELECT 'El usuario que se intenta asignar no existe en la DB.';
ELSEIF NOT EXISTS (SELECT '#' FROM asignacion WHERE cursoHabilitado_idcursoHabilitado = idCursoH AND estudiante_carnet = Pcarnet) THEN
    SELECT 'Este usuario no se ha asignado a ese curso habilitado.';
ELSEIF creditosAprobados < creditosNec THEN
    SELECT 'Este usuario no posee cantidad de creditos necesarios.';
ELSEIF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) THEN
	DELETE FROM asignacion WHERE cursoHabilitado_idcursoHabilitado = idCursoH AND estudiante_carnet = Pcarnet; 
	UPDATE cursoHabilitado 
    SET
    numAsignados = numAsignados - 1
    WHERE
    idcursoHabilitado = idCursoH;
    UPDATE cursoHabilitado 
    SET
    numDesasignados = numDesasignados + 1
    WHERE
    idcursoHabilitado = idCursoH;
ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE IngresarNota(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
									IN `Pseccion` VARCHAR(45),
                                    IN `Pcarnet` VARCHAR(45),
                                    IN `Pnota` DECIMAL)
                                    
BEGIN 

DECLARE idCursoH INT;
DECLARE creditosOtorg INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = YEAR(CURDATE()) AND seccion = Pseccion;

IF NOT EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
    SELECT 'El usuario que se intenta asignar no existe en la DB.';
ELSEIF Pnota < 0 THEN 
SELECT 'La nota debe ser numero positivo.';
ELSEIF Pnota > 100 THEN 
SELECT 'Debe ser menor o igual a 100.';
ELSEIF EXISTS (SELECT '#' FROM notas WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM notas WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM notas WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM notas WHERE estudiante_carnet = Pcarnet) THEN
SELECT 'Nota duplicada, ya se ha registrado.';
ELSEIF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE año = YEAR(CURDATE())) THEN
   
   INSERT INTO notas(curso_idcurso, ciclo,seccion,estudiante_carnet,nota)
	values(Pidcurso, Pciclo, Pseccion, Pcarnet, ROUND(Pnota));
   
   IF ROUND(Pnota) >= 61 THEN
    SELECT creditosOtorga INTO creditosOtorg FROM curso WHERE idcurso = Pidcurso;
	UPDATE estudiante 
    SET
    creditosAprobados = creditosAprobados + creditosOtorg
    WHERE
    carnet = Pcarnet;
    END IF;
ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE GenerarActa(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
									IN `Pseccion` VARCHAR(45))
                                    
BEGIN 

DECLARE idCursoH INT;
DECLARE creditosOtorg INT;
DECLARE cantidadConNota INT;
DECLARE cantidadAsignados INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = YEAR(CURDATE()) AND seccion = Pseccion;

SELECT COUNT(idnotas) INTO cantidadConNota FROM notas WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND seccion = Pseccion;
SELECT numAsignados INTO cantidadAsignados FROM cursoHabilitado WHERE idcursoHabilitado = idCursoH;

IF cantidadConNota!=cantidadAsignados THEN 
SELECT 'No se han ingresado las notas de todos los asignados.';
ELSEIF EXISTS (SELECT '#' FROM acta WHERE cursoHabilitado_idcursoHabilitado = idCursoH) THEN
SELECT 'Acta duplicada, ya se ha registrada.';
ELSEIF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE año = YEAR(CURDATE())) THEN
   
   INSERT INTO acta(ciclo, seccion,cursoHabilitado_idcursoHabilitado,cursoHabilitado_curso_idcurso,fechaHoraGeneracion)
	values(Pciclo, Pseccion,idCursoH,Pidcurso,NOW());

ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

DELIMITER $$
CREATE PROCEDURE ConsultarPensum(IN `Pidcarrera` INT)
BEGIN 
SELECT idcurso, nombre,IF(obligatorio=1, "SI", "NO") AS 'Es obligatorio', creditosNecesarios FROM curso WHERE carrera_idcarrera = Pidcarrera;
END $$

DELIMITER $$
CREATE PROCEDURE ConsultarEstudiante(IN `Pcarnet` INT)
BEGIN 
IF NOT EXISTS (SELECT '#' FROM estudiante WHERE carnet = Pcarnet) THEN
	SELECT 'Carnet no registrado.';
ELSE
SELECT carnet, CONCAT(nombres," ",apellidos) AS 'Nombre', fechaNac, email, telefono, direccion, dpi, c.nombre AS 'Carrera', creditosAprobados
FROM estudiante e 
INNER JOIN carrera c ON c.idcarrera = e.idcarrera
WHERE carnet = Pcarnet;
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE ConsultarDocente(IN `PcodigoSiif` INT)
BEGIN 
IF NOT EXISTS (SELECT '#' FROM docente WHERE codigoSIIF = PcodigoSiif) THEN
	SELECT 'Docente no registrado.';
ELSE
SELECT codigoSIIF, CONCAT(nombres," ",apellidos) AS 'Nombre', fechaNac, email, telefono, direccion, dpi
FROM docente WHERE codigoSIIF = PcodigoSiif;
END IF;
END $$

DELIMITER $$
CREATE PROCEDURE ConsultarAsignados(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
                                    IN `Paño` INT,
									IN `Pseccion` VARCHAR(45))
BEGIN 
DECLARE idCursoH INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = Paño AND seccion = Pseccion;
IF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE año = YEAR(CURDATE())) THEN
   
IF NOT EXISTS (SELECT '#' FROM asignacion WHERE cursoHabilitado_idcursoHabilitado = idCursoH) THEN
SELECT 'No existen asignados a ese curso habilitado.';
ELSE 
SELECT carnet, CONCAT(nombres," ",apellidos) AS 'Nombre', creditosAprobados
FROM estudiante e 
INNER JOIN asignacion a ON a.estudiante_carnet = e.carnet
WHERE cursoHabilitado_idcursoHabilitado = idCursoH;
END IF;
ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE ConsultarAprobacion(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
                                    IN `Paño` INT,
									IN `Pseccion` VARCHAR(45))
BEGIN 
DECLARE idCursoH INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = Paño AND seccion = Pseccion;
IF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE año = YEAR(CURDATE())) THEN
SELECT n.curso_idcurso,carnet, CONCAT(nombres," ",apellidos) AS 'Nombre', IF(n.nota>=61, "APROBADO", "DESAPROBADO") AS 'Estado'
FROM estudiante e 
INNER JOIN notas n ON n.estudiante_carnet = e.carnet
WHERE curso_idcurso = Pidcurso;
ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$

DELIMITER $$
CREATE PROCEDURE ConsultarActas(IN `Pidcurso` INT)
BEGIN 
IF NOT EXISTS (SELECT '#' FROM acta WHERE cursoHabilitado_curso_idcurso = Pidcurso) THEN
	SELECT 'No hay actas para ese curso.';
ELSE
SELECT cursoHabilitado_curso_idcurso, a.seccion, CASE
    WHEN a.ciclo = '1S' THEN "PRIMER SEMESTRE"
    WHEN a.ciclo = '2S' THEN "SEGUNDO SEMESTRE"
    WHEN a.ciclo = 'VJ' THEN "“VACACIONES DE JUNIO"
    WHEN a.ciclo = 'VD' THEN "“VACACIONES DE DICIEMBRE"
    ELSE "NO DEFINIDO"
END AS 'Ciclo', YEAR(fechaHoraGeneracion) AS 'Año', ch.numAsignados, fechaHoraGeneracion
FROM acta a 
INNER JOIN cursoHabilitado ch ON ch.idcursoHabilitado = a.cursoHabilitado_idcursoHabilitado
WHERE curso_idcurso = Pidcurso;
END IF;
END $$


DELIMITER $$
CREATE PROCEDURE ConsultarDesasignacion(IN `Pidcurso` INT,
									IN `Pciclo` VARCHAR(4),
                                    IN `Paño` INT,
									IN `Pseccion` VARCHAR(45))
BEGIN 
DECLARE idCursoH INT;

SELECT idcursoHabilitado INTO idCursoH
FROM cursoHabilitado WHERE curso_idcurso = Pidcurso AND ciclo = Pciclo AND año = Paño AND seccion = Pseccion;
IF EXISTS (SELECT '#' FROM cursoHabilitado WHERE curso_idcurso = Pidcurso) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE ciclo = Pciclo) AND
EXISTS (SELECT '#' FROM cursoHabilitado WHERE seccion = Pseccion) AND EXISTS (SELECT '#' FROM cursoHabilitado WHERE año = YEAR(CURDATE())) THEN

SELECT curso_idcurso,seccion, CASE
    WHEN ciclo = '1S' THEN "PRIMER SEMESTRE"
    WHEN ciclo = '2S' THEN "SEGUNDO SEMESTRE"
    WHEN ciclo = 'VJ' THEN "“VACACIONES DE JUNIO"
    WHEN ciclo = 'VD' THEN "“VACACIONES DE DICIEMBRE"
    ELSE "NO DEFINIDO"
END AS 'Ciclo', año, numAsignados, numDesasignados, (numDesasignados/(numAsignados+numDesasignados))*100 AS 'PorcentajeDesasignacion' 
FROM cursoHabilitado
WHERE idcursoHabilitado = idCursoH;

ELSE
SELECT 'No se encuentra habilitado el curso, para esa seccion, ciclo o año.';
END IF;
END $$


DELIMITER $$
CREATE TRIGGER estudianteInsert
    AFTER INSERT
    ON estudiante FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "estudiante");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER estudianteUpdate
    AFTER UPDATE
    ON estudiante FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se actualizaron registros.", "UPDATE", "estudiante");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER asignacionInsert
    AFTER INSERT
    ON asignacion FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "asignacion");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER asignacionDelete
    AFTER DELETE
    ON asignacion FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se eliminarion registros.", "DELETE", "asignacion");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER notasInsert
    AFTER INSERT
    ON notas FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "notas");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER cursoInsert
    AFTER INSERT
    ON curso FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "curso");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER cursoHInsert
    AFTER INSERT
    ON cursoHabilitado FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "cursoHabilitado");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER docenteInsert
    AFTER INSERT
    ON docente FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "docente");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER actaInsert
    AFTER INSERT
    ON acta FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "acta");
END$$    
DELIMITER ;

DELIMITER $$
CREATE TRIGGER horarioInsert
    AFTER INSERT
    ON horario FOR EACH ROW
BEGIN
    INSERT INTO historial(fecha,descripcion,tipo,historialcol) VALUES(now(), "Se insertaron registros.", "INSERT", "horario");
END$$    
DELIMITER ;

CALL CrearCarrera('IngenieriaEnCienciasYSistemas');
CALL RegistrarEstudiante('201907775', 'Dyllan','Garcia', '2000-03-19', 'dyllangm@193gmail.com', '43362920', '1st st 34-34 h5', '3058184570301', '1');
CALL CrearCarrera('IngenieriaIndustrial');

CALL RegistrarDocente('12345677', 'Jose','Perez Lopez', '1990-03-19', 'joseP@193gmail.com', '53362920', '1st st 34-34 h5', '5678384570301');
CALL CrearCurso('0779', 'Bases 1','150', '5', '1', '0');
CALL HabilitarCurso('0774', '2S','12345678', '5', 'B');
CALL AgregarHorario('2', '6','9:00-10:40');
CALL AsignarCurso('774','2S','A','201907774');
CALL DesasignarCurso('774','2S','A','201907774');

CALL IngresarNota('774','2S','A',201907774, 61.8);

CALL GenerarActa('774','2S','A');

CALL ConsultarPensum(1);
CALL ConsultarEstudiante(20190774);
CALL ConsultarDocente(12345678);
CALL ConsultarAsignados('774','2S',2022,'A');
CALL ConsultarAprobacion('774','2S',2022,'A');
CALL ConsultarActas(774);
CALL ConsultarDesasignacion('774','2S',2023,'A');

TRUNCATE TABLE notas;
SELECT * FROM carrera;
SELECT * FROM acta;
SELECT * FROM cursoHabilitado;
SELECT * FROM horario;
SELECT * FROM asignacion;
SELECT * FROM notas;
SELECT * FROM curso;
SELECT * FROM estudiante;
SELECT * FROM docente;
SELECT * FROM historial;