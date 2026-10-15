from flask import Blueprint, render_template, session, redirect, url_for, request, flash
from werkzeug.security import generate_password_hash
from app import get_db

docente_bp = Blueprint('docente', __name__)

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

@docente_bp.route('/docente')
@docente_required
def panel():
    db = get_db()
    cur = db.cursor(dictionary=True)

    # Todos los estudiantes
    cur.execute("""
        SELECT u.id, u.nombre, u.email, u.fecha_registro,
               COUNT(DISTINCT i.id) as total_intentos,
               COALESCE(SUM(i.correcto), 0) as total_correctos,
               COUNT(DISTINCT CASE WHEN ps.completado = 1 THEN ps.subtema_id END) as subtemas_completados
        FROM usuarios u
        LEFT JOIN intentos i ON i.usuario_id = u.id
        LEFT JOIN progreso_subtema ps ON ps.usuario_id = u.id
        WHERE u.rol = 'estudiante'
        GROUP BY u.id, u.nombre, u.email, u.fecha_registro
        ORDER BY u.nombre
    """)
    estudiantes = cur.fetchall()

    # Total de subtemas en el sistema
    cur.execute("SELECT COUNT(*) as total FROM subtemas")
    total_subtemas = cur.fetchone()['total']

    # Estadísticas generales
    cur.execute("SELECT COUNT(*) as total FROM usuarios WHERE rol = 'estudiante'")
    total_estudiantes = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) as total FROM intentos")
    total_intentos = cur.fetchone()['total']

    cur.execute("""
        SELECT COUNT(*) as total FROM progreso_subtema WHERE completado = 1
    """)
    total_completados = cur.fetchone()['total']

    # Rendimiento por tema (todos los estudiantes)
    cur.execute("""
        SELECT t.nombre as tema, t.color,
               COUNT(i.id) as intentos,
               COALESCE(SUM(i.correcto), 0) as aciertos
        FROM temas t
        LEFT JOIN subtemas s ON s.tema_id = t.id
        LEFT JOIN ejercicios e ON e.subtema_id = s.id
        LEFT JOIN intentos i ON i.ejercicio_id = e.id
        GROUP BY t.id, t.nombre, t.color
        ORDER BY t.orden
    """)
    por_tema = cur.fetchall()

    cur.close()

    # Calcular porcentaje global por estudiante
    for est in estudiantes:
        est['porcentaje'] = round(
            (est['total_correctos'] / est['total_intentos'] * 100), 1
        ) if est['total_intentos'] > 0 else 0

    return render_template('docente/panel.html',
                           estudiantes=estudiantes,
                           total_estudiantes=total_estudiantes,
                           total_subtemas=total_subtemas,
                           total_intentos=total_intentos,
                           total_completados=total_completados,
                           por_tema=por_tema)

@docente_bp.route('/docente/estudiante/<int:estudiante_id>')
@docente_required
def detalle_estudiante(estudiante_id):
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("SELECT id, nombre, email, fecha_registro FROM usuarios WHERE id = %s AND rol = 'estudiante'", (estudiante_id,))
    estudiante = cur.fetchone()
    if not estudiante:
        return redirect(url_for('docente.panel'))

    cur.execute("""
        SELECT t.nombre as tema, t.color,
               s.nombre as subtema, s.id as subtema_id,
               ps.completado, ps.total_intentos, ps.total_aciertos,
               ps.porcentaje, ps.fecha_completado
        FROM temas t
        JOIN subtemas s ON s.tema_id = t.id
        LEFT JOIN progreso_subtema ps ON ps.subtema_id = s.id AND ps.usuario_id = %s
        ORDER BY t.orden, s.orden
    """, (estudiante_id,))
    progreso = cur.fetchall()

    cur.execute("SELECT subtema_id, nota, comentario, fecha FROM retroalimentacion WHERE estudiante_id = %s",
                (estudiante_id,))
    retros = {r['subtema_id']: r for r in cur.fetchall()}

    cur.execute("""
        SELECT COUNT(*) as total, COALESCE(SUM(correcto), 0) as correctos
        FROM intentos WHERE usuario_id = %s
    """, (estudiante_id,))
    resumen = cur.fetchone()

    cur.close()

    total = resumen['total'] or 0
    correctos = int(resumen['correctos'] or 0)
    porcentaje_global = round((correctos / total * 100), 1) if total > 0 else 0

    return render_template('docente/detalle_estudiante.html',
                           estudiante=estudiante,
                           progreso=progreso,
                           retros=retros,
                           total=total,
                           correctos=correctos,
                           porcentaje_global=porcentaje_global)


@docente_bp.route('/docente/estudiante/<int:estudiante_id>/subtema/<int:subtema_id>/retro', methods=['POST'])
@docente_required
def guardar_retro(estudiante_id, subtema_id):
    nota_txt = request.form.get('nota', '').strip().replace(',', '.')
    comentario = request.form.get('comentario', '').strip()

    nota = None
    if nota_txt:
        try:
            nota = round(float(nota_txt), 1)
        except ValueError:
            nota = -1
        if not 0 <= nota <= 5:
            flash('La nota debe ser un número entre 0.0 y 5.0.', 'danger')
            return redirect(url_for('docente.detalle_estudiante', estudiante_id=estudiante_id))

    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT id FROM usuarios WHERE id = %s AND rol = 'estudiante'", (estudiante_id,))
    if not cur.fetchone():
        cur.close()
        return redirect(url_for('docente.panel'))

    if nota is None and not comentario:
        cur.execute("DELETE FROM retroalimentacion WHERE estudiante_id = %s AND subtema_id = %s",
                    (estudiante_id, subtema_id))
    else:
        cur.execute("""
            INSERT INTO retroalimentacion (estudiante_id, subtema_id, docente_id, nota, comentario)
            VALUES (%s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                docente_id = VALUES(docente_id), nota = VALUES(nota),
                comentario = VALUES(comentario), fecha = NOW()
        """, (estudiante_id, subtema_id, session['usuario_id'], nota, comentario or None))
    db.commit()
    cur.close()
    flash('Calificación y retroalimentación guardadas.', 'success')
    return redirect(url_for('docente.detalle_estudiante', estudiante_id=estudiante_id))


@docente_bp.route('/docente/usuario/<int:usuario_id>/password', methods=['POST'])
@docente_required
def restablecer_password(usuario_id):
    password = request.form.get('password', '')
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT id, nombre, rol FROM usuarios WHERE id = %s", (usuario_id,))
    usuario = cur.fetchone()
    if not usuario:
        cur.close()
        return redirect(url_for('docente.panel'))

    if usuario['rol'] == 'docente':
        destino = url_for('docente.docentes')
    else:
        destino = url_for('docente.detalle_estudiante', estudiante_id=usuario_id)

    if len(password) < 6:
        flash('La contraseña nueva debe tener mínimo 6 caracteres.', 'danger')
    else:
        cur.execute("UPDATE usuarios SET password_hash = %s WHERE id = %s",
                    (generate_password_hash(password), usuario_id))
        db.commit()
        flash(f'Contraseña de {usuario["nombre"]} restablecida.', 'success')
    cur.close()
    return redirect(destino)


@docente_bp.route('/docente/docentes', methods=['GET', 'POST'])
@docente_required
def docentes():
    db = get_db()
    cur = db.cursor(dictionary=True)

    if request.method == 'POST':
        nombre = request.form.get('nombre', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')

        cur.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
        existe = cur.fetchone()
        if not nombre or not email or len(password) < 6:
            flash('Escribe nombre, correo y una contraseña de mínimo 6 caracteres.', 'danger')
        elif existe:
            flash('Este correo ya está registrado.', 'warning')
        else:
            cur.execute(
                "INSERT INTO usuarios (nombre, email, password_hash, rol) VALUES (%s, %s, %s, 'docente')",
                (nombre, email, generate_password_hash(password))
            )
            db.commit()
            flash(f'Docente {nombre} creado.', 'success')
        cur.close()
        return redirect(url_for('docente.docentes'))

    cur.execute("SELECT id, nombre, email, fecha_registro FROM usuarios WHERE rol = 'docente' ORDER BY nombre")
    lista = cur.fetchall()
    cur.close()
    return render_template('docente/docentes.html', docentes=lista)
