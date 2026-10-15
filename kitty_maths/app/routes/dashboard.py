from flask import Blueprint, render_template, session, redirect, url_for
from app import get_db

dashboard_bp = Blueprint('dashboard', __name__)

def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated

@dashboard_bp.route('/dashboard')
@login_required
def index():
    db = get_db()
    cur = db.cursor(dictionary=True)
    usuario_id = session['usuario_id']

    cur.execute("SELECT * FROM temas ORDER BY orden")
    temas = cur.fetchall()

    cur.execute("""
        SELECT t.id as tema_id, COUNT(s.id) as total_subtemas,
               COALESCE(SUM(CASE WHEN ps.completado = 1 THEN 1 ELSE 0 END), 0) as completados
        FROM temas t
        LEFT JOIN subtemas s ON s.tema_id = t.id
        LEFT JOIN progreso_subtema ps ON ps.subtema_id = s.id AND ps.usuario_id = %s
        GROUP BY t.id
    """, (usuario_id,))
    progresos_raw = cur.fetchall()
    progresos = {p['tema_id']: p for p in progresos_raw}

    cur.execute("SELECT COUNT(*) as total FROM intentos WHERE usuario_id = %s", (usuario_id,))
    stats = cur.fetchone()

    cur.execute("SELECT COUNT(*) as correctos FROM intentos WHERE usuario_id = %s AND correcto = 1", (usuario_id,))
    correctos = cur.fetchone()

    cur.execute("SELECT COUNT(*) as subtemas_completados FROM progreso_subtema WHERE usuario_id = %s AND completado = 1", (usuario_id,))
    completados = cur.fetchone()
    cur.close()

    total_intentos = stats['total'] if stats else 0
    total_correctos = correctos['correctos'] if correctos else 0
    porcentaje_global = round((total_correctos / total_intentos * 100), 1) if total_intentos > 0 else 0

    return render_template('dashboard/index.html',
                           temas=temas,
                           progresos=progresos,
                           total_intentos=total_intentos,
                           total_correctos=total_correctos,
                           porcentaje_global=porcentaje_global,
                           subtemas_completados=completados['subtemas_completados'] if completados else 0)
