-- Estructura de base de datos: ubicacion_db
CREATE TABLE dbo.computadoras_ubicacion (
    id_maquina INT PRIMARY KEY,
    aula_laboratorio VARCHAR(100) NOT NULL,
    numero_banco INT,
    fecha_mantenimiento DATE,
    nombre_responsable VARCHAR(100)
);
