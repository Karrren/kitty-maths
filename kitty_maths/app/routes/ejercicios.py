from flask import Blueprint, render_template, session, redirect, url_for, request, jsonify
from app import get_db
from datetime import datetime

ejercicios_bp = Blueprint('ejercicios', __name__)


def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated


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


@ejercicios_bp.route('/subtemas/<int:subtema_id>/ejercicios')
@login_required
def lista(subtema_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT s.*, t.nombre as tema_nombre, t.id as tema_id, t.color as tema_color
        FROM subtemas s JOIN temas t ON t.id = s.tema_id WHERE s.id = %s
    """, (subtema_id,))
    subtema = cur.fetchone()
    cur.execute("SELECT * FROM ejercicios WHERE subtema_id = %s ORDER BY dificultad, id", (subtema_id,))
    ejercicios = cur.fetchall()
    cur.close()
    return render_template('ejercicios/lista.html', subtema=subtema, ejercicios=ejercicios)


@ejercicios_bp.route('/subtemas/<int:subtema_id>/quiz')
@login_required
def quiz(subtema_id):
    # El docente no resuelve el quiz: lo mandamos a gestionar los ejercicios de este subtema
    if session.get('usuario_rol') == 'docente':
        return redirect(url_for('ejercicios.lista', subtema_id=subtema_id))

    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT s.*, t.nombre as tema_nombre, t.id as tema_id, t.color as tema_color
        FROM subtemas s JOIN temas t ON t.id = s.tema_id WHERE s.id = %s
    """, (subtema_id,))
    subtema = cur.fetchone()
    cur.execute("SELECT * FROM ejercicios WHERE subtema_id = %s ORDER BY id", (subtema_id,))
    ejercicios = cur.fetchall()
    cur.close()
    return render_template('ejercicios/quiz.html', subtema=subtema, ejercicios=ejercicios)


@ejercicios_bp.route('/subtemas/<int:subtema_id>/quiz/enviar', methods=['POST'])
@login_required
def enviar_quiz(subtema_id):
    # Igual protegemos el endpoint que recibe las respuestas: un docente no debe generar intentos/progreso
    if session.get('usuario_rol') == 'docente':
        return jsonify({'error': 'No autorizado'}), 403

    usuario_id = session['usuario_id']
    data = request.get_json()
    respuestas = data.get('respuestas', {})

    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM ejercicios WHERE subtema_id = %s", (subtema_id,))
    ejercicios = cur.fetchall()

    aciertos = 0
    resultados = []
    for ej in ejercicios:
        eid = str(ej['id'])
        respuesta = respuestas.get(eid, '')
        correcto = respuesta.upper() == ej['respuesta_correcta'].upper()
        if correcto:
            aciertos += 1
        cur.execute(
            "INSERT INTO intentos (usuario_id, ejercicio_id, respuesta, correcto) VALUES (%s, %s, %s, %s)",
            (usuario_id, ej['id'], respuesta, correcto)
        )
        resultados.append({
            'id': ej['id'],
            'pregunta': ej['pregunta'],
            'respuesta_usuario': respuesta,
            'respuesta_correcta': ej['respuesta_correcta'],
            'correcto': correcto,
            'explicacion': ej['explicacion'],
            'opcion_a': ej['opcion_a'],
            'opcion_b': ej['opcion_b'],
            'opcion_c': ej['opcion_c'],
            'opcion_d': ej['opcion_d'],
        })

    total = len(ejercicios)
    porcentaje = round((aciertos / total * 100), 1) if total > 0 else 0
    completado = porcentaje >= 60
    ahora = datetime.now()

    cur.execute("""
        INSERT INTO progreso_subtema (usuario_id, subtema_id, completado, total_intentos, total_aciertos, porcentaje, fecha_completado)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            total_intentos = total_intentos + %s,
            total_aciertos = total_aciertos + %s,
            porcentaje = %s,
            completado = IF(%s = 1, 1, completado),
            fecha_completado = IF(%s = 1, %s, fecha_completado)
    """, (
        usuario_id, subtema_id, completado, total, aciertos, porcentaje,
        ahora if completado else None,
        total, aciertos, porcentaje,
        1 if completado else 0,
        1 if completado else 0, ahora
    ))
    db.commit()
    cur.close()

    return jsonify({
        'aciertos': aciertos,
        'total': total,
        'porcentaje': porcentaje,
        'completado': completado,
        'resultados': resultados
    })


# ============================================
#  GESTIÓN DE EJERCICIOS (solo docente)
# ============================================

@ejercicios_bp.route('/subtemas/<int:subtema_id>/ejercicios/crear', methods=['GET', 'POST'])
@docente_required
def crear(subtema_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT s.*, t.nombre as tema_nombre, t.id as tema_id
        FROM subtemas s JOIN temas t ON t.id = s.tema_id WHERE s.id = %s
    """, (subtema_id,))
    subtema = cur.fetchone()
    if not subtema:
        cur.close()
        return redirect(url_for('temas.lista'))

    if request.method == 'POST':
        pregunta = request.form.get('pregunta', '').strip()
        opcion_a = request.form.get('opcion_a', '').strip()
        opcion_b = request.form.get('opcion_b', '').strip()
        opcion_c = request.form.get('opcion_c', '').strip()
        opcion_d = request.form.get('opcion_d', '').strip()
        respuesta_correcta = request.form.get('respuesta_correcta', '').strip().upper()
        explicacion = request.form.get('explicacion', '').strip()
        dificultad = request.form.get('dificultad', 'facil')

        opciones_validas = {'A': opcion_a, 'B': opcion_b, 'C': opcion_c, 'D': opcion_d}
        if not pregunta or not opcion_a or not opcion_b or respuesta_correcta not in ('A', 'B', 'C', 'D') \
                or not opciones_validas.get(respuesta_correcta):
            cur.close()
            return render_template('ejercicios/crear.html', subtema=subtema,
                                    error="Revisa la pregunta, al menos las opciones A y B, "
                                          "y que la respuesta correcta tenga texto.")

        cur.execute("""
            INSERT INTO ejercicios (subtema_id, pregunta, opcion_a, opcion_b, opcion_c, opcion_d,
                                     respuesta_correcta, explicacion, dificultad)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (subtema_id, pregunta, opcion_a, opcion_b, opcion_c or None, opcion_d or None,
              respuesta_correcta, explicacion, dificultad))
        db.commit()
        cur.close()
        return redirect(url_for('ejercicios.lista', subtema_id=subtema_id))

    cur.close()
    return render_template('ejercicios/crear.html', subtema=subtema)


@ejercicios_bp.route('/ejercicios/<int:ejercicio_id>/editar', methods=['GET', 'POST'])
@docente_required
def editar(ejercicio_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT e.*, s.nombre as subtema_nombre, s.id as subtema_id,
               t.nombre as tema_nombre, t.id as tema_id
        FROM ejercicios e
        JOIN subtemas s ON s.id = e.subtema_id
        JOIN temas t ON t.id = s.tema_id
        WHERE e.id = %s
    """, (ejercicio_id,))
    ejercicio = cur.fetchone()
    if not ejercicio:
        cur.close()
        return redirect(url_for('temas.lista'))

    if request.method == 'POST':
        pregunta = request.form.get('pregunta', '').strip()
        opcion_a = request.form.get('opcion_a', '').strip()
        opcion_b = request.form.get('opcion_b', '').strip()
        opcion_c = request.form.get('opcion_c', '').strip()
        opcion_d = request.form.get('opcion_d', '').strip()
        respuesta_correcta = request.form.get('respuesta_correcta', '').strip().upper()
        explicacion = request.form.get('explicacion', '').strip()
        dificultad = request.form.get('dificultad', 'facil')

        opciones_validas = {'A': opcion_a, 'B': opcion_b, 'C': opcion_c, 'D': opcion_d}
        if not pregunta or not opcion_a or not opcion_b or respuesta_correcta not in ('A', 'B', 'C', 'D') \
                or not opciones_validas.get(respuesta_correcta):
            cur.close()
            return render_template('ejercicios/editar.html', ejercicio=ejercicio,
                                    error="Revisa la pregunta, al menos las opciones A y B, "
                                          "y que la respuesta correcta tenga texto.")

        cur.execute("""
            UPDATE ejercicios
            SET pregunta=%s, opcion_a=%s, opcion_b=%s, opcion_c=%s, opcion_d=%s,
                respuesta_correcta=%s, explicacion=%s, dificultad=%s
            WHERE id=%s
        """, (pregunta, opcion_a, opcion_b, opcion_c or None, opcion_d or None,
              respuesta_correcta, explicacion, dificultad, ejercicio_id))
        db.commit()
        cur.close()
        return redirect(url_for('ejercicios.lista', subtema_id=ejercicio['subtema_id']))

    cur.close()
    return render_template('ejercicios/editar.html', ejercicio=ejercicio)


@ejercicios_bp.route('/ejercicios/<int:ejercicio_id>/eliminar', methods=['POST'])
@docente_required
def eliminar(ejercicio_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT subtema_id FROM ejercicios WHERE id = %s", (ejercicio_id,))
    ej = cur.fetchone()
    if not ej:
        cur.close()
        return redirect(url_for('temas.lista'))

    cur.execute("DELETE FROM ejercicios WHERE id = %s", (ejercicio_id,))
    db.commit()
    cur.close()
    return redirect(url_for('ejercicios.lista', subtema_id=ej['subtema_id']))