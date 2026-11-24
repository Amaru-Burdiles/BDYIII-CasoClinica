/* LIMPIEZA DE TABLAS */
DROP TABLE clasificacion_medico;
DROP TABLE informe_errores;
DROP TABLE informe_rendimiento;
DROP TABLE bitacora_cancelacion;
DROP SEQUENCE seq_informe_errores;


/* ------------------------- CREACION DE OBJEOS ----------------------------- */


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
CREATE TABLE informe_errores
(
    id_error NUMBER PRIMARY KEY,
    fecha_error DATE NOT NULL,
    codigo_error VARCHAR2(15) NOT NULL,
    descripcion_error VARCHAR2(100) NOT NULL
);



/*=======================
-- Informe Rendimiento --
=======================*/
CREATE TABLE informe_rendimiento
(
    -- Info del medico
    rut VARCHAR2(9) NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    anios_exp NUMBER NOT NULL,
    cant_atenciones NUMBER NOT NULL,
    
    -- Puntajes y clasificacion
    ptje_experiencia NUMBER NOT NULL,
    ptje_productividad NUMBER NOT NULL,
    ptje_especialidad NUMBER NOT NULL,
    ptje_region NUMBER NOT NULL,
    rendimiento NUMBER NOT NULL,
    clasificacion VARCHAR2(10) NOT NULL,
    
    -- Especificaciones del informe
    periodo_filtrado NUMBER NOT NULL,
    fecha_informe DATE NOT NULL
);

ALTER TABLE informe_rendimiento
ADD CONSTRAINT PK_informe_rendimiento PRIMARY KEY (
    rut,
    nombre,
    especialidad,
    anios_exp,
    cant_atenciones,
    ptje_experiencia,
    ptje_productividad,
    ptje_especialidad,
    ptje_region,
    rendimiento,
    clasificacion,
    periodo_filtrado,
    fecha_informe
);



/*========================
-- Bitacora Cancelacion --
========================*/
CREATE TABLE bitacora_cancelacion
(
    id_consulta NUMBER NOT NULL,
    fecha_cambio DATE NOT NULL,
    encargado VARCHAR2(100) NOT NULL,
    motivo VARCHAR2(600) NOT NULL
);

ALTER TABLE bitacora_cancelacion
ADD CONSTRAINT PK_bitacora PRIMARY KEY (id_consulta, fecha_cambio);



/*=====================
-- Secuencia Errores --
=====================*/
CREATE SEQUENCE SEQ_ERROR_INFORME;


/* ------------------------- INSERSION DE DATOS ----------------------------- */

/*========================
-- Clasificacion Medico --
========================*/
INSERT INTO clasificacion_medico VALUES(1, 'Bajo', 0, 99);
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
    PROCEDURE prc_especialidad(p_id NUMBER, nombre OUT VARCHAR, puntaje OUT NUMBER);
    
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
    -- ESPECIALIDAD
    PROCEDURE prc_especialidad(p_id NUMBER, nombre OUT VARCHAR, puntaje OUT NUMBER)
    IS
    BEGIN
        -- Obtiene el nombre de la especialidad y su puntaje
        SELECT es.nombre, es.puntaje
        INTO nombre, puntaje
        FROM especialidad es
        WHERE p_id = es.id;
    END;
    
    -- EXPERIENCIA
    FUNCTION fn_experiencia(p_experiencia NUMBER)
    RETURN NUMBER
    IS
        -- Almacena el puntaje de experiencia del medico
        v_ptje_experiencia NUMBER;
        
    BEGIN
        -- Obtiene el puntaje de experiencia 
        SELECT puntaje
        INTO v_ptje_experiencia
        FROM puntajeexperiencia
        WHERE p_experiencia BETWEEN anios_inicio AND anios_fin;
        
        -- Retorna el valor calculado
        RETURN v_ptje_experiencia;
    END;
    
    -- PRODUCTIVIDAD
    FUNCTION fn_productividad(p_atenciones NUMBER)
    RETURN NUMBER
    IS
        -- Almacena el puntaje de productividad del medico
        v_ptje_productividad NUMBER;
        
    BEGIN
        -- Obtiene el puntaje de productividad del medico mediante el total de atenciones
        SELECT puntaje
        INTO v_ptje_productividad
        FROM puntajeproductividad
        WHERE p_atenciones BETWEEN atenciones_inicio AND atenciones_fin;
        
        -- Retorna el puntaje calculado
        RETURN v_ptje_productividad;
    END;
    
    -- REGION
    FUNCTION fn_region(p_run_medico NUMBER)
    RETURN NUMBER
    IS
        -- Almacena el puntaje asociado a la region
        v_ptje_region NUMBER;
        
    BEGIN
        -- Obtiene el puntaje de region 
        SELECT MAX(r.puntaje)
        INTO v_ptje_region
        FROM region r JOIN clinica c ON (r.id = c.region_id)
                      JOIN consulta co ON (c.id = co.clinica_id)
        WHERE co.medico_rut = p_run_medico;
        
        -- Retorna el puntaje calculado
        RETURN v_ptje_region;
    END;
    
END;



/*=============================
-- Package Insertar Registro --
=============================*/
CREATE OR REPLACE PACKAGE pkg_insertar
IS
    /* Inserta registros al Informe Rendimiento
       Input: ; Output: Void */
    PROCEDURE prc_informe_rendimiento(
        p_rut VARCHAR,
        p_nombre VARCHAR,
        p_especialidad VARCHAR,
        p_anios_exp NUMBER,
        p_cant_atenciones NUMBER,
        p_ptje_experiencia NUMBER,
        p_ptje_productividad NUMBER,
        p_ptje_especialidad NUMBER,
        p_ptje_region NUMBER,
        p_rendimiento NUMBER,
        p_clasificacion VARCHAR,
        p_periodo NUMBER
    );
    
    
    
    /* Inserta registros a la bitacora de consultas canceladas 
       Input: NUMBER; Output: Void */
    PROCEDURE prc_consulta_cancelada(p_id_consulta NUMBER);
    


    /* Inserta registros al Informe errores
       Input: NUMBER, VARCHAR; Output: Void */
    PROCEDURE prc_informe_errores(v_codigo NUMBER, v_mensaje VARCHAR);

END;

/* IMPLEMENTACION */
CREATE OR REPLACE PACKAGE BODY pkg_insertar
IS 
    -- INFORME ERRORES
    PROCEDURE prc_informe_errores(v_codigo NUMBER, v_mensaje VARCHAR)
    IS
    BEGIN
        -- Inserta el error en la tabla informe errores
        INSERT INTO informe_errores
            VALUES (seq_error_informe.NEXTVAL, SYSDATE, v_codigo, v_mensaje);
        
    END;
    

    -- INFORME RENDIMIENTO
    PROCEDURE prc_informe_rendimiento(
        p_rut VARCHAR,
        p_nombre VARCHAR,
        p_especialidad VARCHAR,
        p_anios_exp NUMBER,
        p_cant_atenciones NUMBER,
        p_ptje_experiencia NUMBER,
        p_ptje_productividad NUMBER,
        p_ptje_especialidad NUMBER,
        p_ptje_region NUMBER,
        p_rendimiento NUMBER,
        p_clasificacion VARCHAR,
        p_periodo NUMBER
    )
    IS
        -- Almacena el codigo y mensaje del error
        v_cod_error NUMBER;
        v_msg_error informe_errores.descripcion_error%TYPE;
        
    BEGIN
        -- Inserta un ragistro en la tabla informe rendimiento
        INSERT INTO informe_rendimiento VALUES (
                p_rut,
                p_nombre,
                p_especialidad,
                p_anios_exp,
                p_cant_atenciones,
                p_ptje_experiencia,
                p_ptje_productividad,
                p_ptje_especialidad,
                p_ptje_region,
                p_rendimiento,
                p_clasificacion,
                p_periodo,
                SYSDATE
            );
        EXCEPTION -- Try-Catch: En caso que los datos esten duplicados
            WHEN DUP_VAL_ON_INDEX THEN
                -- Captura los datos del error
                v_cod_error := SQLCODE;
                v_msg_error := SQLERRM;
                
                -- Guarda el error
                prc_informe_errores(v_cod_error, v_msg_error);
    END;
    
    
    -- CONSULTA CANCELADA
    PROCEDURE prc_consulta_cancelada(p_id_consulta NUMBER)
    IS
        -- Almacena el motivo de la cancelacion
        v_motivo bitacora_cancelacion.motivo%TYPE;
        
        -- Almacena el codigo y mensaje del error
        v_cod_error NUMBER;
        v_msg_error informe_errores.descripcion_error%TYPE;
        
    BEGIN
        -- Pide el motivo al usuario
        v_motivo := '&Ingrese el motivo de la cancelacion: ';
    
        -- Inserta el registro en la bitacora
        INSERT INTO bitacora_cancelacion
            VALUES(p_id_consulta, SYSDATE, USER, v_motivo);
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- Captura la info del error
            v_cod_error := SQLCODE();
            v_msg_error := SQLERRM();
            
            -- Delega la insercion al informe error
            prc_informe_errores(v_cod_error, v_msg_error);
    END;
    
END;



/*======================
-- Funcion Almacenada --
======================*/
CREATE OR REPLACE FUNCTION fn_rendimiento(
        p_experiencia NUMBER, p_ponderacion_ex NUMBER,
        p_productividad NUMBER, p_ponderacion_pr NUMBER,
        p_especialidad NUMBER, p_ponderacion_es NUMBER,
        p_region NUMBER, p_ponderacion_re NUMBER
)
RETURN NUMBER
IS
    -- Almacena el puntaje de rendimeinto
    v_ptje_rendimiento NUMBER;
    
BEGIN
    -- Calcula el rendimiento utilizando los valores dados
    v_ptje_rendimiento := (p_experiencia * p_ponderacion_ex) 
                        + (p_productividad * p_ponderacion_pr)
                        + (p_especialidad * p_ponderacion_es) 
                        + (p_region * p_ponderacion_re);
    
    -- Retorna el valor calculado
    RETURN v_ptje_rendimiento;
END;



/*======================
-- Funcion Almacenada --
======================*/
CREATE OR REPLACE FUNCTION fn_clasificar_medico(p_rendimiento NUMBER)
RETURN VARCHAR
IS
    -- Almacena la clasificiacion
    v_clasificacion clasificacion_medico.descripcion_clase%TYPE;
    
BEGIN
    -- Obtiene la clasificacion segun el rendimiento
    SELECT descripcion_clase
    INTO v_clasificacion
    FROM clasificacion_medico
    WHERE p_rendimiento BETWEEN limite_inferior AND limite_superior;
    
    -- Retorna el valor obtenido
    RETURN v_clasificacion;
END;



/*=========================
-- Trigger Regla Negocio --
=========================*/
CREATE OR REPLACE TRIGGER trg_sin_consultas
AFTER INSERT
ON informe_rendimiento
FOR EACH ROW
DECLARE
    -- Almacenan el codigo y mensaje del error
    v_cod_error NUMBER;
    v_msg_error informe_errores.descripcion_error%TYPE;
    
BEGIN
    IF :NEW.cant_atenciones = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El medico no posee atenciones realizadas durante el periodo de analisis.');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Captura los datos del error
        v_cod_error := SQLCODE();
        v_msg_error := SQLERRM();
        
        -- Deja registro del error
        pkg_insertar.prc_informe_errores(v_cod_error, v_msg_error);
END;



/*======================
-- Trigger Auditorias --
======================*/
CREATE OR REPLACE TRIGGER trg_consulta_cancelada
AFTER UPDATE
ON consulta
FOR EACH ROW
DECLARE
BEGIN
    -- Verifica si el estado de la consulta se marco como 'cancelada'
    IF LOWER(:NEW.estado) = 'cancelada' THEN
       pkg_insertar.prc_consulta_cancelada(:OLD.id);
    END IF;
END;



/*============================
-- Procedimiento Almacenado --
============================*/
CREATE OR REPLACE PROCEDURE prc_meta_consultas(
    p_meta NUMBER, p_rut_medico NUMBER, p_ptje_region OUT NUMBER
)
IS
    -- Almacena la cantidad de consultas de la clinica
    v_consultas_clinica NUMBER;
    
BEGIN
    -- Obtiene la cantidad total de consultas de la clinica
    SELECT *
    FROM consulta c;
    
    -- Determina si la cantidad de consultas es inferior al 80% de la meta 
    IF (p_consultas / p_meta) < (p_meta * 0.8) THEN
        -- Reduce el puntaje
        p_ptje_region := p_ptje_region - (p_ptje_region * 0.05);
    END IF;
END;



/*===========================
-- Procedimiento Principal --
===========================*/
CREATE OR REPLACE PROCEDURE prc_generar_informe(
    p_year NUMBER,
    p_meta NUMBER,
    p_pond_exp NUMBER,
    p_pond_pro NUMBER,
    p_pond_esp NUMBER,
    p_pond_reg NUMBER
)
IS
    -- Almacena la informacion del medico, filtrando por el a�o de la consulta
    CURSOR c_medicos(p_year NUMBER) IS 
        SELECT m.rut,
               m.dv,
               m.nombre,
               m.especialidad_id,
               TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_ingreso)/ 12) anios_exp,
               COUNT(c.id) cant_atenciones,
               c.clinica_id
        FROM medico m JOIN consulta c ON(m.rut = c.medico_rut)
        WHERE EXTRACT(YEAR FROM c.fecha) = p_year
                     AND UPPER(c.estado) = 'REALIZADA'
        GROUP BY m.rut,
                 m.dv,
                 m.nombre,
                 m.especialidad_id,
                 TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_ingreso)/ 12);
    
    -- Define una estructura para agrupar los resultados de cursores implicitos
    TYPE camposInforme IS RECORD (
        nomb_especialidad   especialidad.nombre%TYPE,
        ptje_experiencia    informe_rendimiento.ptje_experiencia%TYPE,
        ptje_productividad  informe_rendimiento.ptje_productividad%TYPE,
        ptje_especialidad   informe_rendimiento.ptje_especialidad%TYPE,
        ptje_region         informe_rendimiento.ptje_region%TYPE,
        rendimiento         informe_rendimiento.rendimiento%TYPE,
        clasificacion       informe_rendimiento.clasificacion%TYPE
    );
    
    -- Almacena todos los datos necesarios para el informe
    reg_informe camposInforme;
     
BEGIN
    /* BUCLE PRINCIPAL */
    --Recorre el registro de los medicos pasando a cada uno el a�o a filtrar
    FOR reg_medico IN c_medicos(p_year) LOOP
        
        -- Delega una funcion para calcular el puntaje experiencia
        reg_informe.ptje_experiencia := pkg_calc_puntaje.fn_experiencia(reg_medico.anios_exp);
        
        -- Delega un procedimiento para obtener la especialidad y su puntaje
        pkg_calc_puntaje.prc_especialidad(
            reg_medico.especialidad_id,
            reg_informe.nomb_especialidad,
            reg_informe.ptje_especialidad
        );
    
        -- Delega una funcion para calcular el puntaje de productividad
        reg_informe.ptje_productividad := pkg_calc_puntaje.fn_productividad(reg_medico.cant_atenciones);

        -- Delega una funcion para calcular el puntaje region
        reg_informe.ptje_region := pkg_calc_puntaje.fn_region(reg_medico.rut);
        
        -- Delegamos una funcion para calcular el rendimiento
        reg_informe.rendimiento := pkg_calc_puntaje.fn_rendimiento(
            reg_informe.ptje_experiencia, p_pond_exp,
            reg_informe.ptje_productividad, p_pond_pro,
            reg_informe.ptje_especialidad, p_pond_esp,
            reg_informe.ptje_region, p_pond_reg
        );
                       
        -- Delega una funcion para clasificar al medico
        reg_informe.clasificacion := fn_clasificar_medico(reg_informe.rendimiento);
        
        -- Delega un procedimiento para determinar si se cumple la meta
        prc_meta_consultas(p_meta, reg_medico.cant_atenciones, reg_informe.ptje_region);

        -- Delega un procedimiento para guardar el informe controlando duplicados
        pkg_insertar.prc_informe_rendimiento(
            reg_medico.rut,
            reg_medico.nombre,
            reg_informe.nomb_especialidad,
            reg_medico.anios_exp,
            reg_medico.cant_atenciones,
            reg_informe.ptje_experiencia,
            reg_informe.ptje_productividad,
            reg_informe.ptje_especialidad,
            reg_informe.ptje_region,
            reg_informe.rendimiento,
            reg_informe.clasificacion,
            p_year
        );
    END LOOP;
END;



/*==================
-- Bloque Anonimo --
==================*/
DECLARE
    -- Define un tipo de dato compuesto que almacena numeros
    TYPE numArray IS VARRAY(4) OF NUMBER;
    
    -- Almacena el listado con los ponderadores
    v_ponderadores numArray;
    
    -- Almacena el a�o a filtrar
    v_filtro NUMBER;
    
    -- Almacena la meta de consultas por clinica
    v_meta NUMBER;
        
BEGIN
    /* INICIALIZACION DE VARIBLES */
    -- Ingrece los ponderadores para cada puntaje en el siguiente orden:
    --           experiencia, productividad, especialidad, region
    v_ponderadores := numArray(0.25, 0.25, 0.25, 0.25);
    
    -- Ingrece el a�o a filtrar
    v_filtro := 2026;
    
    -- Llama al procedimiento principal
    prc_generar_informe(
        v_filtro,
        v_ponderadores(1),
        v_ponderadores(2),
        v_ponderadores(3),
        v_ponderadores(4)
    );
    
    COMMIT;
END;


/*===========
-- Testing --
===========*/
SELECT *
FROM medico m LEFT JOIN especialidad e ON (m.especialidad_id = e.id);

SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_medicos IS
        SELECT
        m.rut,
        m.especialidad_id
        FROM medico m;
    
    v_resultado especialidad.nombre%TYPE;
    v_puntaje NUMBER;
    
BEGIN

    FOR reg_m IN c_medicos LOOP
        pkg_calc_puntaje.prc_especialidad(reg_m.especialidad_id, v_resultado, v_puntaje);
        
        DBMS_OUTPUT.PUT_LINE(reg_m.rut || ' ' || v_resultado || ' ' || v_puntaje);
    
    END LOOP;    
END;
