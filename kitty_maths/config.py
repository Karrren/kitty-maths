import os
import secrets
from dotenv import load_dotenv

# Lee los datos de conexión del archivo .env (no se sube a GitHub).
load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env'))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or secrets.token_hex(32)
    MYSQL_HOST = os.environ.get('MYSQL_HOST') or 'localhost'
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT') or 3306)
    MYSQL_USER = os.environ.get('MYSQL_USER') or 'root'
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD') or ''
    MYSQL_DB = os.environ.get('MYSQL_DB') or 'kitty_maths'
    # En la nube (TiDB Cloud) la conexión debe ir cifrada: MYSQL_SSL=true
    MYSQL_SSL = (os.environ.get('MYSQL_SSL') or '').lower() in ('1', 'true', 'si', 'sí')
    MYSQL_CURSORCLASS = 'DictCursor'


def parametros_mysql(con_base=True):
    """Datos para mysql.connector.connect(), comunes a la app y a los scripts."""
    params = dict(
        host=Config.MYSQL_HOST,
        port=Config.MYSQL_PORT,
        user=Config.MYSQL_USER,
        password=Config.MYSQL_PASSWORD,
        charset='utf8mb4',
    )
    if con_base:
        params['database'] = Config.MYSQL_DB
    if Config.MYSQL_SSL:
        import certifi
        params.update(ssl_ca=certifi.where(), ssl_verify_cert=True, ssl_verify_identity=True)
    return params
