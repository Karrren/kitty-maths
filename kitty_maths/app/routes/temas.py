from flask import Blueprint, render_template, session, redirect, url_for
from app import get_db

temas_bp = Blueprint('temas', __name__)

def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated

@temas_bp.route('/temas')
@login_required
def lista():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM temas ORDER BY orden")
    temas = cur.fetchall()
    cur.close()
    return render_template('temas/lista.html', temas=temas)

@temas_bp.route('/temas/<int:tema_id>')
@login_required
def detalle(tema_id):
    usuario_id = session['usuario_id']
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("SELECT * FROM temas WHERE id = %s", (tema_id,))
    tema = cur.fetchone()
    if not tema:
        return redirect(url_for('temas.lista'))

    cur.execute("SELECT * FROM subtemas WHERE tema_id = %s ORDER BY orden", (tema_id,))
    subtemas = cur.fetchall()

    cur.execute("""
        SELECT subtema_id, completado, total_intentos, total_aciertos, porcentaje
        FROM progreso_subtema WHERE usuario_id = %s
    """, (usuario_id,))
    progresos = {p['subtema_id']: p for p in cur.fetchall()}
    cur.close()

    return render_template('temas/detalle.html', tema=tema, subtemas=subtemas, progresos=progresos)

@temas_bp.route('/subtemas/<int:subtema_id>')
@login_required
def subtema(subtema_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT s.*, t.nombre as tema_nombre, t.id as tema_id, t.color as tema_color
        FROM subtemas s JOIN temas t ON t.id = s.tema_id
        WHERE s.id = %s
    """, (subtema_id,))
    subtema = cur.fetchone()
    if not subtema:
        return redirect(url_for('temas.lista'))

    cur.execute("SELECT COUNT(*) as total FROM ejercicios WHERE subtema_id = %s", (subtema_id,))
    total_ej = cur.fetchone()
    cur.close()

    return render_template('temas/subtema.html', subtema=subtema, total_ejercicios=total_ej['total'])
