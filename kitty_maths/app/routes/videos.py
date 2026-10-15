import re
from flask import Blueprint, session, redirect, url_for, request, flash
from app import get_db

videos_bp = Blueprint('videos', __name__)

def docente_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('auth.login'))
        if session.get('usuario_rol') != 'docente':
            return redirect(url_for('dashboard.index'))
        return f(*args, **kwargs)
    return decorated

def extraer_youtube_id(enlace):
    """Saca el código del video de enlaces como youtube.com/watch?v=..., youtu.be/..., /embed/... o /shorts/..."""
    m = re.search(r'(?:v=|youtu\.be/|embed/|shorts/|live/)([A-Za-z0-9_-]{11})', enlace)
    if m:
        return m.group(1)
    if re.fullmatch(r'[A-Za-z0-9_-]{11}', enlace):
        return enlace
    return None

@videos_bp.route('/subtemas/<int:subtema_id>/videos', methods=['POST'])
@docente_required
def agregar(subtema_id):
    titulo = request.form.get('titulo', '').strip()
    youtube_id = extraer_youtube_id(request.form.get('enlace', '').strip())

    if not titulo or not youtube_id:
        flash('Escribe un título y pega un enlace válido de YouTube.', 'danger')
        return redirect(url_for('temas.subtema', subtema_id=subtema_id))

    db = get_db()
    cur = db.cursor()
    cur.execute("INSERT INTO videos (subtema_id, titulo, youtube_id) VALUES (%s, %s, %s)",
                (subtema_id, titulo, youtube_id))
    db.commit()
    cur.close()
    flash('Video agregado.', 'success')
    return redirect(url_for('temas.subtema', subtema_id=subtema_id))

@videos_bp.route('/videos/<int:video_id>/eliminar', methods=['POST'])
@docente_required
def eliminar(video_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT subtema_id FROM videos WHERE id = %s", (video_id,))
    video = cur.fetchone()
    if not video:
        cur.close()
        return redirect(url_for('temas.lista'))

    cur.execute("DELETE FROM videos WHERE id = %s", (video_id,))
    db.commit()
    cur.close()
    flash('Video eliminado.', 'success')
    return redirect(url_for('temas.subtema', subtema_id=video['subtema_id']))
