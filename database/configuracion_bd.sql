-- SETUP BD.

DROP DATABASE IF EXISTS punto_del_dia;
CREATE DATABASE punto_del_dia
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE punto_del_dia;


-- 1. USUARIOS Y COMUNIDADES

CREATE TABLE usuarios (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL,
  apellidos     VARCHAR(120) NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,          -- hash (bcrypt), nunca la contraseña
  telefono      VARCHAR(20)  NULL,
  activo        BOOLEAN      NOT NULL DEFAULT TRUE,  -- baja lógica
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE comunidades (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(120) NOT NULL,
  direccion          VARCHAR(200) NOT NULL,
  ciudad             VARCHAR(80)  NOT NULL,
  codigo_postal      CHAR(5)      NOT NULL,
  codigo_invitacion  VARCHAR(12)  NOT NULL UNIQUE,   -- para que los vecinos se unan
  created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- Tabla intermedia N:M usuario <-> comunidad. El ROL vive aquí, no en usuarios,
-- porque una misma persona puede ser presidente en una comunidad y vecino en otra.
CREATE TABLE miembros_comunidad (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id    INT UNSIGNED NOT NULL,
  comunidad_id  INT UNSIGNED NOT NULL,
  rol           ENUM('administrador','presidente','vecino') NOT NULL DEFAULT 'vecino',
  vivienda      VARCHAR(30)  NULL,                   -- ej. "3ºB"
  fecha_alta    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_usuario_comunidad (usuario_id, comunidad_id),
  CONSTRAINT fk_miembro_usuario   FOREIGN KEY (usuario_id)   REFERENCES usuarios(id)    ON DELETE CASCADE,
  CONSTRAINT fk_miembro_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. INCIDENCIAS (con clasificación por IA)
-- ---------------------------------------------------------------------

CREATE TABLE categorias_incidencia (
  id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO categorias_incidencia (nombre) VALUES
  ('Fontanería'), ('Electricidad'), ('Ascensor'), ('Limpieza'),
  ('Zonas comunes'), ('Ruidos'), ('Otros');

CREATE TABLE incidencias (
  id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  comunidad_id        INT UNSIGNED NOT NULL,
  usuario_id          INT UNSIGNED NOT NULL,          -- quien la reporta
  titulo              VARCHAR(150) NOT NULL,
  descripcion         TEXT         NOT NULL,
  categoria_id        INT UNSIGNED NULL,              -- la rellena la IA (puede quedar NULL si falla)
  urgencia            ENUM('baja','media','alta') NULL,
  resumen_ia          TEXT         NULL,              -- resumen para el administrador
  clasificada_por_ia  BOOLEAN      NOT NULL DEFAULT FALSE,
  estado              ENUM('abierta','en_proceso','resuelta','cerrada') NOT NULL DEFAULT 'abierta',
  created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_inc_comunidad_estado (comunidad_id, estado),
  CONSTRAINT fk_inc_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE,
  CONSTRAINT fk_inc_usuario   FOREIGN KEY (usuario_id)   REFERENCES usuarios(id),
  CONSTRAINT fk_inc_categoria FOREIGN KEY (categoria_id) REFERENCES categorias_incidencia(id)
) ENGINE=InnoDB;

CREATE TABLE incidencia_imagenes (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  incidencia_id INT UNSIGNED NOT NULL,
  ruta          VARCHAR(255) NOT NULL,                -- ruta/URL del archivo, no el binario
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_img_incidencia FOREIGN KEY (incidencia_id) REFERENCES incidencias(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. RESERVAS DE ZONAS COMUNES
-- ---------------------------------------------------------------------

CREATE TABLE zonas_comunes (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  comunidad_id   INT UNSIGNED NOT NULL,
  nombre         VARCHAR(80)  NOT NULL,               -- pádel, piscina, barbacoa...
  descripcion    VARCHAR(255) NULL,
  hora_apertura  TIME NOT NULL DEFAULT '09:00:00',
  hora_cierre    TIME NOT NULL DEFAULT '22:00:00',
  activa         BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_zona_comunidad (comunidad_id, nombre),
  CONSTRAINT fk_zona_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reservas (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  zona_id     INT UNSIGNED NOT NULL,
  usuario_id  INT UNSIGNED NOT NULL,
  inicio      DATETIME NOT NULL,
  fin         DATETIME NOT NULL,
  estado      ENUM('confirmada','cancelada') NOT NULL DEFAULT 'confirmada',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_reserva_zona_tiempo (zona_id, inicio, fin),
  CONSTRAINT chk_reserva_horas CHECK (fin > inicio),
  CONSTRAINT fk_reserva_zona    FOREIGN KEY (zona_id)    REFERENCES zonas_comunes(id) ON DELETE CASCADE,
  CONSTRAINT fk_reserva_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- Comprobación de solapamiento (la hará el backend dentro de una transacción,
-- bloqueando la fila de la zona con SELECT ... FOR UPDATE):
--   SELECT COUNT(*) FROM reservas
--   WHERE zona_id = ? AND estado = 'confirmada'
--     AND inicio < :nuevo_fin AND fin > :nuevo_inicio;
-- Si devuelve 0 -> INSERT; si no -> rechazar la reserva.

-- ---------------------------------------------------------------------
-- 4. TABLÓN DE ANUNCIOS
-- ---------------------------------------------------------------------

CREATE TABLE anuncios (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  comunidad_id  INT UNSIGNED NOT NULL,
  autor_id      INT UNSIGNED NOT NULL,
  titulo        VARCHAR(150) NOT NULL,
  contenido     TEXT         NOT NULL,
  fijado        BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_anuncio_comunidad (comunidad_id, created_at),
  CONSTRAINT fk_anuncio_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE,
  CONSTRAINT fk_anuncio_autor     FOREIGN KEY (autor_id)     REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. VOTACIONES / ENCUESTAS
-- ---------------------------------------------------------------------

CREATE TABLE votaciones (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  comunidad_id  INT UNSIGNED NOT NULL,
  creador_id    INT UNSIGNED NOT NULL,
  titulo        VARCHAR(150) NOT NULL,
  descripcion   TEXT NULL,
  fecha_inicio  DATETIME NOT NULL,
  fecha_fin     DATETIME NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_votacion_fechas CHECK (fecha_fin > fecha_inicio),
  CONSTRAINT fk_votacion_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE,
  CONSTRAINT fk_votacion_creador   FOREIGN KEY (creador_id)   REFERENCES usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE opciones_votacion (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  votacion_id   INT UNSIGNED NOT NULL,
  texto         VARCHAR(150) NOT NULL,
  UNIQUE KEY uq_opcion_votacion (id, votacion_id),    -- necesario para la FK compuesta de votos
  CONSTRAINT fk_opcion_votacion FOREIGN KEY (votacion_id) REFERENCES votaciones(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE votos (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  votacion_id   INT UNSIGNED NOT NULL,
  opcion_id     INT UNSIGNED NOT NULL,
  usuario_id    INT UNSIGNED NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_un_voto_por_usuario (votacion_id, usuario_id),   -- 1 voto por persona
  -- La opción elegida debe pertenecer a ESA votación:
  CONSTRAINT fk_voto_opcion  FOREIGN KEY (opcion_id, votacion_id) REFERENCES opciones_votacion(id, votacion_id) ON DELETE CASCADE,
  CONSTRAINT fk_voto_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. REPOSITORIO DE DOCUMENTOS
-- ---------------------------------------------------------------------

CREATE TABLE documentos (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  comunidad_id     INT UNSIGNED NOT NULL,
  subido_por       INT UNSIGNED NOT NULL,
  titulo           VARCHAR(150) NOT NULL,
  tipo             ENUM('acta','presupuesto','otro') NOT NULL DEFAULT 'otro',
  nombre_original  VARCHAR(255) NOT NULL,
  ruta             VARCHAR(255) NOT NULL,             -- dónde está el PDF en el servidor
  tamano_bytes     INT UNSIGNED NULL,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_doc_comunidad_tipo (comunidad_id, tipo),
  CONSTRAINT fk_doc_comunidad FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE CASCADE,
  CONSTRAINT fk_doc_usuario   FOREIGN KEY (subido_por)   REFERENCES usuarios(id)
) ENGINE=InnoDB;