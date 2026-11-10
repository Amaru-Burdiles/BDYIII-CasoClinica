/* ELIMINA TABLAS SI EXISTEN */
DROP TABLE clasificacion_medico;
DROP TABLE errores_informe;
DROP SEQUENCE SEQ_ERROR_INFORME;
DROP TABLE informe_general;

/* ----------------------- CREACI�N DE OBJEOS --------------------------- */


/*========================
-- Clasificacion Medico --
========================*/
CREATE TABLE clasificacion_medico
(
    id_clase NUMBER PRIMARY KEY,
    descripcion_clase VARCHAR2(15) NOT NULL,
    limite_inferior NUMBER NOT NULL,
    limite_superior NUMBER NOT NULL
);

/*===================
-- Informe Errores --
===================*/
CREATE TABLE errores_informe
(
    id_error NUMBER PRIMARY KEY,
    fecha_error DATE NOT NULL,
    codigo_error VARCHAR2(15) NOT NULL,
    descripcion_error VARCHAR2(100) NOT NULL
);

/*=======================
-- Informe Rendimiento --
=======================*/
CREATE TABLE informe_general
(
    rut VARCHAR2(9) NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    anios_exp NUMBER NOT NULL,
    cant_atenciones NUMBER NOT NULL,
    ptje_experiencia NUMBER NOT NULL,
    ptje_productividad NUMBER NOT NULL,
    ptje_especialidad NUMBER NOT NULL,
    ptje_region NUMBER NOT NULL,
    rendimiento NUMBER NOT NULL,
    clasificacion VARCHAR2(10) NOT NULL
);

/*=====================
-- Secuencia Errores --
=====================*/
CREATE SEQUENCE SEQ_ERROR_INFORME;


/* ------------------------- INSERSION DE DATOS ----------------------------- */

/*========================
-- Clasificacion Medico --
========================*/
INSERT INTO clasificacion_medico VALUES(1, 'Bajo', 1, 99);
INSERT INTO clasificacion_medico VALUES(2, 'Medio', 100, 199);
INSERT INTO clasificacion_medico VALUES(3, 'Alto', 200, 274);


/* -------------------------- DESARROLLO LOGICA ----------------------------- */

/*============================
-- Package Calculo Puntajes --
=============================*/
CREATE OR REPLACE PACKAGE pkg_calc_puntaje
IS
    
    /* Extraer la especialidad y el puntaje asociado a una especialidad dada 
       Input: NUMBER; Output: VARCHAR, NUMBER */
    PROCEDURE prc_especialidad(p_id NUMBER, especialidad OUT NUMBER, puntaje OUT VARCHAR);
    
    /* Determina el puntaje de experiencia de un medico dado
       Input: NUMBER; Output: NUMBER */
    FUNCTION fn_experiencia(p_experiencia NUMBER)
    RETURN NUMBER;
    
    /* Determina el puntaje de productividad a partir de las atenciones
       Input: NUMBER; Output: NUMBER */
    FUNCTION fn_productividad(p_atenciones NUMBER)
    RETURN NUMBER;
    
    /* Determina el puntaje asociado a una region de la consulta 
       Input: NUMBER; Output: NUMBER */
    FUNCTION fn_region(p_run_medico NUMBER)
    RETURN NUMBER;
    
END;

/* IMPLEMENTACION */
CREATE OR REPLACE PACKAGE BODY pkg_calc_puntaje
IS
    -- PROCEDIMIENTO PUBLICO
    PROCEDURE prc_especialidad(p_id NUMBER, especialidad OUT NUMBER, puntaje OUT VARCHAR)
    IS
    BEGIN
        -- Obtiene el nombre de la especialidad y su puntaje
        SELECT es.nombre, es.puntaje
        INTO especialidad, puntaje
        FROM especialidad es
        WHERE p_id = es.id;
    END;
    
    -- FUNCION PUBLICA
    FUNCTION fn_experiencia(p_experiencia NUMBER)
    RETURN NUMBER
    IS
        -- Almacena el puntaje de experiencia del medico
        v_ptje_experiencia NUMBER;
        
    BEGIN
        --Obtiene el puntaje de experiencia 
        SELECT puntaje
        INTO v_ptje_experiencia
        FROM puntajeexperiencia
        WHERE p_experiencia BETWEEN anios_inicio AND anios_fin;
        
        -- Retorna el valor calculado
        RETURN v_ptje_experiencia;
    END;
    
    -- FUNCION PUBLICA
    FUNCTION fn_productividad(p_atenciones NUMBER)
    RETURN NUMBER
    IS
        -- Almacena el puntaje de productividad del medico
        v_ptje_productividad NUMBER;
        
    BEGIN
        --Obtiene el puntaje de productividad del medico mediante el total de atenciones
        SELECT puntaje
        INTO v_ptje_productividad
        FROM puntajeproductividad
        WHERE p_atenciones BETWEEN atenciones_inicio AND atenciones_fin;
    END;
    
END;

/*=============================
-- Package Insertar Registro --
=============================*/
CREATE OR REPLACE PACKAGE pkg_insertar
IS
    /* Inserta registros al Informe Rendimiento
       Input: ; Output: Void */

END;


CREATE OR REPLACE PACKAGE pkg_calculos
IS
    /* Limpia y guarda los ponderadores dados para esta sesion 
       Input: NUMBER, NUMBER, NUMBER, NUMBER; Output: Void */

    /* Calcula el indicador integral a partir de los puntajes dados 
       Input: NUMBER, NUMBER, NUMBER, NUMBER; Output: NUMBER */
END;







/* DESARROLLO BLOQUE AN�NIMO =============================================== */
DECLARE
    -- Almacena la informaci�n del m�dico, filtrando por el a�o de la consulta
    CURSOR c_medicos(p_year NUMBER) IS 
        SELECT m.rut,
               m.dv,
               m.nombre,
               m.especialidad_id,
               TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_ingreso)/ 12) anios_exp,
               COUNT(c.id) cant_atenciones
        FROM medico m JOIN consulta c ON(m.rut = c.medico_rut)
        WHERE EXTRACT(YEAR FROM c.fecha) = p_year
                     AND UPPER(c.estado) = 'REALIZADA'
        GROUP BY m.rut,
                 m.dv,
                 m.nombre,
                 m.especialidad_id,
                 TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_ingreso)/ 12);
    
    -- Define un tipo de dato compuesto que almacena numeros
    TYPE numArray IS VARRAY(4) OF NUMBER;
    
    -- Almacena el listado con los ponderadores
    v_ponderadores numArray;

    
    -- Define una estructura para agrupar los resultados de cursores implicitos
    TYPE registro_g IS RECORD (
        nomb_especialidad   especialidad.nombre%TYPE,
        ptje_experiencia    informe_general.ptje_experiencia%TYPE,
        ptje_productividad  informe_general.ptje_productividad%TYPE,
        ptje_especialidad   informe_general.ptje_especialidad%TYPE,
        ptje_region         informe_general.ptje_region%TYPE,
        rendimiento         informe_general.rendimiento%TYPE,
        clasificacion       informe_general.clasificacion%TYPE
    );
    reg_general registro_g;
    
    -- Almacenan el c�digo y descripci�n del error temporalmente antes del Insert
    v_cod_error errores_informe.codigo_error%TYPE;
    v_msg_error errores_informe.descripcion_error%TYPE;
    
    -- Almacena el a�o a filtrar
    v_filtro NUMBER;
        
BEGIN
    /* INICIALIZACI�N DE VARIBLES */
    -- Inicializa los valores de los ponderadores en el VARRAY
    v_ponderadores := numArray(0.25, 0.25, 0.25, 0.25);
    
    -- Inicializa el a�o a filtrar
    v_filtro := 2026;
    
    /* BUCLE PRINCIPAL */
    --Recorre el registro de los m�dicos pasandole a cada uno el a�o a filtrar
    FOR reg_medico IN c_medicos(v_filtro) LOOP
        
        -- procedimiento especialidad
        
        -- Verifica regla de negocio (se lanza la excepcion definida por usuario)
        BEGIN
            IF reg_medico.cant_atenciones = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'El m�dico no posee atenciones realizadas 
                                        durante el per�odo de an�lisis.');
            END IF;
        -- Captura el error    
        EXCEPTION WHEN OTHERS THEN
            -- Recopila el codigo y mensaje de error para pasarlo al insert
            v_cod_error := SQLCODE;
            v_msg_error := SQLERRM;
            
            INSERT INTO errores_informe (id_error, fecha_error, codigo_error, descripcion_error)
            VALUES (SEQ_ERROR_INFORME.NEXTVAL, SYSDATE, v_cod_error, v_msg_error);
        END;
        
        -- funcion especialidad
    
        -- funcion productividad

        --Obtiene el puntaje de region 
        SELECT MAX(r.puntaje) INTO reg_general.ptje_region
        FROM region r JOIN clinica c ON (r.id = c.region_id)
        JOIN consulta co ON (c.id = co.clinica_id)
        WHERE co.medico_rut = reg_medico.rut;
        
        -- C�lculo del indicador integral utilizando los valores almacenados en el VARRAY
        reg_general.rendimiento := (reg_general.ptje_experiencia * v_ponderadores(1)) + 
                                 (reg_general.ptje_productividad * v_ponderadores(2)) + 
                                  (reg_general.ptje_especialidad * v_ponderadores(3)) + 
                                  (reg_general.ptje_region * v_ponderadores(4));
                       
        -- Obtiene la clasificaci�n seg�n el indicador obtenido
        SELECT descripcion_clase INTO reg_general.clasificacion
        FROM clasificacion_medico
        WHERE reg_general.rendimiento BETWEEN limite_inferior AND limite_superior;

        -- Inserta registro en la tabla de resultado general controlando duplicados (DUP_VAL_ON_INDEX)[cite: 4, 5]
        BEGIN
            INSERT INTO informe_general VALUES (
                reg_medico.rut,
                reg_medico.nombre,
                reg_medico.especialidad_id,
                reg_medico.anios_exp,
                reg_medico.cant_atenciones,
                reg_general.ptje_experiencia,
                reg_general.ptje_productividad,
                reg_general.ptje_especialidad,
                reg_general.ptje_region,
                reg_general.rendimiento,
                reg_general.clasificacion
            );
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            v_cod_error := SQLCODE;
            v_msg_error := SQLERRM;
            INSERT INTO errores_informe (id_error, fecha_error, codigo_error, descripcion_error)
            VALUES (SEQ_ERROR_INFORME.NEXTVAL, SYSDATE, v_cod_error, v_msg_error);
        END;
    END LOOP;
    COMMIT;
END;
