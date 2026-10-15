"""
Crea los usuarios de prueba (estudiante y docente, contraseña kitty123).
Si ya existen no los toca, así que no cambia una contraseña que ya hayas cambiado.

Comando: python crear_usuarios.py
"""
from werkzeug.security import generate_password_hash
import mysql.connector
from config import parametros_mysql

USUARIOS_DEMO = [
    ('Estudiante Demo', 'estudiante@kittymaths.com', 'estudiante'),
    ('Docente Demo',    'docente@kittymaths.com',    'docente'),
]


def crear_usuarios_demo(cur):
    for nombre, email, rol in USUARIOS_DEMO:
        cur.execute("""
            INSERT INTO usuarios (nombre, email, password_hash, rol)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE nombre = nombre
        """, (nombre, email, generate_password_hash('kitty123'), rol))
        print(f"  - {rol}: {email}")


if __name__ == '__main__':
    conn = mysql.connector.connect(**parametros_mysql())
    cur = conn.cursor()
    crear_usuarios_demo(cur)
    conn.commit()
    cur.close()
    conn.close()
    print("\nUsuarios listos. Contraseña de ambos: kitty123")
