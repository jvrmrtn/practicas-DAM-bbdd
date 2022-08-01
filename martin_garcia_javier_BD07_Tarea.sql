--1. Crea el tipo de objetos "Personal" con los siguientes atributos
CREATE OR REPLACE TYPE Personal AS OBJECT (
    codigo INTEGER,
    dni VARCHAR2(10),
    nombre VARCHAR2(30),
    apellidos VARCHAR2(30),
    sexo VARCHAR2(1),
    fecha_nac DATE
)NOT FINAL;
/

--Crea, como tipo heredado de "Personal", el tipo de objeto "Responsable" 
--con los siguientes atributos
CREATE OR REPLACE TYPE Responsable UNDER Personal (
    tipo CHAR,
    antiguedad INTEGER
);
/

--Crea el tipo de objeto "Zonas" con los siguientes atributos
CREATE OR REPLACE TYPE Zonas AS OBJECT (
    codigo INTEGER,
    nombre VARCHAR(20),
    refRespon REF Responsable,
    codigoPostal CHAR(5)
);
/

--Crea, como tipo heredado de "Personal", el tipo de objeto "Comercial" 
--con los siguientes atributos
CREATE OR REPLACE TYPE Comercial UNDER Personal (
    zonaComercial Zonas
);
/

--2. Crea un método constructor para el tipo de objetos "Responsable", 
--en el que se indiquen como parámetros código, nombre, primer apellido, segundo apellido y tipo. 
--Este método debe asignar al atributo apellidos los datos de primer apellido y segundo apellido 
--que se han pasado como parámetros, uniéndolos con un espacio entre ellos.
ALTER TYPE Responsable ADD CONSTRUCTOR FUNCTION Responsable(codigo INTEGER, nombre VARCHAR2, primerApellido VARCHAR2, segundoApellido VARCHAR2, tipo CHAR)
    RETURN SELF AS RESULT CASCADE;
/

CREATE OR REPLACE TYPE BODY Responsable AS 
    CONSTRUCTOR FUNCTION Responsable (codigo INTEGER, nombre VARCHAR2, primerApellido VARCHAR2, segundoApellido VARCHAR2, tipo CHAR)
        RETURN SELF AS RESULT
    IS
        BEGIN
            SELF.codigo := codigo;
            SELF.nombre := nombre;
            SELF.apellidos := primerApellido ||' '|| segundoApellido;
            SELF.tipo := tipo;
            RETURN;
        END;
END;
/

--3.Crea un método getNombreCompleto para el tipo de objetos Responsable 
--que permita obtener su nombre completo con el formato apellidos nombre
ALTER TYPE Responsable ADD MEMBER FUNCTION getNombreCompleto
    RETURN VARCHAR2 CASCADE;
/

CREATE OR REPLACE TYPE BODY Responsable AS
    CONSTRUCTOR FUNCTION Responsable (codigo INTEGER, nombre VARCHAR2, primerApellido VARCHAR2, segundoApellido VARCHAR2, tipo CHAR)
        RETURN SELF AS RESULT
    IS
        BEGIN
            SELF.codigo := codigo;
            SELF.nombre := nombre;
            SELF.apellidos := primerApellido ||' '|| segundoApellido;
            SELF.tipo := tipo;
            RETURN;
        END;

    MEMBER FUNCTION getNombreCompleto
        RETURN VARCHAR2
    IS
        BEGIN
            RETURN SELF.apellidos ||' '|| SELF.nombre;    
        END getNombreCompleto;
END;
/

--4.Crea una tabla TablaResponsables de objetos  Responsable.
CREATE TABLE TablaResponsables OF Responsable;
/

--Inserta en dicha tabla dos objetos  Responsable
DECLARE
    r1 Responsable;
BEGIN
    r1 := new Responsable(5,NULL,'ELENA','POSTA LLANOS','F','31/03/1975','N',4);
    INSERT INTO TablaResponsables VALUES(r1);
END;
/

--El segundo objeto "Responsable" debes crearlo usando el método constructor 
--que has realizado anteriormente. Debes usar los siguientes datos
DECLARE
    r2 Responsable;
BEGIN
    r2 := new Responsable(6, 'JAVIER', 'JARAMILLO', 'HERNANDEZ', 'C');
    INSERT INTO TablaResponsables VALUES(r2);
END;
/

--5.Crea una colección VARRAY llamada ListaZonas en la que se puedan almacenar 
--hasta 10 objetos Zonas.
CREATE OR REPLACE TYPE ListaZonas IS VARRAY(10) OF Zonas;
/

--Guarda en una instancia listaZonas1 de dicha lista, dos Zonas.
DECLARE
    listaZonas1 ListaZonas;
    zona1 Zonas;
    zona2 Zonas;
    responsable_ref REF Responsable;
BEGIN
    SELECT REF(tr) INTO responsable_ref 
    FROM TablaResponsables tr
    WHERE tr.codigo = 5;
    zona1 := new Zonas(1,'zona 1',responsable_ref,'06834');

    --La referencia al responsable se indica con un dni no guardado,
    --Lo guardo en el segundo responsable.
    UPDATE TablaResponsables SET DNI = '51083099F'
    WHERE codigo = 6;
    
    SELECT REF(tr) INTO responsable_ref
    FROM TablaResponsables tr
    WHERE tr.DNI = '51083099F';
    zona2 := new Zonas(2,'zona 2',responsable_ref,'28003');
    
    listaZonas1 := ListaZonas(zona1,zona2);
END;
/

--6.Crea una tabla TablaComerciales de objetos Comercial.
CREATE TABLE TablaComerciales OF Comercial;
/

--Inserta en dicha tabla las siguientes filas
--zonacomercial: objeto que se encuentre en la segunda posición de "listaZonas1" 
--(debe tomarse de la lista)
DECLARE
    listaZonas1 ListaZonas;
    zona1 Zonas;
    zona2 Zonas;
    responsable_ref REF Responsable;
    c1 Comercial;
    c2 Comercial;
BEGIN
    SELECT REF(tr) INTO responsable_ref 
    FROM TablaResponsables tr
    WHERE tr.codigo = 5;
    zona1 := new Zonas(1,'zona 1',responsable_ref,'06834');
    
    SELECT REF(tr) INTO responsable_ref
    FROM TablaResponsables tr
    WHERE tr.DNI = '51083099F';
    zona2 := new Zonas(2,'zona 2',responsable_ref,'28003');
    
    listaZonas1 := ListaZonas(zona1,zona2);
    
    c1 := new Comercial(100,'23401092Z','MARCOS','SUAREZ LOPEZ','M','30/3/1990', listaZonas1(1));
    INSERT INTO TablaComerciales VALUES(c1);
    c2 := new Comercial(102,'6932288V','ANASTASIA','GOMES PEREZ','F','28/11/1984', listaZonas1(2));
    INSERT INTO TablaComerciales VALUES(c2);
END;
/

--7. Obtener, de la tabla TablaComerciales, el Comercial que tiene el código 100, 
--asignándoselo a una variable unComercial.
DECLARE
    unComercial Comercial;
BEGIN
    SELECT VALUE(tc) INTO unComercial 
    FROM TablaComerciales tc
    WHERE tc.codigo = 100;
END;
/

--8.Modifica el código del Comercial guardado en esa variable unComercial asignando el valor 101, 
DECLARE
    unComercial Comercial;
    zona2 Zonas;
BEGIN
    SELECT VALUE(tc) INTO unComercial 
    FROM TablaComerciales tc
    WHERE tc.codigo = 100;
    unComercial.codigo := 101;
    dbms_output.put_line(unComercial.zonaComercial.nombre);
    
--y su zona debe ser la segunda que se había creado anteriormente.    
    SELECT tc.zonaComercial INTO unComercial.zonaComercial 
    FROM TablaComerciales tc
    WHERE tc.zonacomercial.codigo = 2;
    dbms_output.put_line(unComercial.zonaComercial.nombre);
    
--Inserta ese Comercial en la tabla TablaComerciales     
    INSERT INTO TablaComerciales VALUES(unComercial);
END;
/

--9.Crea un método MAP ordenarZonas para el tipo Zonas. 
--Este método debe retornar el nombre completo del Responsable al que hace referencia cada zona. 
--Para obtener el nombre debes utilizar el método getNombreCompleto que se ha creado anteriormente.
ALTER TYPE Zonas ADD MAP MEMBER FUNCTION ordenarZonas
    RETURN VARCHAR2 CASCADE;
/

CREATE OR REPLACE TYPE BODY Zonas AS
    MAP MEMBER FUNCTION ordenarZonas
        RETURN VARCHAR2
    IS
        r1 Responsable;
    BEGIN
        SELECT DEREF(refRespon) INTO r1 FROM Dual; 
        RETURN r1.getNombreCompleto();
    END ordenarZonas;
END;
/

--10.Realiza una consulta de la tabla TablaComerciales ordenada por zonaComercial 
--para comprobar el funcionamiento del método MAP.
SELECT * FROM TablaComerciales ORDER BY zonaComercial;
    
    
    
    
    
    
    
    
    
    
    
    