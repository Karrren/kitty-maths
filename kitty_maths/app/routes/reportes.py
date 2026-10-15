from flask import Blueprint, render_template, session, redirect, url_for
from app import get_db

reportes_bp = Blueprint('reportes', __name__)

def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated

@reportes_bp.route('/reportes')
@login_required
def index():
    usuario_id = session['usuario_id']
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("""
        SELECT t.nombre as tema, s.nombre as subtema, s.id as subtema_id,
               ps.completado, ps.total_intentos, ps.total_aciertos,
               ps.porcentaje, ps.fecha_inicio, ps.fecha_completado
        FROM temas t
        JOIN subtemas s ON s.tema_id = t.id
        LEFT JOIN progreso_subtema ps ON ps.subtema_id = s.id AND ps.usuario_id = %s
        ORDER BY t.orden, s.orden
    """, (usuario_id,))
    progreso = cur.fetchall()

    cur.execute("""
        SELECT COUNT(*) as total, SUM(correcto) as correctos
        FROM intentos WHERE usuario_id = %s
    """, (usuario_id,))
    resumen = cur.fetchone()

    cur.execute("""
        SELECT t.nombre as tema, COUNT(i.id) as intentos, SUM(i.correcto) as aciertos
        FROM intentos i
        JOIN ejercicios e ON e.id = i.ejercicio_id
        JOIN subtemas s ON s.id = e.subtema_id
        JOIN temas t ON t.id = s.tema_id
        WHERE i.usuario_id = %s
        GROUP BY t.id, t.nombre
        ORDER BY t.orden
    """, (usuario_id,))
    por_tema = cur.fetchall()

    cur.execute("""
        SELECT r.nota, r.comentario, r.fecha, s.id as subtema_id, s.nombre as subtema,
               t.nombre as tema, d.nombre as docente
        FROM retroalimentacion r
        JOIN subtemas s ON s.id = r.subtema_id
        JOIN temas t ON t.id = s.tema_id
        LEFT JOIN usuarios d ON d.id = r.docente_id
        WHERE r.estudiante_id = %s
        ORDER BY r.fecha DESC
    """, (usuario_id,))
    retros = cur.fetchall()
    cur.close()

    total = resumen['total'] or 0
    correctos = int(resumen['correctos'] or 0)
    porcentaje_global = round((correctos / total * 100), 1) if total > 0 else 0

    return render_template('reportes/index.html',
                           progreso=progreso,
                           total=total,
                           correctos=correctos,
                           porcentaje_global=porcentaje_global,
                           por_tema=por_tema,
                           retros=retros)
