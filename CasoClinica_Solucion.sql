/* ELIMINA TABLAS SI EXISTEN */
DROP TABLE clasificacion_medico;
DROP TABLE errores_informe;
DROP SEQUENCE SEQ_ERROR_INFORME;
DROP TABLE informe_general;

/* CREACIÓN DE TABLAS ==========================================*/
-- Crea la tabla usada para determinar la clasificación del médico
CREATE TABLE clasificacion_medico
(
    id_clase NUMBER PRIMARY KEY,
    descripcion_clase VARCHAR2(15) NOT NULL,
    limite_inferior NUMBER NOT NULL,
    limite_superior NUMBER NOT NULL
);


-- Crea la tabla para almacenar los errores, tanto del sistema como del negocio
CREATE TABLE errores_informe
(
    id_error NUMBER PRIMARY KEY,
    fecha_error DATE NOT NULL,
    codigo_error VARCHAR2(15) NOT NULL,
    descripcion_error VARCHAR2(100) NOT NULL
);


-- Crea la tabla para almacenar el informe resultante del bloque anónimo
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


/* CREACION DE SECUENCIA */
-- Crea la secuencia usada como clave primaria en la tabla errores
CREATE SEQUENCE SEQ_ERROR_INFORME;


/* INSERSION DE DATOS */
-- Puebla la tabla con las categorias y sus rangos
INSERT INTO clasificacion_medico VALUES(1, 'Bajo', 0, 99);
INSERT INTO clasificacion_medico VALUES(2, 'Medio', 100, 199);
INSERT INTO clasificacion_medico VALUES(3, 'Alto', 200, 274);


/* DESARROLLO BLOQUE ANÓNIMO */
DECLARE
    -- Almacena la información del médico, filtrando por el año de la consulta
    CURSOR c_medicos(p_year NUMBER) IS 
        SELECT m.rut,
               m.dv,
               m.nombre,
               es.nombre nombre_especialidad,
               TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_ingreso)/ 12) anios_exp
        FROM medico m JOIN consulta c ON(m.rut = c.medico_rut)
                      JOIN especialidad es ON (m.especialidad_id = es.id)
        WHERE EXTRACT(YEAR FROM c.fecha) = p_year
                     AND UPPER(c.estado) = 'REALIZADA';
    
    -- Almacena la calificación del médico
    
    -- Almacena el total de atenciones del medico
    
    -- Almacena el puntaje de experiencia del medico
    
    -- Almacena el puntaje de productividad del medico
    
    -- Almacena el puntaje de la especialidad del medico
    
    -- Alamcena el puntaje de la region que pertenece el medico
    
    -- Alamcena el rendimiento del medico
    
    -- Define un tipo de dato compuesto que almacena numeros
    TYPE numArray IS VARRAY(4) OF NUMBER;
    
    -- Almacena el listado con los ponderadores
    v_ponderadores numArray;

    
    -- Define una estructura para capturar
    TYPE registro_g IS RECORD (
        cant_atenciones     informe_general.cant_atenciones%TYPE,
        ptje_experiencia    informe_general.ptje_experiencia%TYPE,
        ptje_productividad  informe_general.ptje_productividad%TYPE,
        ptje_especialidad   informe_general.ptje_especialidad%TYPE,
        ptje_region         informe_general.ptje_region%TYPE,
        rendimiento         informe_general.rendimiento%TYPE,
        clasificacion       informe_general.clasificacion%TYPE
    );
    reg_general registro_g;
    
    -- Almacenan el código y descripción del error temporalmente antes del Insert
    v_cod_error errores_informe.codigo_error%TYPE;
    v_msg_error errores_informe.descripcion_error%TYPE;
    
    -- Almacena el año a filtrar
    v_filtro NUMBER;
        
BEGIN
    /* INICIALIZACIÓN DE VARIBLES */
    -- Inicializa los valores de los ponderadores en el VARRAY
    v_ponderadores := numArray(0.25, 0.25, 0.25, 0.25);
    
    -- Inicializa el año a filtrar
    v_filtro := 2026;
    
    /* BUCLE PRINCIPAL */
    --Recorre el registro de los médicos pasandole a cada uno el año a filtrar
    FOR reg_medico IN c_medicos(v_filtro) LOOP
        
        -- Obtiene el total de atenciones realizadas por el medico
        SELECT COUNT(id) INTO reg_general.cant_atenciones
        FROM consulta c
        WHERE c.medico_rut = reg_medico.rut AND EXTRACT(YEAR FROM fecha) = v_filtro --nosegura
            AND UPPER(c.estado) = 'REALIZADA';
        
        -- Verifica regla de negocio (se lanza la excepcion definida por usuario)
        BEGIN
            IF reg_general.cant_atenciones = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'El médico no posee atenciones realizadas 
                                        durante el período de análisis.');
            END IF;
        -- Captura el error    
        EXCEPTION WHEN OTHERS THEN
            -- Recopila el codigo y mensaje de error para pasarlo al insert
            v_cod_error := SQLCODE;
            v_msg_error := SQLERRM;
            
            INSERT INTO errores_informe (id_error, fecha_error, codigo_error, descripcion_error)
            VALUES (SEQ_ERROR_INFORME.NEXTVAL, SYSDATE, v_cod_error, v_msg_error);
        END;
        
        --Obtiene el puntaje de experiencia 
        SELECT puntaje INTO reg_general.ptje_experiencia
        FROM puntajeexperiencia
        WHERE reg_medico.anios_exp BETWEEN anios_inicio AND anios_fin;
    
        --Obtiene el puntaje de productividad del medico mediante el total de atenciones
        SELECT puntaje INTO reg_general.ptje_productividad
        FROM puntajeproductividad
        WHERE reg_general.cant_atenciones BETWEEN atenciones_inicio AND atenciones_fin;
        
        --Obtiene el puntaje de especialidad
        SELECT es.puntaje INTO reg_general.ptje_especialidad
        FROM especialidad es
        WHERE es.nombre = reg_medico.nombre_especialidad;

        --Obtiene el puntaje de region 
        SELECT MAX(r.puntaje) INTO reg_general.ptje_region
        FROM region r JOIN clinica c ON (r.id = c.region_id)
        JOIN consulta co ON (c.id = co.clinica_id)
        WHERE co.medico_rut = reg_medico.rut;
        
        -- Cálculo del indicador integral utilizando los valores almacenados en el VARRAY
        reg_general.rendimiento := (reg_general.ptje_experiencia * v_ponderadores(1)) + 
                                 (reg_general.ptje_productividad * v_ponderadores(2)) + 
                                  (reg_general.ptje_especialidad * v_ponderadores(3)) + 
                                  (reg_general.ptje_region * v_ponderadores(4));
                       
        -- Obtiene la clasificación según el indicador obtenido
        SELECT descripcion_clase INTO reg_general.clasificacion
        FROM clasificacion_medico
        WHERE reg_general.rendimiento BETWEEN limite_inferior AND limite_superior;

        -- Inserta registro en la tabla de resultado general controlando duplicados (DUP_VAL_ON_INDEX)[cite: 4, 5]
        BEGIN
            INSERT INTO informe_general VALUES (
                reg_medico.rut,
                reg_medico.nombre,
                reg_medico.nombre_especialidad,
                reg_medico.anios_exp,
                reg_general.cant_atenciones,
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
