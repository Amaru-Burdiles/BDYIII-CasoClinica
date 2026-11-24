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
CREATE TABLE informe_rendimiento
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
    
    /* Calcula el rendimiento en base a especialidad, productividad, exp, region
       y sus respectivas ponderaciones. Si estas ultimas son 0 se usa un defecto
       Input: NUMBER, NUMBER, NUMBER, NUMBER; Output: NUMBER */
    FUNCTION fn_rendimiento(p_especialidad NUMBER, p_ponderacion_es NUMBER,
                            p_productividad NUMBER, p_ponderacion_pr NUMBER,
                            p_experiencia NUMBER, p_ponderacion_ex NUMBER,
                            p_region NUMBER, p_ponderacion_re NUMBER)
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
        -- Obtiene el puntaje de experiencia 
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
        -- Obtiene el puntaje de productividad del medico mediante el total de atenciones
        SELECT puntaje
        INTO v_ptje_productividad
        FROM puntajeproductividad
        WHERE p_atenciones BETWEEN atenciones_inicio AND atenciones_fin;
        
        -- Retorna el puntaje calculado
        RETURN v_ptje_productividad;
    END;
    
    -- FUNCION PUBLICA
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
    
    -- FUNCION PUBLICA
    FUNCTION fn_rendimiento(p_experiencia NUMBER, p_ponderacion_ex NUMBER,
                            p_productividad NUMBER, p_ponderacion_pr NUMBER,
                            p_especialidad NUMBER, p_ponderacion_es NUMBER,
                            p_region NUMBER, p_ponderacion_re NUMBER)
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
        p_clasificacion VARCHAR
    );

END;

/* IMPLEMENTACION */
CREATE OR REPLACE PACKAGE BODY pkg_insertar
IS
    -- PROCEDIMIENTO PRIVADO
    PROCEDURE prc_informe_errores(v_codigo NUMBER, v_mensaje VARCHAR)
    IS
    BEGIN
        -- Inserta el error en la tabla informe errores
        INSERT INTO errores_informe
            VALUES (seq_error_informe.NEXTVAL, SYSDATE, v_codigo, v_mensaje);
        
    END;
    
    -- PROCEDIMIENTO PUBLICO
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
        p_clasificacion VARCHAR
    )
    IS
    BEGIN
        -- Inserta un ragistro en la tabla informe rendimiento
        INSERT INTO informe_rendimieto VALUES (
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
                p_clasificacion
            );
        EXCEPTION -- Try-Catch: En caso que los datos esten duplicados
            WHEN DUP_VAL_ON_INDEX THEN
                -- Captura los datos del error
                v_cod_error := SQLCODE;
                v_msg_error := SQLERRM;
                
                -- Guarda el error
                pprc_informe_errores(v_cod_error, v_msg_error);
    END;
    
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

        -- funcion region
        
        -- funcion rendimiento
                       
        -- funcion clasificacion

        -- Inserta registro en la tabla de resultado general controlando duplicados
    END LOOP;
    COMMIT;
END;
