
use pro2;


DROP PROCEDURE RegistrarEstudiante;
DROP PROCEDURE CrearCarrera;

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
IF EXISTS (SELECT '#' FROM carrera WHERE nombre = Pnombre) THEN
	SELECT 'Ya esta registrada esa carrera.';
ELSEIF Pnombre NOT REGEXP '^[A-Za-z\s]*$' THEN	 
	SELECT 'Formato de carrera incorrecto, solo se permiten letras.';
ELSE
	INSERT INTO carrera(nombre)
	values(Pnombre);
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


CALL CrearCarrera('IngenieriaEnCienciasYSistemas');
CALL RegistrarEstudiante('201907774', 'Dyllan','Garcia', '2000-03-19', 'dyllangm@193gmail.com', '43362920', '1st st 34-34 h5', '3058184570301', '1');
CALL CrearCarrera('IngenieriaIndustrial');

CALL RegistrarDocente('12345678', 'Jose','Perez Lopez', '1990-03-19', 'joseP@193gmail.com', '53362920', '1st st 34-34 h5', '5678384570301');

SELECT * FROM carrera;
SELECT * FROM estudiante;
SELECT * FROM docente;
SELECT * FROM carrera;