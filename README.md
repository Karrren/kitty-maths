# KittyMaths

Página web para la retroalimentación de temas estadísticos — IET San Luis, Garagoa (Boyacá), 2026.

Hecha con Flask (Python) y MySQL.

---

## Publicarla gratis en PythonAnywhere

[PythonAnywhere](https://www.pythonanywhere.com) tiene un plan gratuito que incluye Python y MySQL, y no pide tarjeta.
La página queda en un enlace como `https://TU_USUARIO.pythonanywhere.com`.

> En el plan gratuito tienes que entrar a la web una vez cada 3 meses y pulsar
> **"Run until 3 months from today"** (pestaña *Web*); si no, la página se apaga.

### 1. Crear la cuenta

Regístrate en <https://www.pythonanywhere.com/pricing/> con el plan **Beginner (gratis)**.
En todo lo que sigue, cambia `TU_USUARIO` por el nombre de usuario que elijas.

### 2. Crear la base de datos

1. Ve a la pestaña **Databases**.
2. Escribe una contraseña para MySQL y pulsa **Initialize MySQL**. Guárdala; es `TU_CLAVE_MYSQL`.
3. En *Create a database* escribe `kitty_maths` y pulsa **Create**. Queda como `TU_USUARIO$kitty_maths`.

### 3. Descargar el proyecto

En la pestaña **Consoles** abre una consola **Bash** y ejecuta:

```bash
git clone https://github.com/Karrren/kitty-maths.git
cd kitty-maths
python3.13 -m venv venv
source venv/bin/activate
pip install -r kitty_maths/requirements.txt
```

### 4. Cargar las tablas y los usuarios de prueba

En la misma consola (te pedirá `TU_CLAVE_MYSQL`):

```bash
sed '/^CREATE DATABASE/d;/^USE /d' database.sql | mysql -u TU_USUARIO -h TU_USUARIO.mysql.pythonanywhere-services.com -p 'TU_USUARIO$kitty_maths'
```

Después crea los usuarios de prueba:

```bash
cd kitty_maths
MYSQL_HOST=TU_USUARIO.mysql.pythonanywhere-services.com MYSQL_USER=TU_USUARIO MYSQL_PASSWORD='TU_CLAVE_MYSQL' MYSQL_DB='TU_USUARIO$kitty_maths' python crear_usuarios.py
```

### 5. Crear la web app

1. Pestaña **Web** → **Add a new web app** → **Next**.
2. Elige **Manual configuration** (no "Flask") → **Python 3.13** → **Next**.
3. En la sección **Virtualenv** escribe: `/home/TU_USUARIO/kitty-maths/venv`
4. En **Static files** agrega: URL `/static/` → Directory `/home/TU_USUARIO/kitty-maths/kitty_maths/app/static`
5. Abre el enlace **WSGI configuration file**, borra todo su contenido y pega el de
   [`kitty_maths/wsgi_pythonanywhere.py`](kitty_maths/wsgi_pythonanywhere.py), cambiando
   `TU_USUARIO`, `TU_CLAVE_MYSQL` y la `SECRET_KEY`. Guarda.
6. Vuelve a la pestaña **Web** y pulsa el botón verde **Reload**.

Listo: la página queda en `https://TU_USUARIO.pythonanywhere.com`.

### Si ya habías creado la base con una versión anterior

Las tablas de videos y retroalimentación son nuevas. Créalas una sola vez con:

```bash
mysql -u TU_USUARIO -h TU_USUARIO.mysql.pythonanywhere-services.com -p 'TU_USUARIO$kitty_maths' < kitty_maths/actualizar_bd.sql
```

### Actualizar la página después de hacer cambios

Sube los cambios a GitHub y luego, en una consola Bash de PythonAnywhere:

```bash
cd ~/kitty-maths
git pull
```

y pulsa **Reload** en la pestaña **Web**.

Si algo falla, el **Error log** (pestaña *Web*) dice qué pasó.

---

## Correrla en tu computador

1. Crea la base con `database.sql` en tu MySQL local.
2. Copia `kitty_maths/.env.example` como `kitty_maths/.env` y pon tu contraseña de MySQL.
3. Instala las dependencias y crea los usuarios de prueba:

   ```bash
   python -m venv venv
   venv\Scripts\activate
   pip install -r kitty_maths/requirements.txt
   cd kitty_maths
   python crear_usuarios.py
   python run.py
   ```

4. Abre <http://localhost:5000>.

La conexión a MySQL se configura en `kitty_maths/.env` (no se sube a GitHub) o con las variables de entorno
`MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DB` y `SECRET_KEY`.

Usuarios de prueba: `estudiante@kittymaths.com` y `docente@kittymaths.com`, contraseña `kitty123`.
