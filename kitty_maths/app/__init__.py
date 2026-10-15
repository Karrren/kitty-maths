from flask import Flask
import mysql.connector
from config import Config

def get_db():
    from flask import g
    if 'db' not in g:
        g.db = mysql.connector.connect(
            host=Config.MYSQL_HOST,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DB,
            charset='utf8mb4'
        )
    return g.db

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    @app.teardown_appcontext
    def close_db(e=None):
        from flask import g
        db = g.pop('db', None)
        if db is not None:
            db.close()

    from app.routes.auth import auth_bp
    from app.routes.dashboard import dashboard_bp
    from app.routes.temas import temas_bp
    from app.routes.ejercicios import ejercicios_bp
    from app.routes.reportes import reportes_bp
    from app.routes.docente import docente_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(temas_bp)
    app.register_blueprint(ejercicios_bp)
    app.register_blueprint(reportes_bp)
    app.register_blueprint(docente_bp)

    return app
