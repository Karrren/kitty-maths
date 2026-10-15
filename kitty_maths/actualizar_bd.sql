-- Tablas nuevas: videos por subtema y retroalimentación del docente.
-- Si ya tenías la base creada con una versión anterior de database.sql,
-- ejecuta este archivo una vez sobre ella.

-- Videos de YouTube por subtema
CREATE TABLE IF NOT EXISTS videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subtema_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    youtube_id VARCHAR(20) NOT NULL,
    fecha DATETIME DEFAULT NOW(),
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE CASCADE
);

-- Calificación y retroalimentación del docente por estudiante y subtema
CREATE TABLE IF NOT EXISTS retroalimentacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    subtema_id INT NOT NULL,
    docente_id INT,
    nota DECIMAL(2,1),
    comentario TEXT,
    fecha DATETIME DEFAULT NOW(),
    UNIQUE KEY unica_retro (estudiante_id, subtema_id),
    FOREIGN KEY (estudiante_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE CASCADE,
    FOREIGN KEY (docente_id) REFERENCES usuarios(id) ON DELETE SET NULL
);
