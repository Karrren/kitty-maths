# Plantilla del archivo WSGI para PythonAnywhere.
# Copia este contenido en el archivo WSGI de tu web app
# (pestaña "Web" -> "WSGI configuration file") y cambia TU_USUARIO
# y TU_CLAVE_MYSQL por tus datos.
import os
import sys

proyecto = '/home/TU_USUARIO/kitty-maths/kitty_maths'
if proyecto not in sys.path:
    sys.path.insert(0, proyecto)

os.environ['MYSQL_HOST'] = 'TU_USUARIO.mysql.pythonanywhere-services.com'
os.environ['MYSQL_USER'] = 'TU_USUARIO'
os.environ['MYSQL_PASSWORD'] = 'TU_CLAVE_MYSQL'
os.environ['MYSQL_DB'] = 'TU_USUARIO$kitty_maths'
os.environ['SECRET_KEY'] = 'cambia-esto-por-un-texto-largo-y-secreto'

from app import create_app
application = create_app()
