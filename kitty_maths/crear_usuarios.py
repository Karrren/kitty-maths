"""
Ejecuta este script UNA SOLA VEZ despues de importar database.sql
para crear los usuarios de prueba.

Comando: python crear_usuarios.py
"""
from werkzeug.security import generate_password_hash
import mysql.connector
from config import Config

conn = mysql.connector.connect(
    host=Config.MYSQL_HOST,
    user=Config.MYSQL_USER,
    password=Config.MYSQL_PASSWORD,
    database=Config.MYSQL_DB,
    charset='utf8mb4'
)
cur = conn.cursor()

usuarios = [
    ('Estudiante Demo',  'estudiante@kittymaths.com', generate_password_hash('kitty123'), 'estudiante'),
    ('Docente Demo',     'docente@kittymaths.com',    generate_password_hash('kitty123'), 'docente'),
]

for nombre, email, pw_hash, rol in usuarios:
    cur.execute("""
        INSERT INTO usuarios (nombre, email, password_hash, rol)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE nombre = nombre
    """, (nombre, email, pw_hash, rol))
    print(f"  ✓ {rol}: {email}")

conn.commit()
cur.close()
conn.close()
print("\nUsuarios creados. Contraseña de ambos: kitty123")
