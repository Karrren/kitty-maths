"""
Prepara la base de datos: la crea si no existe, carga database.sql la primera vez,
agrega las tablas nuevas (actualizar_bd.sql) y crea los usuarios de prueba.

Se puede ejecutar todas las veces que quieras: si los datos ya están, no los duplica.
Render lo ejecuta solo en cada despliegue (ver render.yaml).

Comando: python inicializar_bd.py
"""
import os
import re
import mysql.connector
from config import Config, parametros_mysql
from crear_usuarios import crear_usuarios_demo

AQUI = os.path.dirname(os.path.abspath(__file__))


def dividir_sql(texto):
    """Separa un archivo .sql en sentencias, sin cortar los ';' que van dentro de textos."""
    sentencias, actual, comilla, i = [], [], None, 0
    while i < len(texto):
        c = texto[i]
        if comilla:
            actual.append(c)
            if c == '\\' and i + 1 < len(texto):
                actual.append(texto[i + 1])
                i += 1
            elif c == comilla:
                comilla = None
        elif c in ("'", '"', '`'):
            comilla = c
            actual.append(c)
        elif texto.startswith('--', i):
            fin = texto.find('\n', i)
            i = len(texto) if fin == -1 else fin
            continue
        elif c == ';':
            sentencias.append(''.join(actual).strip())
            actual = []
        else:
            actual.append(c)
        i += 1
    sentencias.append(''.join(actual).strip())
    return [s for s in sentencias if s]


def ejecutar_archivo(cur, ruta):
    with open(ruta, encoding='utf-8') as f:
        for sentencia in dividir_sql(f.read()):
            # La base ya la elegimos nosotros con MYSQL_DB
            if re.match(r'(CREATE\s+DATABASE|USE)\s', sentencia, re.IGNORECASE):
                continue
            cur.execute(sentencia)


def main():
    conn = mysql.connector.connect(**parametros_mysql(con_base=False))
    cur = conn.cursor()
    cur.execute(f"CREATE DATABASE IF NOT EXISTS `{Config.MYSQL_DB}` "
                "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    cur.execute(f"USE `{Config.MYSQL_DB}`")

    cur.execute("SHOW TABLES LIKE 'temas'")
    hay_temas = cur.fetchone() is not None
    if hay_temas:
        cur.execute("SELECT COUNT(*) FROM temas")
        hay_temas = cur.fetchone()[0] > 0

    if hay_temas:
        print("La base ya tiene los temas; no se vuelve a cargar database.sql.")
    else:
        print("Cargando database.sql (tablas, temas, subtemas y ejercicios)...")
        ruta = os.path.join(AQUI, 'database.sql')
        if not os.path.exists(ruta):
            ruta = os.path.join(AQUI, '..', 'database.sql')
        ejecutar_archivo(cur, ruta)

    print("Revisando tablas nuevas (actualizar_bd.sql)...")
    ejecutar_archivo(cur, os.path.join(AQUI, 'actualizar_bd.sql'))

    print("Usuarios de prueba:")
    crear_usuarios_demo(cur)

    conn.commit()
    cur.close()
    conn.close()
    print("Base de datos lista.")


if __name__ == '__main__':
    main()
