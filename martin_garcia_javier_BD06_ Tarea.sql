
--Ejercicio 01. Crear el procedimiento.
CREATE OR REPLACE PROCEDURE CambiarAgentesFamilia( id_FamiliaOrigen agentes.familia%type, id_FamiliaDestino agentes.familia%type)
AS
    v_cantidadFO NUMBER := 0;
    v_cantidadFD NUMBER := 0;
    v_familia agentes.familia%type;
    v_familiaOrigen agentes.familia%type := id_FamiliaOrigen;
    v_familiaDestino agentes.familia%type := id_FamiliaDestino;
    CURSOR cFamilia IS
        SELECT familia FROM agentes;
    CURSOR cFamiliaOrigen IS
        SELECT familia FROM agentes WHERE familia = v_familiaOrigen;
BEGIN

IF id_FamiliaOrigen = id_FamiliaDestino THEN
    RAISE_APPLICATION_ERROR(-20001, 'Las familias son iguales.');
ELSE
    OPEN cFamilia;
        LOOP
            FETCH cFamilia INTO v_familia;
            IF(v_familia = v_familiaOrigen)THEN
                v_cantidadFO := v_cantidadFO + 1;
            ELSIF(v_familia = v_familiaDestino)THEN
                v_cantidadFD := v_cantidadFD + 1;
            END IF;
            EXIT WHEN cFamilia%notfound;     
        END LOOP;
    CLOSE cFamilia;
        IF(v_cantidadFO > 0) THEN
            IF(v_cantidadFD > 0) THEN
                OPEN cFamiliaOrigen;
                    LOOP
                        FETCH cFamiliaOrigen INTO v_familia;
                        UPDATE agentes SET familia = v_familiadestino WHERE familia = v_familiaorigen;
                        EXIT WHEN cFamiliaOrigen%notfound;
                    END LOOP;
                CLOSE cFamiliaOrigen;
            dbms_output.put_line('Se han trasladado '|| v_cantidadfo ||' agentes de la familia '|| v_familiaorigen ||' a la familia '|| v_familiadestino ||'.');
                ELSE
                    RAISE_APPLICATION_ERROR(-20010, 'La familia de Destino no existe.');
            END IF;
            ELSE
                RAISE_APPLICATION_ERROR(-20011, 'La familia de Origen no existe.');
        END IF;
END IF;
END;
/

--Ejercicio01. Ejecutar procedimiento.
DECLARE
    v_familiaAgenteOrigen agentes.familia%type := &familiaOrigen;
    v_familiaAgenteDestino agentes.familia%type := &familiaDestino;
BEGIN
    CambiarAgentesFamilia(v_familiaAgenteOrigen, v_familiaagentedestino);
END;
/


--Ejercicio.02
--2.1.La longitud de la clave de un agente no puede ser inferior a 6.
--*Esto se puede restringir con CHECK. (... CHECK LENGTH(clave) < 6).
CREATE OR REPLACE TRIGGER clave_agente_menor_seis 
BEFORE INSERT OR UPDATE OF clave ON agentes
FOR EACH ROW
DECLARE

BEGIN
    IF LENGTH(:NEW.clave) < 6 THEN
        RAISE_APPLICATION_ERROR(-20200, 'La clave tiene que ser de 6 o más caracteres.');
    END IF;
END;
/
--UPDATE agentes SET clave = '12345' WHERE identificador = 31;

--2.2.La habilidad de un agente debe estar comprendida entre 0 y 9 (ambos inclusive).
--*Esto se puede restringir con CHECK. (... CHECK habilidad BETWEEN 0 AND 9).
CREATE OR REPLACE TRIGGER habilidad_agente 
BEFORE INSERT OR UPDATE OF habilidad ON agentes
FOR EACH ROW
DECLARE

BEGIN
    IF (:NEW.habilidad < 0) OR (:NEW.habilidad > 9) THEN
        RAISE_APPLICATION_ERROR(-20201, 'La habilidad debe estar entre 0 y 9.');
    END IF;
END;
/

--UPDATE agentes SET habilidad = -1 WHERE identificador = 31;

--2.3.La categoría de un agente sólo puede ser igual a 0, 1 o 2.
--*Esto se puede restringir con CHECK. (... CHECK categoria BETWEEN 0 AND 2).
CREATE OR REPLACE TRIGGER categoria_agente 
BEFORE INSERT OR UPDATE OF categoria ON agentes
FOR EACH ROW
DECLARE

BEGIN
    IF (:NEW.categoria < 0) or (:NEW.categoria > 2) THEN
        RAISE_APPLICATION_ERROR(-20202, 'La categoría debe ser 0, 1 ó 2.');
    END IF;
END;
/

--UPDATE agentes SET categoria = 6 WHERE identificador = 31;

--2.4.Si un agente tiene categoría 2 no puede pertenecer a ninguna familia y debe pertenecer a una oficina. 
CREATE OR REPLACE TRIGGER restriccion_categoria2_agente 
BEFORE INSERT OR UPDATE ON agentes
FOR EACH ROW
DECLARE

BEGIN
    IF (:NEW.categoria = 2) OR (:OLD.categoria = 2)  THEN
        IF(:NEW.familia IS NOT NULL) OR (:OLD.familia IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20210, 'Un agente con categoria 2 no puede tener familia.');
        ELSIF(:NEW.oficina IS NULL) OR (:OLD.oficina IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20220, 'Un agente con categoria 2 tiene que tener oficina.');
        END IF;
    END IF;
END;
/

--UPDATE agentes SET familia = 31 WHERE identificador = 31;
--UPDATE agentes SET oficina = NULL WHERE identificador = 31;

--2.5.Si un agente tiene categoría 1 no puede pertenecer a ninguna oficina y debe pertenecer  a una familia.
CREATE OR REPLACE TRIGGER restriccion_categoria1_agente 
BEFORE INSERT OR UPDATE ON agentes
FOR EACH ROW
DECLARE

BEGIN
    IF (:NEW.categoria = 1) OR (:OLD.categoria = 1)  THEN
        IF(:NEW.familia IS NULL) OR (:OLD.familia IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20310, 'Un agente con categoria 1 tiene que tener familia.');
        ELSIF(:NEW.oficina IS NOT NULL) OR (:OLD.oficina IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20320, 'Un agente con categoria 1 no puede tener oficina.');
        END IF;
    END IF;
END;
/

--UPDATE agentes SET familia = NULL, oficina = 2 WHERE identificador = 211;
--UPDATE agentes SET oficina = 2 WHERE identificador = 211;
--Salta el disparador 2.6 de no poder tener familia y oficina a la vez, 
--Habria que comentar la parte del ELSIF del disparador 2.6 para que saltase éste.

--2.6.Todos los agentes deben pertenecer  a una oficina o a una familia pero nunca a ambas a la vez.
CREATE OR REPLACE TRIGGER oficina_or_familia
BEFORE INSERT OR UPDATE ON agentes
FOR EACH ROW
DECLARE

BEGIN

    IF (:new.familia IS NULL) AND (:new.oficina IS NULL) THEN
          RAISE_APPLICATION_ERROR(-20410, 'Un agente tiene que tener familia u oficina.');
     ELSIF (:new.familia IS NOT NULL and :new.oficina IS NOT NULL) THEN
          RAISE_APPLICATION_ERROR(-20420, 'Un agente no puede tener familia y oficina a la vez.');
     END IF;    

END;
/

--UPDATE agentes SET familia = NULL WHERE identificador = 311;
--UPDATE agentes SET familia = 31 WHERE identificador = 31;

