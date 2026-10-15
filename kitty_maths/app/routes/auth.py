from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from werkzeug.security import generate_password_hash, check_password_hash
from app import get_db

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/')
def index():
    if 'usuario_id' not in session:
        return redirect(url_for('auth.login'))
    return render_template('index.html')

@auth_bp.route('/registro', methods=['GET', 'POST'])
def registro():
    if 'usuario_id' in session:
        return redirect(url_for('dashboard.index'))
    if request.method == 'POST':
        nombre = request.form['nombre'].strip()
        email = request.form['email'].strip().lower()
        password = request.form['password']
        confirmar = request.form['confirmar']
        # El registro público solo crea estudiantes; los docentes los crea otro docente
        rol = 'estudiante'

        if password != confirmar:
            flash('Las contraseñas no coinciden.', 'danger')
            return render_template('auth/registro.html')

        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
        if cur.fetchone():
            flash('Este correo ya está registrado.', 'warning')
            cur.close()
            return render_template('auth/registro.html')

        hash_pw = generate_password_hash(password)
        cur.execute(
            "INSERT INTO usuarios (nombre, email, password_hash, rol) VALUES (%s, %s, %s, %s)",
            (nombre, email, hash_pw, rol)
        )
        db.commit()
        cur.close()
        flash('¡Registro exitoso! Ahora puedes iniciar sesión.', 'success')
        return redirect(url_for('auth.login'))
    return render_template('auth/registro.html')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if 'usuario_id' in session:
        return redirect(url_for('dashboard.index'))
    if request.method == 'POST':
        email = request.form['email'].strip().lower()
        password = request.form['password']

        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
        usuario = cur.fetchone()
        cur.close()

        if usuario and check_password_hash(usuario['password_hash'], password):
            session['usuario_id'] = usuario['id']
            session['usuario_nombre'] = usuario['nombre']
            session['usuario_rol'] = usuario['rol']
            flash(f'¡Bienvenido/a, {usuario["nombre"]}!', 'success')
            if usuario['rol'] == 'docente':
                return redirect(url_for('docente.panel'))
            return redirect(url_for('dashboard.index'))
        flash('Correo o contraseña incorrectos.', 'danger')
    return render_template('auth/login.html')

@auth_bp.route('/recuperar')
def recuperar():
    return render_template('auth/recuperar.html')

@auth_bp.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión correctamente.', 'info')
    return redirect(url_for('auth.index'))
