# KittyMaths

Página web para la retroalimentación de temas estadísticos — IET San Luis, Garagoa (Boyacá), 2026.

Hecha con Flask (Python) y MySQL.

---

## Publicarla gratis (Render + TiDB Cloud)

- **[Render](https://render.com)** pone la página en internet. Es gratis y no pide tarjeta.
- **[TiDB Cloud](https://tidbcloud.com)** guarda la base de datos. Es compatible con MySQL, gratis y no pide tarjeta.

La página queda en un enlace como `https://kitty-maths.onrender.com`.

> En el plan gratis de Render la página "se duerme" si nadie entra durante 15 minutos.
> La primera visita después tarda cerca de un minuto en cargar; las siguientes van rápido.

### 1. Crear la base de datos en TiDB Cloud

1. Regístrate en <https://tidbcloud.com> (puedes entrar con tu cuenta de Google o GitHub).
2. Crea un clúster del plan **Starter** (gratis). Si te deja elegir región, escoge una de Estados Unidos,
   por ejemplo **Oregon (us-west-2)**, que queda cerca de Render.
3. Cuando esté listo, pulsa **Connect**. Ahí verás estos datos; cópialos en un lugar seguro:
   - **HOST** (algo como `gateway01.us-west-2.prod.aws.tidbcloud.com`)
   - **PORT** (normalmente `4000`)
   - **USERNAME** (algo como `2abcDEF123.root`)
   - **PASSWORD**: pulsa **Generate Password** y guárdala; no la vuelven a mostrar.

No tienes que cargar nada a mano: Render crea la base `kitty_maths`, las tablas, los temas
y los usuarios de prueba automáticamente la primera vez.

### 2. Publicar la página en Render

1. Regístrate en <https://render.com> con **tu cuenta de GitHub** (así Render puede ver el repositorio).
2. Pulsa **New** → **Blueprint**.
3. Elige el repositorio **kitty-maths**. Render lee el archivo `render.yaml` del proyecto.
4. Te pedirá tres datos de TiDB. Pégalos:
   - `MYSQL_HOST` → el HOST
   - `MYSQL_USER` → el USERNAME
   - `MYSQL_PASSWORD` → la PASSWORD
5. Pulsa **Apply** (o **Deploy Blueprint**) y espera unos minutos.
   En los registros (**Logs**) debe aparecer `Base de datos lista.` y luego `Your service is live`.
6. Arriba a la izquierda aparece el enlace de tu página. ¡Ese es el que compartes!

### 3. Muy importante: cambia la contraseña del docente

La pantalla de inicio muestra los usuarios de prueba con la contraseña `kitty123`.
Entra como `docente@kittymaths.com`, ve a **Panel docente → Docentes** y cámbiale la contraseña.
Así nadie más puede entrar como docente. (Volver a desplegar no la regresa a `kitty123`.)

### Actualizar la página después de hacer cambios

Sube los cambios a GitHub (`git push`). Render los detecta y vuelve a publicar la página solo.

### Si algo falla

- En Render abre tu servicio → **Logs** y mira las últimas líneas en rojo.
- `Access denied`: revisa `MYSQL_USER` y `MYSQL_PASSWORD` en **Environment** (sin espacios al inicio o al final).
- `Can't connect` o `timed out`: revisa `MYSQL_HOST`, y en TiDB que el clúster tenga el
  **Public Endpoint** activo y que permita conexiones desde cualquier IP.

---

## Correrla en tu computador

1. Copia `kitty_maths/.env.example` como `kitty_maths/.env` y pon tu contraseña de MySQL.
2. Instala las dependencias, prepara la base (tablas, temas y usuarios de prueba) y arranca la app:

   ```bash
   python -m venv venv
   venv\Scripts\activate
   pip install -r kitty_maths/requirements.txt
   cd kitty_maths
   python inicializar_bd.py
   python run.py
   ```

3. Abre <http://localhost:5000>.

La conexión a MySQL se configura en `kitty_maths/.env` (no se sube a GitHub) o con las variables de entorno
`MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DB`, `MYSQL_SSL` y `SECRET_KEY`.

Usuarios de prueba: `estudiante@kittymaths.com` y `docente@kittymaths.com`, contraseña `kitty123`.
