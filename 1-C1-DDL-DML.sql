-- Generado por Oracle SQL Developer Data Modeler 21.4.1.349.1605
--   en:        2026-08-02 21:56:52 CLT
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g

DROP TABLE categoria CASCADE CONSTRAINTS;
DROP TABLE clinica CASCADE CONSTRAINTS;
DROP TABLE consulta CASCADE CONSTRAINTS;
DROP TABLE detalle CASCADE CONSTRAINTS;
DROP TABLE especialidad CASCADE CONSTRAINTS;
DROP TABLE medico CASCADE CONSTRAINTS;
DROP TABLE paciente CASCADE CONSTRAINTS;
DROP TABLE procedimiento CASCADE CONSTRAINTS;
DROP TABLE prevision CASCADE CONSTRAINTS;
DROP TABLE puntajeexperiencia CASCADE CONSTRAINTS;
DROP TABLE puntajeproductividad CASCADE CONSTRAINTS;
DROP TABLE region CASCADE CONSTRAINTS;
DROP TABLE resultadodesempeno CASCADE CONSTRAINTS;

CREATE TABLE categoria (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(40),
    descripcion VARCHAR2(70)
);

ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( id );

CREATE TABLE clinica (
    id             INTEGER NOT NULL,
    nombre         VARCHAR2(30) NOT NULL,
    direccion      VARCHAR2(50) NOT NULL,
    meta_pacientes INTEGER NOT NULL,
    region_id      INTEGER NOT NULL
);

ALTER TABLE clinica ADD CONSTRAINT clinica_pk PRIMARY KEY ( id );

CREATE TABLE consulta (
    id           INTEGER NOT NULL,
    fecha        DATE NOT NULL,
    estado       VARCHAR2(15) NOT NULL,
    medico_rut   INTEGER NOT NULL,
    paciente_rut INTEGER NOT NULL,
    clinica_id   INTEGER NOT NULL
);

ALTER TABLE consulta ADD CONSTRAINT consulta_pk PRIMARY KEY ( id );

CREATE TABLE detalle (
    cantidad         INTEGER NOT NULL,
    valor            INTEGER NOT NULL,
    procedimiento_id INTEGER NOT NULL,
    consulta_id      INTEGER NOT NULL
);

ALTER TABLE detalle ADD CONSTRAINT detalle_pk PRIMARY KEY ( procedimiento_id,
                                                            consulta_id );


CREATE TABLE especialidad (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(40) NOT NULL,
    puntaje INTEGER NOT NULL
);

ALTER TABLE especialidad ADD CONSTRAINT especialidad_pk PRIMARY KEY ( id );

CREATE TABLE medico (
    rut             INTEGER NOT NULL,
    dv              VARCHAR2(1) NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    fecha_ingreso   DATE NOT NULL,
    especialidad_id INTEGER NOT NULL
);

ALTER TABLE medico ADD CONSTRAINT medico_pk PRIMARY KEY ( rut );

CREATE TABLE paciente (
    rut              INTEGER NOT NULL,
    dv               VARCHAR2(1) NOT NULL,
    nombre           VARCHAR2(40) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    prevision_id     INTEGER NOT NULL,
    genero           VARCHAR2(1) NOT NULL 
);

ALTER TABLE paciente ADD CONSTRAINT paciente_pk PRIMARY KEY ( rut );

CREATE TABLE prevision (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(30) NOT NULL
);

ALTER TABLE prevision ADD CONSTRAINT prevision_pk PRIMARY KEY ( id );

CREATE TABLE procedimiento (
    id           INTEGER NOT NULL,
    nombre       VARCHAR2(50) NOT NULL,
    costo_base   INTEGER,
    categoria_id INTEGER NOT NULL
);

ALTER TABLE procedimiento ADD CONSTRAINT procedimiento_pk PRIMARY KEY ( id );

CREATE TABLE puntajeexperiencia (
    id           INTEGER NOT NULL,
    anios_inicio INTEGER NOT NULL,
    anios_fin    INTEGER NOT NULL,
    puntaje      INTEGER NOT NULL
);

ALTER TABLE puntajeexperiencia ADD CONSTRAINT puntajeexperiencia_pk PRIMARY KEY ( id );

CREATE TABLE puntajeproductividad (
    id                INTEGER NOT NULL,
    atenciones_inicio INTEGER NOT NULL,
    atenciones_fin    INTEGER NOT NULL,
    puntaje           INTEGER NOT NULL
);

ALTER TABLE puntajeproductividad ADD CONSTRAINT puntajeproductividad_pk PRIMARY KEY ( id );

CREATE TABLE region (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    puntaje   INTEGER NOT NULL
);

ALTER TABLE region ADD CONSTRAINT region_pk PRIMARY KEY ( id );

ALTER TABLE clinica
    ADD CONSTRAINT clinica_region_fk FOREIGN KEY ( region_id )
        REFERENCES region ( id );

ALTER TABLE consulta
    ADD CONSTRAINT consulta_clinica_fk FOREIGN KEY ( clinica_id )
        REFERENCES clinica ( id );

ALTER TABLE consulta
    ADD CONSTRAINT consulta_medico_fk FOREIGN KEY ( medico_rut )
        REFERENCES medico ( rut );

ALTER TABLE consulta
    ADD CONSTRAINT consulta_paciente_fk FOREIGN KEY ( paciente_rut )
        REFERENCES paciente ( rut );

ALTER TABLE detalle
    ADD CONSTRAINT detalle_consulta_fk FOREIGN KEY ( consulta_id )
        REFERENCES consulta ( id );

ALTER TABLE detalle
    ADD CONSTRAINT detalle_procedimiento_fk FOREIGN KEY ( procedimiento_id )
        REFERENCES procedimiento ( id );

ALTER TABLE medico
    ADD CONSTRAINT medico_especialidad_fk FOREIGN KEY ( especialidad_id )
        REFERENCES especialidad ( id );

ALTER TABLE paciente
    ADD CONSTRAINT paciente_prevision_fk FOREIGN KEY ( prevision_id )
        REFERENCES prevision ( id );

ALTER TABLE procedimiento
    ADD CONSTRAINT procedimiento_categoria_fk FOREIGN KEY ( categoria_id )
        REFERENCES categoria ( id );


-- ============================================================================
-- SCRIPT DML DATA POBLAMIENTO - ORACLE DATABASE 11g+
-- ============================================================================
SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- 1. TABLAS INDEPENDIENTES / MAESTRAS BASE
-- ----------------------------------------------------------------------------

-- REGION
INSERT INTO region (id, nombre, puntaje) VALUES (1, 'Tarapacá', 150);
INSERT INTO region (id, nombre, puntaje) VALUES (2, 'Antofagasta', 120);
INSERT INTO region (id, nombre, puntaje) VALUES (3, 'Atacama', 130);
INSERT INTO region (id, nombre, puntaje) VALUES (4, 'Coquimbo', 100);
INSERT INTO region (id, nombre, puntaje) VALUES (5, 'Valparaíso', 80);
INSERT INTO region (id, nombre, puntaje) VALUES (6, 'Región del Libertador Gral. Bernardo O''Higgins', 90);
INSERT INTO region (id, nombre, puntaje) VALUES (7, 'Región del Maule', 100);
INSERT INTO region (id, nombre, puntaje) VALUES (8, 'Región del Bío-Bío', 90);
INSERT INTO region (id, nombre, puntaje) VALUES (9, 'Región de la Araucanía', 110);
INSERT INTO region (id, nombre, puntaje) VALUES (10, 'Región de los Lagos', 120);
INSERT INTO region (id, nombre, puntaje) VALUES (11, 'Región Aysén del Gral. Carlos Ibáñez del Campo', 180);
INSERT INTO region (id, nombre, puntaje) VALUES (12, 'Región de Magallanes y de la Antártica Chilena', 200);
INSERT INTO region (id, nombre, puntaje) VALUES (13, 'Región Metropolitana de Santiago', 50);
INSERT INTO region (id, nombre, puntaje) VALUES (14, 'Región de los Ríos', 110);
INSERT INTO region (id, nombre, puntaje) VALUES (15, 'Arica y Parinacota', 160);
INSERT INTO region (id, nombre, puntaje) VALUES (16, 'Región del Ñuble', 100);

-- PREVISION
INSERT INTO prevision (id, nombre) VALUES (1, 'FONASA A');
INSERT INTO prevision (id, nombre) VALUES (2, 'FONASA B');
INSERT INTO prevision (id, nombre) VALUES (3, 'FONASA C');
INSERT INTO prevision (id, nombre) VALUES (4, 'FONASA D');
INSERT INTO prevision (id, nombre) VALUES (5, 'Isapre Banmédica');
INSERT INTO prevision (id, nombre) VALUES (6, 'Isapre Consalud');
INSERT INTO prevision (id, nombre) VALUES (7, 'Isapre Colmena');
INSERT INTO prevision (id, nombre) VALUES (8, 'Isapre Cruz Blanca');
INSERT INTO prevision (id, nombre) VALUES (9, 'Capredena / Dipreca');
INSERT INTO prevision (id, nombre) VALUES (10, 'Particular');

-- ESPECIALIDAD
INSERT INTO especialidad (id, nombre, puntaje) VALUES (101, 'Medicina General', 100);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (102, 'Pediatría', 150);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (103, 'Cardiología', 250);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (104, 'Dermatología', 200);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (105, 'Traumatología y Ortopedia', 220);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (106, 'Ginecología y Obstetricia', 200);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (107, 'Neurología', 240);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (108, 'Oftalmología', 210);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (109, 'Psiquiatría', 180);
INSERT INTO especialidad (id, nombre, puntaje) VALUES (110, 'Oncología Médica', 300);

-- CATEGORIA (Procedimientos)
INSERT INTO categoria (id, nombre, descripcion) VALUES (1, 'Consultas y Exámenes', 'Atenciones básicas de diagnóstico y evaluación médica');
INSERT INTO categoria (id, nombre, descripcion) VALUES (2, 'Imagenología', 'Estudios de diagnóstico por imágenes como rayos X y resonancias');
INSERT INTO categoria (id, nombre, descripcion) VALUES (3, 'Laboratorio Clínico', 'Análisis bioquímicos y hematológicos de muestras');
INSERT INTO categoria (id, nombre, descripcion) VALUES (4, 'Procedimientos Quirúrgicos', 'Intervenciones ambulatorias o de mayor complejidad');
INSERT INTO categoria (id, nombre, descripcion) VALUES (5, 'Kinesiología y Rehabilitación', 'Sesiones de recuperación física y motora');

-- TABLAS DE ESCALAS Y MATRICES DE EVALUACIÓN
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (1, 0, 2, 50);
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (2, 3, 5, 100);
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (3, 6, 10, 180);
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (4, 11, 15, 250);
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (5, 16, 30, 350);
INSERT INTO puntajeexperiencia (id, anios_inicio, anios_fin, puntaje) VALUES (6, 31, 99, 400);

INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (1, 0, 50, 20);
INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (2, 51, 100, 60);
INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (3, 101, 200, 120);
INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (4, 201, 350, 200);
INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (5, 351, 500, 300);
INSERT INTO puntajeproductividad (id, atenciones_inicio, atenciones_fin, puntaje) VALUES (6, 501, 9999, 450);


-- 2. TABLAS Nivel 1 (Dependen de las tablas maestras)
-- ----------------------------------------------------------------------------

-- CLINICA
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (10, 'Clínica RedSalud Iquique', 'Av. Arturo Prat 1230', 400, 1);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (20, 'Clínica Bupa Antofagasta', 'Manuel Antonio Matta 1945', 550, 2);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (30, 'Clínica Ciudad del Mar', '13 Norte 635, Viña del Mar', 800, 5);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (40, 'Clínica Alemana Santiago', 'Av. Vitacura 5951', 1200, 13);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (50, 'Clínica Santa María', 'Av. Santa María 0500, Providencia', 1100, 13);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (60, 'Clínica Biobío', 'Av. Jorge Alessandri 3515, Talcahuano', 750, 8);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (70, 'Clínica Alemana Temuco', 'Senador Estébanez 645', 600, 9);
INSERT INTO clinica (id, nombre, direccion, meta_pacientes, region_id) VALUES (80, 'Clínica Puerto Montt', 'Av. Bellavista 123', 450, 10);

-- PROCEDIMIENTO
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5001, 'Consulta Médica General', 25000, 1);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5002, 'Consulta Médica Especializada', 45000, 1);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5003, 'Radiografía de Tórax', 35000, 2);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5004, 'Resonancia Magnética Cerebral', 180000, 2);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5005, 'Ecografía Abdominal', 55000, 2);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5006, 'Hemograma Completo', 12000, 3);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5007, 'Perfil Bioquímico', 22000, 3);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5008, 'Electrocardiograma Reposo', 28000, 1);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5009, 'Endoscopia Digestiva Alta', 120000, 4);
INSERT INTO procedimiento (id, nombre, costo_base, categoria_id) VALUES (5010, 'Sesión Kinesiología Motora', 20000, 5);

-- ============================================================================
-- SCRIPT DML DATA POBLAMIENTO - ORACLE DATABASE 11g+
-- ============================================================================
SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- 1. TABLAS INDEPENDIENTES / MAESTRAS BASE
-- ----------------------------------------------------------------------------

SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- ============================================================================
-- 1. MÉRIDA DE MÉDICOS (20 Registros)
-- ============================================================================
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (10111222, '3', 'Dr. Tomás Echeverría Vial', '2008-03-12', 101);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (11222333, '4', 'Dra. María Soledad Ossa', '2012-07-01', 102);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (12333444, '5', 'Dr. Gonzalo Undurraga Larraín', '2015-01-15', 103);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (13444555, '6', 'Dra. Paula Chadwick Errázuriz', '2019-09-20', 104);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (14555666, '7', 'Dr. Ignacio Matte Vicuña', '2010-11-05', 105);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (15666777, '8', 'Dra. Francisca Edwards Ross', '2017-04-18', 106);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (16777888, '9', 'Dr. Rodrigo Subercaseaux', '2014-02-10', 107);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (17888999, 'K', 'Dra. Camila Cousiño Balmaceda', '2021-08-14', 108);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (18999000, '1', 'Dr. Matías Izquierdo Huneeus', '2016-06-30', 109);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (19000111, '2', 'Dra. Andrea Lira Walker', '2013-10-12', 110);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (10222333, '1', 'Dr. Benjamín Cox Ugarte', '2009-05-22', 101);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (11333444, '2', 'Dra. Antonia Donoso Correa', '2018-01-08', 102);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (12444555, '3', 'Dr. Javier Fontaine Talavera', '2011-12-03', 103);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (13555666, '4', 'Dra. Beatriz Santa Cruz Rivas', '2020-03-19', 104);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (14666777, '5', 'Dr. Cristián Lyon Prieto', '2013-07-25', 105);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (15777888, '6', 'Dra. Daniela Zañartu Tocornal', '2016-09-11', 106);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (16888999, '7', 'Dr. Gabriel Ruiz-Tagle Portales', '2022-02-01', 107);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (17999000, '8', 'Dra. Lucía Ovalle Vergara', '2014-04-17', 108);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (18000111, '9', 'Dr. Nicolás Irarrázaval Barros', '2017-11-28', 109);
INSERT INTO medico (rut, dv, nombre, fecha_ingreso, especialidad_id) VALUES (19111222, '0', 'Dra. Valentina Mackenna Besa', '2019-06-05', 110);

-- ============================================================================
-- 2. PACIENTES (50 Registros)
-- ============================================================================
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10100100, '1', 'Esteban Silva Araya', '1980-01-15', 1, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10200200, '2', 'Claudia Sepúlveda Muñoz', '1985-03-22', 2, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10300300, '3', 'Jorge Contreras Espinoza', '1978-07-10', 3, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10400400, '4', 'Carolina Morales Torres', '1992-11-05', 4, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10500500, '5', 'Hernán Fuenzalida Castro', '1965-04-30', 5, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10600600, '6', 'Verónica Reyes Gallardo', '1995-09-18', 6, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10700700, '7', 'Guillermo Godoy Lagos', '1983-12-01', 7, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10800800, '8', 'Patricio Navarrete Soto', '1970-02-14', 8, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (10900900, '9', 'Marcela Bravo Valenzuela', '1988-06-25', 9, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11000100, 'K', 'Fernando Figueroa Palma', '2000-08-08', 10, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11100200, '0', 'Loreto Saavedra Vera', '1991-05-19', 1, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11200300, '1', 'Sebastián Tapia Orellana', '1987-10-11', 2, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11300400, '2', 'Camila Pizarro Salinas', '1994-01-27', 3, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11400500, '3', 'Diego Carrasco Poblete', '1999-03-03', 4, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11500600, '4', 'Natalia Fritz Parra', '1982-07-16', 5, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11600700, '5', 'Álvaro Bustos Sanhueza', '1976-12-24', 6, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11700800, '6', 'Gabriela Meza Pinto', '1990-04-09', 7, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11800900, '7', 'Manuel Arriagada Venegas', '1968-08-13', 8, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (11900100, '8', 'Constanza Leiva Farías', '1996-02-28', 9, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12000200, '9', 'Felipe Barraza Toledo', '1984-11-17', 10, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12100300, 'K', 'Pía Sandoval Henríquez', '1993-06-04', 1, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12200400, '0', 'Ricardo Ulloa Aguilera', '1979-09-21', 2, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12300500, '1', 'Daniela Yáñez Riquelme', '1986-01-02', 3, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12400600, '2', 'César Paredes Velozo', '1974-05-14', 4, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12500700, '3', 'Monique Durán Miranda', '1998-10-31', 5, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12600800, '4', 'Gonzalo Valdés Olivares', '1981-03-07', 6, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12700900, '5', 'Javiera Campos Godoy', '1997-07-23', 7, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12800100, '6', 'Cristian Inostroza Marín', '1969-12-12', 8, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (12900200, '7', 'Francisca Palma Zúñiga', '1989-08-04', 9, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13000300, '8', 'Ignacio Aedo Escalona', '2002-04-15', 10, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13100400, '9', 'Sofía Troncoso Mena', '1991-09-09', 1, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13200500, 'K', 'Vicente Salgado Cornejo', '1983-02-18', 2, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13300600, '0', 'Paula Villegas Acevedo', '1977-11-26', 3, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13400700, '1', 'Hugo Donoso Alarcón', '1963-06-30', 4, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13500800, '2', 'Carla Guerrero Becerra', '1995-01-11', 5, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13600900, '3', 'Andrés Vivanco Mella', '1988-05-08', 6, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13700100, '4', 'Bárbara Naranjo Hormazábal', '1990-10-20', 7, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13800200, '5', 'Mauricio Santibáñez Pino', '1972-03-14', 8, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (13900300, '6', 'Tamara Cárdenas Vidal', '1986-07-29', 9, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14000400, '7', 'Emilio Garrido Ruz', '1994-12-05', 10, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14100500, '8', 'Valeria Mansilla Oyarzún', '1980-08-17', 1, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14200600, '9', 'Esteban Plaza Bustamante', '1975-01-23', 2, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14300700, 'K', 'Isabel Mellado Carvajal', '1998-04-03', 3, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14400800, '0', 'Marcos Neira Sepúlveda', '1985-09-12', 4, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14500900, '1', 'Consuelo Saez Varga', '1992-06-21', 5, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14600100, '2', 'Renato Beltrán Quintana', '2001-11-09', 6, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14700200, '3', 'Camila Ocampo Farias', '1987-03-31', 7, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14800300, '4', 'Arturo Venegas Mardones', '1966-10-18', 8, 'M');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (14900400, '5', 'Elisa Quezada Arratia', '1993-02-07', 9, 'F');
INSERT INTO paciente (rut, dv, nombre, fecha_nacimiento, prevision_id, genero) VALUES (15000500, '6', 'Felipe Arancibia Guajardo', '1989-05-25', 10, 'M');

COMMIT;

DECLARE
    -- Tipos de colecciones para almacenar llaves existentes
    TYPE t_numbers IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    
    v_medicos_rut      t_numbers;
    v_pacientes_rut    t_numbers;
    v_clinicas_id      t_numbers;
    v_procedimientos   t_numbers;
    
    v_total_medicos       PLS_INTEGER;
    v_total_pacientes     PLS_INTEGER;
    v_total_clinicas      PLS_INTEGER;
    v_total_procedimientos PLS_INTEGER;

    v_consulta_id      INTEGER := 20000;
    v_medico_rut       INTEGER;
    v_paciente_rut     INTEGER;
    v_clinica_id       INTEGER;
    v_procedimiento_id INTEGER;
    v_estado           VARCHAR2(15);
    v_fecha            DATE;
    v_valor            INTEGER;
BEGIN
    -- 1. Cargar en memoria solo las llaves primarias QUE REALMENTE EXISTEN
    SELECT rut BULK COLLECT INTO v_medicos_rut FROM medico;
    SELECT rut BULK COLLECT INTO v_pacientes_rut FROM paciente;
    SELECT id  BULK COLLECT INTO v_clinicas_id FROM clinica;
    SELECT id  BULK COLLECT INTO v_procedimientos FROM procedimiento;

    -- Obtener la cantidad de registros recuperados
    v_total_medicos       := v_medicos_rut.COUNT;
    v_total_pacientes     := v_pacientes_rut.COUNT;
    v_total_clinicas      := v_clinicas_id.COUNT;
    v_total_procedimientos := v_procedimientos.COUNT;

    -- Validar que existan datos mínimos en las tablas padre
    IF v_total_medicos = 0 OR v_total_pacientes = 0 OR v_total_clinicas = 0 OR v_total_procedimientos = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Una o más tablas base (medico, paciente, clinica, procedimiento) están vacías.');
    END IF;

    -- 2. Bucle de generación de datos
    FOR i IN 1..100 LOOP
        v_consulta_id := v_consulta_id + 1;

        -- Selección rotativa de RUTs y IDs existentes mediante MOD
        v_medico_rut   := v_medicos_rut(MOD(i, v_total_medicos) + 1);
        v_paciente_rut := v_pacientes_rut(MOD(i, v_total_pacientes) + 1);
        v_clinica_id   := v_clinicas_id(MOD(i, v_total_clinicas) + 1);

        -- Asignación de estados
        IF MOD(i, 10) = 0 THEN
            v_estado := 'Cancelada';
        ELSIF MOD(i, 7) = 0 THEN
            v_estado := 'Pendiente';
        ELSE
            v_estado := 'Realizada';
        END IF;

        -- Fechas dinámicas
        v_fecha := DATE '2026-01-01' + MOD(i * 3, 220);

        -- Inserción de la Consulta
        INSERT INTO consulta (id, fecha, estado, medico_rut, paciente_rut, clinica_id)
        VALUES (v_consulta_id, v_fecha, v_estado, v_medico_rut, v_paciente_rut, v_clinica_id);

        -- Inserción de Detalles si la consulta no está cancelada
        IF v_estado != 'Cancelada' THEN
            -- Procedimiento 1
            v_procedimiento_id := v_procedimientos(MOD(i, v_total_procedimientos) + 1);
            
            SELECT costo_base INTO v_valor 
            FROM procedimiento 
            WHERE id = v_procedimiento_id;

            INSERT INTO detalle (cantidad, valor, procedimiento_id, consulta_id)
            VALUES (1, v_valor, v_procedimiento_id, v_consulta_id);

            -- Procedimiento 2 (Opcional en algunas consultas)
            IF MOD(i, 3) = 0 THEN
                v_procedimiento_id := v_procedimientos(MOD(i + 1, v_total_procedimientos) + 1);
                
                SELECT costo_base INTO v_valor 
                FROM procedimiento 
                WHERE id = v_procedimiento_id;

                INSERT INTO detalle (cantidad, valor, procedimiento_id, consulta_id)
                VALUES (1, v_valor, v_procedimiento_id, v_consulta_id);
            END IF;
        END IF;
    END LOOP;
    
    COMMIT;
END;
/


