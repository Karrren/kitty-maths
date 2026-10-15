-- ============================================
-- BASE DE DATOS: KITTY MATHS
-- Proyecto: Diseño y elaboración de una página web
-- para la retroalimentación de temas estadísticos
-- IET San Luis - Garagoa, Boyacá - 2026
-- ============================================

CREATE DATABASE IF NOT EXISTS kitty_maths CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kitty_maths;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('estudiante', 'docente') DEFAULT 'estudiante',
    fecha_registro DATETIME DEFAULT NOW()
);

-- Tabla de temas principales
CREATE TABLE IF NOT EXISTS temas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    icono VARCHAR(50) DEFAULT 'fas fa-chart-bar',
    color VARCHAR(20) DEFAULT '#7B2FBE',
    orden INT DEFAULT 0
);

-- Tabla de subtemas
CREATE TABLE IF NOT EXISTS subtemas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tema_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    contenido TEXT,
    orden INT DEFAULT 0,
    FOREIGN KEY (tema_id) REFERENCES temas(id) ON DELETE CASCADE
);

-- Tabla de ejercicios
CREATE TABLE IF NOT EXISTS ejercicios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subtema_id INT NOT NULL,
    tipo ENUM('opcion_multiple', 'verdadero_falso') DEFAULT 'opcion_multiple',
    pregunta TEXT NOT NULL,
    opcion_a VARCHAR(255),
    opcion_b VARCHAR(255),
    opcion_c VARCHAR(255),
    opcion_d VARCHAR(255),
    respuesta_correcta VARCHAR(1) NOT NULL,
    explicacion TEXT,
    dificultad ENUM('facil', 'medio', 'dificil') DEFAULT 'medio',
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE CASCADE
);

-- Tabla de intentos individuales
CREATE TABLE IF NOT EXISTS intentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ejercicio_id INT NOT NULL,
    respuesta VARCHAR(1),
    correcto BOOLEAN DEFAULT FALSE,
    fecha DATETIME DEFAULT NOW(),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id) ON DELETE CASCADE
);

-- Tabla de progreso por subtema
CREATE TABLE IF NOT EXISTS progreso_subtema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    subtema_id INT NOT NULL,
    completado BOOLEAN DEFAULT FALSE,
    total_intentos INT DEFAULT 0,
    total_aciertos INT DEFAULT 0,
    porcentaje DECIMAL(5,2) DEFAULT 0.00,
    fecha_inicio DATETIME DEFAULT NOW(),
    fecha_completado DATETIME,
    UNIQUE KEY unico_progreso (usuario_id, subtema_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE CASCADE
);

-- ============================================
-- DATOS INICIALES
-- ============================================

INSERT INTO temas (nombre, descripcion, icono, color, orden) VALUES
('Variables Estadísticas', 'Aprende sobre los tipos de variables estadísticas: cualitativas y cuantitativas.', 'fas fa-list-alt', '#7B2FBE', 1),
('Distribución de Frecuencias', 'Organiza datos en tablas de frecuencia, calcula frecuencias absolutas y relativas.', 'fas fa-table', '#E91E8C', 2),
('Medidas de Tendencia Central', 'Calcula la media, mediana y moda de un conjunto de datos.', 'fas fa-chart-line', '#FF6B35', 3),
('Medidas de Dispersión', 'Comprende el rango, varianza y desviación estándar de los datos.', 'fas fa-arrows-alt-h', '#1E88E5', 4),
('Probabilidad', 'Estudia experimentos aleatorios, espacio muestral y la regla de Laplace.', 'fas fa-dice', '#43A047', 5);

-- Subtemas de Variables Estadísticas
INSERT INTO subtemas (tema_id, nombre, descripcion, contenido, orden) VALUES
(1, 'Definición de Variable Estadística', 'Concepto básico de variable estadística y sus características.',
'Una <strong>variable estadística</strong> es cualquier característica o atributo que puede variar entre los individuos de una población y que puede ser medida u observada.<br><br>
<h5>Características de una variable estadística:</h5>
<ul>
<li>Debe poder variar de un individuo a otro</li>
<li>Debe ser medible o clasificable</li>
<li>Debe estar claramente definida</li>
</ul>
<h5>Ejemplos:</h5>
<ul>
<li>La edad de los estudiantes de grado 11</li>
<li>El color de cabello de los estudiantes</li>
<li>La nota obtenida en matemáticas</li>
<li>El número de hermanos de cada estudiante</li>
</ul>
<div class="alert alert-info"><strong>Recuerda:</strong> Una variable puede tomar diferentes valores, mientras que una constante siempre tiene el mismo valor.</div>', 1),

(1, 'Variables Cualitativas y Cuantitativas', 'Diferencia entre variables cualitativas y cuantitativas.',
'Las variables estadísticas se clasifican principalmente en dos grandes grupos:<br><br>
<h5>1. Variables Cualitativas (Categóricas)</h5>
Son aquellas que expresan <strong>cualidades o atributos</strong> y NO pueden medirse numéricamente.<br>
<ul>
<li><strong>Nominales:</strong> sin orden entre categorías (color de ojos, género, ciudad)</li>
<li><strong>Ordinales:</strong> con orden entre categorías (nivel de satisfacción: bajo, medio, alto)</li>
</ul>
<h5>2. Variables Cuantitativas (Numéricas)</h5>
Son aquellas que se expresan con <strong>valores numéricos</strong> y permiten operaciones matemáticas.<br>
<ul>
<li><strong>Discretas:</strong> toman valores enteros (número de hijos: 0, 1, 2, 3...)</li>
<li><strong>Continuas:</strong> pueden tomar cualquier valor en un rango (estatura: 1.65 m, peso: 58.3 kg)</li>
</ul>
<div class="alert alert-success"><strong>Truco:</strong> Si puedes preguntar "¿Cuánto?" → cuantitativa. Si preguntas "¿Cuál?" → cualitativa.</div>', 2),

(1, 'Escalas de Medición', 'Las cuatro escalas de medición: nominal, ordinal, de intervalo y de razón.',
'Las <strong>escalas de medición</strong> determinan el nivel de precisión con el que podemos medir una variable:<br><br>
<h5>1. Escala Nominal</h5>
Solo permite clasificar sin establecer orden. Ejemplo: <em>género (masculino/femenino), color favorito</em>.<br><br>
<h5>2. Escala Ordinal</h5>
Permite clasificar y ordenar, pero las diferencias entre categorías no son iguales. Ejemplo: <em>niveles de rendimiento (bajo, básico, alto, superior)</em>.<br><br>
<h5>3. Escala de Intervalo</h5>
Tiene un orden y distancias iguales entre valores, pero el cero es arbitrario. Ejemplo: <em>temperatura en Celsius (0°C no significa ausencia de temperatura)</em>.<br><br>
<h5>4. Escala de Razón</h5>
Tiene todas las características anteriores Y el cero es absoluto (significa ausencia total). Ejemplo: <em>peso, estatura, ingresos económicos</em>.<br><br>
<div class="alert alert-warning"><strong>Importante:</strong> La escala de razón es la más completa y permite todas las operaciones matemáticas.</div>', 3);

-- Subtemas de Distribución de Frecuencias
INSERT INTO subtemas (tema_id, nombre, descripcion, contenido, orden) VALUES
(2, 'Tablas de Frecuencia', 'Construcción e interpretación de tablas de frecuencia.',
'Una <strong>tabla de frecuencias</strong> organiza los datos de una variable estadística, mostrando cuántas veces aparece cada valor.<br><br>
<h5>Elementos de una tabla de frecuencia:</h5>
<ul>
<li><strong>xi:</strong> Valor o categoría de la variable</li>
<li><strong>fi:</strong> Frecuencia absoluta (número de veces que aparece el valor)</li>
<li><strong>hi:</strong> Frecuencia relativa (fi / n)</li>
<li><strong>Fi:</strong> Frecuencia absoluta acumulada</li>
<li><strong>Hi:</strong> Frecuencia relativa acumulada</li>
</ul>
<h5>Ejemplo:</h5>
Notas de 10 estudiantes: 3, 4, 4, 5, 3, 4, 5, 3, 4, 5<br><br>
<table class="table table-bordered table-sm">
<thead class="table-purple"><tr><th>xi</th><th>fi</th><th>hi</th><th>Fi</th><th>Hi</th></tr></thead>
<tbody>
<tr><td>3</td><td>3</td><td>0.30</td><td>3</td><td>0.30</td></tr>
<tr><td>4</td><td>4</td><td>0.40</td><td>7</td><td>0.70</td></tr>
<tr><td>5</td><td>3</td><td>0.30</td><td>10</td><td>1.00</td></tr>
<tr><td><strong>Total</strong></td><td><strong>10</strong></td><td><strong>1.00</strong></td><td></td><td></td></tr>
</tbody></table>
<div class="alert alert-info">La suma de todas las frecuencias absolutas (fi) siempre es igual al total de datos (n).</div>', 1),

(2, 'Frecuencias Absolutas y Relativas', 'Calculo e interpretación de frecuencias absolutas, relativas y acumuladas.',
'<h5>Frecuencia Absoluta (fi)</h5>
Es el <strong>número de veces</strong> que aparece un dato en el conjunto de datos.<br>
<em>Ejemplo:</em> Si 8 de 30 estudiantes tienen 16 años, la frecuencia absoluta de "16 años" es fi = 8.<br><br>
<h5>Frecuencia Relativa (hi)</h5>
Es la <strong>proporción</strong> que representa cada valor respecto al total.<br>
<strong>Fórmula:</strong> hi = fi / n<br>
<em>Ejemplo:</em> hi = 8/30 = 0.267 (o 26.7%)<br><br>
<h5>Frecuencia Acumulada (Fi)</h5>
Es la <strong>suma acumulada</strong> de las frecuencias absolutas hasta un valor dado.<br>
<em>Ejemplo:</em> Si fi para 15 años = 5 y fi para 16 años = 8, entonces F(16) = 5 + 8 = 13.<br><br>
<h5>Frecuencia Relativa Acumulada (Hi)</h5>
Es la <strong>suma acumulada</strong> de las frecuencias relativas: Hi = Fi / n<br><br>
<div class="alert alert-success"><strong>Recuerda:</strong> La suma de todas las hi siempre es igual a 1 (o 100%).</div>', 2);

-- Subtemas de Medidas de Tendencia Central
INSERT INTO subtemas (tema_id, nombre, descripcion, contenido, orden) VALUES
(3, 'Media Aritmética', 'Cálculo e interpretación de la media aritmética.',
'La <strong>media aritmética (x̄)</strong> es el valor promedio de un conjunto de datos. Se calcula sumando todos los valores y dividiendo entre el número total de datos.<br><br>
<h5>Fórmula:</h5>
<div class="formula-box">x̄ = (x₁ + x₂ + x₃ + ... + xₙ) / n = Σxi / n</div><br>
<h5>Ejemplo:</h5>
Notas de un estudiante en 5 exámenes: 3.5, 4.0, 3.8, 4.5, 3.2<br>
x̄ = (3.5 + 4.0 + 3.8 + 4.5 + 3.2) / 5 = 19.0 / 5 = <strong>3.8</strong><br><br>
<h5>Propiedades de la media:</h5>
<ul>
<li>La suma de las desviaciones respecto a la media es siempre cero</li>
<li>Se ve muy afectada por valores extremos (atípicos)</li>
<li>Siempre existe un único valor de media</li>
<li>Usa todos los valores del conjunto de datos</li>
</ul>
<div class="alert alert-warning"><strong>Cuidado:</strong> Si hay valores muy extremos, la media puede no representar bien el conjunto. En ese caso, considera usar la mediana.</div>', 1),

(3, 'Mediana', 'Cálculo e interpretación de la mediana.',
'La <strong>mediana (Me)</strong> es el valor que divide el conjunto de datos ordenados en dos partes iguales. El 50% de los datos es menor o igual a la mediana y el 50% es mayor o igual.<br><br>
<h5>Cómo calcularla:</h5>
<strong>Paso 1:</strong> Ordena los datos de menor a mayor.<br>
<strong>Paso 2:</strong><br>
<ul>
<li>Si n es <strong>impar</strong>: La mediana es el valor central → posición (n+1)/2</li>
<li>Si n es <strong>par</strong>: La mediana es el promedio de los dos valores centrales → posiciones n/2 y (n/2)+1</li>
</ul>
<h5>Ejemplos:</h5>
<strong>Impar:</strong> Datos: 2, 5, 7, 8, 12 → n=5, posición central = 3 → Me = <strong>7</strong><br><br>
<strong>Par:</strong> Datos: 2, 5, 7, 8, 12, 15 → n=6, posiciones 3 y 4 → Me = (7+8)/2 = <strong>7.5</strong><br><br>
<div class="alert alert-info"><strong>Ventaja:</strong> La mediana NO se ve afectada por valores extremos, por eso es útil cuando hay datos atípicos.</div>', 2),

(3, 'Moda', 'Identificación e interpretación de la moda.',
'La <strong>moda (Mo)</strong> es el valor que aparece con mayor frecuencia en un conjunto de datos.<br><br>
<h5>Tipos de moda:</h5>
<ul>
<li><strong>Unimodal:</strong> Un solo valor con mayor frecuencia. Ej: {2, 3, <u>4</u>, 4, 4, 5, 7} → Mo = 4</li>
<li><strong>Bimodal:</strong> Dos valores con la misma mayor frecuencia. Ej: {1, <u>2</u>, 2, <u>3</u>, 3, 4} → Mo = 2 y 3</li>
<li><strong>Multimodal:</strong> Más de dos modas.</li>
<li><strong>Amodal:</strong> Todos los datos tienen la misma frecuencia. No hay moda.</li>
</ul>
<h5>Ejemplo:</h5>
Calificaciones: 3, 4, 4, 4, 5, 3, 5, 4, 2, 4<br>
Contando: 2→1 vez, 3→2 veces, 4→5 veces, 5→2 veces<br>
Mo = <strong>4</strong> (aparece 5 veces)<br><br>
<div class="alert alert-success"><strong>Uso:</strong> La moda es especialmente útil para variables cualitativas, donde no es posible calcular media o mediana.</div>', 3);

-- Subtemas de Medidas de Dispersión
INSERT INTO subtemas (tema_id, nombre, descripcion, contenido, orden) VALUES
(4, 'Rango y Varianza', 'Cálculo del rango y la varianza de un conjunto de datos.',
'Las medidas de dispersión indican qué tan <strong>dispersos o agrupados</strong> están los datos respecto a un valor central.<br><br>
<h5>Rango (R)</h5>
Es la diferencia entre el valor máximo y el mínimo del conjunto de datos.<br>
<div class="formula-box">R = Valor máximo − Valor mínimo</div>
<em>Ejemplo:</em> Datos: 5, 8, 3, 12, 7 → R = 12 − 3 = <strong>9</strong><br><br>
<h5>Varianza (σ² o S²)</h5>
Mide qué tan alejados están los datos de la media. Es el promedio de los cuadrados de las desviaciones.<br>
<div class="formula-box">S² = Σ(xi − x̄)² / (n − 1)  [muestra]<br>σ² = Σ(xi − μ)² / n  [población]</div>
<h5>Ejemplo:</h5>
Datos: 2, 4, 4, 4, 5, 5, 7, 9 → x̄ = 5<br>
S² = [(2-5)² + (4-5)² + (4-5)² + (4-5)² + (5-5)² + (5-5)² + (7-5)² + (9-5)²] / (8-1)<br>
S² = [9 + 1 + 1 + 1 + 0 + 0 + 4 + 16] / 7 = 32/7 ≈ <strong>4.57</strong><br><br>
<div class="alert alert-info">Una varianza pequeña indica que los datos están muy agrupados cerca de la media. Una varianza grande indica mayor dispersión.</div>', 1),

(4, 'Desviación Estándar', 'Cálculo e interpretación de la desviación estándar.',
'La <strong>desviación estándar (S o σ)</strong> es la raíz cuadrada de la varianza. Tiene las mismas unidades que los datos originales, lo que facilita su interpretación.<br><br>
<div class="formula-box">S = √S² = √[Σ(xi − x̄)² / (n − 1)]</div><br>
<h5>Ejemplo:</h5>
Continuando con el ejemplo anterior donde S² ≈ 4.57:<br>
S = √4.57 ≈ <strong>2.14</strong><br><br>
Esto significa que en promedio, los datos se alejan <strong>2.14 unidades</strong> de la media.<br><br>
<h5>Interpretación:</h5>
<ul>
<li><strong>S pequeña:</strong> Los datos son muy homogéneos (parecidos entre sí)</li>
<li><strong>S grande:</strong> Los datos son muy heterogéneos (muy diferentes entre sí)</li>
<li><strong>S = 0:</strong> Todos los datos son iguales</li>
</ul>
<h5>Regla empírica (68-95-99.7%):</h5>
En una distribución normal:<br>
- El 68% de los datos cae entre x̄ ± 1S<br>
- El 95% cae entre x̄ ± 2S<br>
- El 99.7% cae entre x̄ ± 3S<br><br>
<div class="alert alert-success">La desviación estándar es la medida de dispersión más usada en estadística.</div>', 2);

-- Subtemas de Probabilidad
INSERT INTO subtemas (tema_id, nombre, descripcion, contenido, orden) VALUES
(5, 'Experimentos Aleatorios y Espacio Muestral', 'Conceptos básicos de probabilidad: experimentos aleatorios, espacio muestral y eventos.',
'<h5>Experimento Aleatorio</h5>
Es un proceso cuyo resultado <strong>no se puede predecir con certeza</strong> antes de realizarlo.<br>
<em>Ejemplos:</em> lanzar una moneda, lanzar un dado, elegir un estudiante al azar.<br><br>
<h5>Espacio Muestral (S o Ω)</h5>
Es el <strong>conjunto de todos los resultados posibles</strong> de un experimento aleatorio.<br>
<em>Ejemplo — lanzar un dado:</em> Ω = {1, 2, 3, 4, 5, 6}<br>
<em>Ejemplo — lanzar una moneda:</em> Ω = {Cara, Sello}<br><br>
<h5>Evento (A)</h5>
Es un <strong>subconjunto del espacio muestral</strong>; es decir, un conjunto de resultados específicos.<br>
<em>Ejemplo:</em> Evento A = "obtener número par" = {2, 4, 6}<br><br>
<h5>Tipos de eventos:</h5>
<ul>
<li><strong>Evento simple:</strong> Un solo resultado. Ej: A = {3}</li>
<li><strong>Evento compuesto:</strong> Más de un resultado. Ej: A = {2, 4, 6}</li>
<li><strong>Evento imposible (∅):</strong> No puede ocurrir. Ej: "obtener 7 en un dado"</li>
<li><strong>Evento seguro (S):</strong> Siempre ocurre. Ej: "obtener un número entre 1 y 6"</li>
</ul>
<div class="alert alert-info">El evento complemento de A (A´ o Ā) contiene todos los resultados de Ω que NO están en A.</div>', 1),

(5, 'Regla de Laplace', 'Cálculo de probabilidades usando la regla clásica de Laplace.',
'La <strong>Regla de Laplace</strong> permite calcular la probabilidad de un evento cuando todos los resultados del espacio muestral son igualmente probables.<br><br>
<div class="formula-box">P(A) = Casos favorables / Casos posibles = |A| / |Ω|</div><br>
<h5>Propiedades de la probabilidad:</h5>
<ul>
<li>0 ≤ P(A) ≤ 1 (siempre entre 0 y 1)</li>
<li>P(∅) = 0 (evento imposible)</li>
<li>P(Ω) = 1 (evento seguro)</li>
<li>P(A) + P(A´) = 1</li>
</ul>
<h5>Ejemplos:</h5>
<strong>1. Un dado:</strong> P(número par) = |{2,4,6}| / |{1,2,3,4,5,6}| = 3/6 = <strong>0.5 = 50%</strong><br><br>
<strong>2. Baraja de cartas (52 cartas):</strong><br>
P(Rey) = 4/52 = 1/13 ≈ <strong>0.077 = 7.7%</strong><br><br>
<strong>3. Urna con bolas:</strong> Una urna tiene 3 bolas rojas, 5 azules y 2 verdes.<br>
P(azul) = 5/10 = <strong>0.5 = 50%</strong><br>
P(roja) = 3/10 = <strong>0.3 = 30%</strong><br><br>
<div class="alert alert-warning"><strong>Importante:</strong> La regla de Laplace solo aplica cuando TODOS los resultados tienen la misma probabilidad de ocurrir (equiprobables).</div>', 2),

(5, 'Probabilidad Condicional', 'Cálculo de probabilidades condicionales e independencia de eventos.',
'La <strong>probabilidad condicional P(A|B)</strong> es la probabilidad de que ocurra el evento A, sabiendo que ya ocurrió el evento B.<br><br>
<div class="formula-box">P(A|B) = P(A ∩ B) / P(B) &nbsp;&nbsp; [siempre que P(B) ≠ 0]</div><br>
<h5>Ejemplo:</h5>
En un grupo de 30 estudiantes: 18 son mujeres y 12 son hombres. De las mujeres, 10 aprobaron estadística.<br>
Si selecciono al azar una mujer, ¿cuál es la probabilidad de que haya aprobado?<br>
P(aprobó | mujer) = 10/18 ≈ <strong>0.556 = 55.6%</strong><br><br>
<h5>Regla de la multiplicación:</h5>
<div class="formula-box">P(A ∩ B) = P(B) × P(A|B) = P(A) × P(B|A)</div><br>
<h5>Eventos Independientes:</h5>
Dos eventos son <strong>independientes</strong> si la ocurrencia de uno NO afecta la probabilidad del otro.<br>
Si A y B son independientes: P(A|B) = P(A) y P(A ∩ B) = P(A) × P(B)<br><br>
<em>Ejemplo:</em> Lanzar una moneda dos veces. El resultado del primer lanzamiento no afecta al segundo.<br><br>
<div class="alert alert-info"><strong>Verificación:</strong> Si P(A ∩ B) = P(A) × P(B), entonces A y B son independientes.</div>', 3);

-- Ejercicios de Variables Estadísticas - Subtema 1
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(1, 'opcion_multiple', '¿Cuál de los siguientes es un ejemplo de variable estadística?',
 'El número π (pi)', 'La velocidad de la luz', 'La edad de los estudiantes de un salón', 'El valor de la gravedad (9.8 m/s²)',
 'C', 'La edad de los estudiantes varía de un individuo a otro y puede ser medida, por lo tanto es una variable estadística. Los demás son constantes.', 'facil'),

(1, 'opcion_multiple', '¿Cuál es la característica principal que define a una variable estadística?',
 'Siempre debe ser un número', 'Puede variar entre individuos de una población', 'Solo mide características físicas', 'Siempre tiene valores entre 0 y 100',
 'B', 'Una variable estadística se define como una característica que puede variar entre los individuos de una población. Puede ser numérica o no numérica.', 'facil'),

(1, 'verdadero_falso', '¿Es correcto afirmar que una constante puede ser considerada una variable estadística?',
 'Verdadero', 'Falso', NULL, NULL,
 'B', 'Falso. Una constante tiene siempre el mismo valor y no varía, por lo que NO es una variable estadística. Las variables estadísticas, por definición, deben poder variar entre individuos.', 'facil');

-- Ejercicios de Variables - Subtema 2
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(2, 'opcion_multiple', '¿A qué tipo de variable pertenece "el color de los ojos de los estudiantes"?',
 'Cuantitativa discreta', 'Cuantitativa continua', 'Cualitativa nominal', 'Cualitativa ordinal',
 'C', 'El color de ojos es una cualidad (no un número) y sus categorías no tienen un orden natural (azul no es mayor que café), por lo tanto es una variable cualitativa nominal.', 'facil'),

(2, 'opcion_multiple', '"El número de hermanos de cada estudiante" es una variable:',
 'Cualitativa nominal', 'Cualitativa ordinal', 'Cuantitativa discreta', 'Cuantitativa continua',
 'C', 'El número de hermanos se expresa con valores numéricos enteros (0, 1, 2, 3...) y no puede tomar valores fraccionarios, por lo que es cuantitativa discreta.', 'facil'),

(2, 'opcion_multiple', '"La estatura en centímetros de los alumnos" es una variable:',
 'Cualitativa ordinal', 'Cuantitativa discreta', 'Cualitativa nominal', 'Cuantitativa continua',
 'D', 'La estatura puede tomar cualquier valor dentro de un rango (por ejemplo 165.3 cm, 172.8 cm), por lo que es una variable cuantitativa continua.', 'medio'),

(2, 'opcion_multiple', '"El nivel de satisfacción con la clase: bajo, medio, alto" es una variable:',
 'Cualitativa ordinal', 'Cualitativa nominal', 'Cuantitativa discreta', 'Cuantitativa continua',
 'A', 'Es cualitativa porque expresa una categoría (no un número), y es ordinal porque las categorías tienen un orden natural: bajo < medio < alto.', 'medio'),

(2, 'verdadero_falso', '¿La variable "número de estudiantes que aprobaron el examen" es cuantitativa discreta?',
 'Verdadero', 'Falso', NULL, NULL,
 'A', 'Verdadero. El número de estudiantes solo puede ser un valor entero (no puede haber 2.5 estudiantes), por lo tanto es cuantitativa discreta.', 'facil');

-- Ejercicios Escala de Medición - Subtema 3
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(3, 'opcion_multiple', 'La variable "temperatura en grados Celsius" usa una escala de medición:',
 'Nominal', 'Ordinal', 'De intervalo', 'De razón',
 'C', 'La temperatura en Celsius usa escala de intervalo porque tiene distancias iguales entre valores, pero el cero (0°C) es arbitrario: no significa ausencia de temperatura.', 'medio'),

(3, 'opcion_multiple', '¿Qué escala de medición tiene un cero absoluto que indica ausencia total de la característica?',
 'Nominal', 'Ordinal', 'De intervalo', 'De razón',
 'D', 'La escala de razón es la única que tiene un cero absoluto. Por ejemplo, 0 kg significa ausencia total de peso. Esta escala permite todas las operaciones matemáticas.', 'medio'),

(3, 'opcion_multiple', 'Clasificar estudiantes por ciudad de residencia (Bogotá, Medellín, Cali) es un ejemplo de escala:',
 'Nominal', 'Ordinal', 'De intervalo', 'De razón',
 'A', 'Las ciudades son categorías sin orden natural entre sí (Bogotá no es "más" que Medellín). Por eso es una escala nominal, la más básica de las cuatro.', 'facil');

-- Ejercicios Tablas de Frecuencia - Subtema 4
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(4, 'opcion_multiple', 'En una tabla de frecuencias, ¿qué representa la frecuencia absoluta (fi)?',
 'La proporción de veces que aparece un valor', 'El número de veces que aparece un valor', 'La suma acumulada de frecuencias', 'El porcentaje de datos',
 'B', 'La frecuencia absoluta (fi) es simplemente el número de veces que aparece un determinado valor en el conjunto de datos. Por ejemplo, si 5 estudiantes tienen nota 4, entonces fi(4) = 5.', 'facil'),

(4, 'opcion_multiple', 'Si en un grupo de 40 estudiantes, 10 obtuvieron nota 5, ¿cuál es la frecuencia relativa de nota 5?',
 '10', '0.10', '0.25', '25',
 'C', 'La frecuencia relativa se calcula como hi = fi/n = 10/40 = 0.25. Representa el 25% de los estudiantes. Note que la frecuencia relativa siempre está entre 0 y 1.', 'medio'),

(4, 'opcion_multiple', '¿Cuánto debe sumar la columna de frecuencias relativas (hi) en una tabla de frecuencias?',
 'El total de datos (n)', 'Siempre 100', 'Siempre 1', 'El valor máximo de la variable',
 'C', 'La suma de todas las frecuencias relativas siempre es igual a 1 (o equivalentemente 100%). Esto se debe a que representan proporciones del total y juntas forman el 100% de los datos.', 'facil');

-- Ejercicios Frecuencias - Subtema 5
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(5, 'opcion_multiple', 'Los datos ordenados son: 2, 2, 3, 4, 4, 4, 5. La frecuencia absoluta acumulada F(4) es:',
 '3', '4', '6', '7',
 'C', 'La frecuencia absoluta acumulada F(4) es la suma de todas las frecuencias absolutas hasta el valor 4 inclusive: f(2) + f(3) + f(4) = 2 + 1 + 3 = 6.', 'medio'),

(5, 'verdadero_falso', '¿La frecuencia relativa acumulada del último valor siempre es igual a 1?',
 'Verdadero', 'Falso', NULL, NULL,
 'A', 'Verdadero. La frecuencia relativa acumulada del último valor incluye TODOS los datos, y como la suma de todas las frecuencias relativas es 1, la acumulada final siempre es 1.', 'medio');

-- Ejercicios Media Aritmética - Subtema 6
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(6, 'opcion_multiple', 'Las notas de un estudiante son: 3.0, 4.0, 3.5, 4.5, 5.0. ¿Cuál es su media aritmética?',
 '3.8', '4.0', '4.2', '3.5',
 'B', 'x̄ = (3.0 + 4.0 + 3.5 + 4.5 + 5.0) / 5 = 20.0 / 5 = 4.0. La media aritmética es 4.0.', 'facil'),

(6, 'opcion_multiple', '¿Cuál es una desventaja de la media aritmética como medida de tendencia central?',
 'Es difícil de calcular', 'No usa todos los datos', 'Se ve muy afectada por valores extremos', 'Solo sirve para variables cualitativas',
 'C', 'La principal desventaja de la media es que se ve fuertemente afectada por valores extremos (outliers). Por ejemplo, si un estudiante tiene notas 2, 4, 4, 4, 10, la media sería 4.8, pero no representa bien el rendimiento típico.', 'medio'),

(6, 'opcion_multiple', 'Un estudiante tiene promedio (media) de 3.8 en 4 exámenes. ¿Qué nota debe sacar en el 5° examen para tener una media de 4.0?',
 '4.0', '4.5', '4.8', '5.0',
 'C', 'Si la media de 4 exámenes es 3.8, la suma es 3.8 × 4 = 15.2. Para que la media de 5 exámenes sea 4.0, necesito que la suma sea 4.0 × 5 = 20.0. Por tanto la nota del 5° examen debe ser 20.0 - 15.2 = 4.8.', 'dificil');

-- Ejercicios Mediana - Subtema 7
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(7, 'opcion_multiple', 'Dados los siguientes valores ordenados: 5, 7, 8, 10, 12. ¿Cuál es la mediana?',
 '7', '8', '10', '8.4',
 'B', 'Con n=5 (impar), la mediana es el valor en la posición central: (5+1)/2 = 3. El tercer valor del conjunto ordenado {5, 7, 8, 10, 12} es 8. Por tanto Me = 8.', 'facil'),

(7, 'opcion_multiple', 'Dados los valores: 3, 5, 7, 9, 11, 13. ¿Cuál es la mediana?',
 '7', '8', '9', '7.5',
 'B', 'Con n=6 (par), la mediana es el promedio de los valores en las posiciones 3 y 4: (7+9)/2 = 16/2 = 8. Por tanto Me = 8.', 'medio'),

(7, 'verdadero_falso', '¿La mediana es más resistente a valores extremos que la media aritmética?',
 'Verdadero', 'Falso', NULL, NULL,
 'A', 'Verdadero. La mediana no se ve afectada por valores extremos (atípicos) porque solo considera la posición central de los datos, no su magnitud. Por eso es preferible cuando hay valores muy altos o muy bajos.', 'medio');

-- Ejercicios Moda - Subtema 8
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(8, 'opcion_multiple', 'En el conjunto {3, 4, 4, 5, 5, 5, 6, 7}, ¿cuál es la moda?',
 '3', '4', '5', '6',
 'C', 'La moda es el valor que aparece con mayor frecuencia. Contando: 3→1, 4→2, 5→3, 6→1, 7→1. El valor 5 aparece 3 veces, que es la mayor frecuencia. Mo = 5.', 'facil'),

(8, 'opcion_multiple', 'Si un conjunto de datos tiene dos modas, se llama:',
 'Unimodal', 'Bimodal', 'Amodal', 'Multimodal',
 'B', 'Un conjunto con exactamente dos valores que tienen la misma frecuencia máxima se llama bimodal (dos modas). Unimodal tiene una moda, multimodal tiene más de dos, y amodal no tiene moda.', 'facil'),

(8, 'opcion_multiple', '¿Para qué tipo de variable es más útil la moda como medida de tendencia central?',
 'Solo para variables cuantitativas continuas', 'Solo para variables cuantitativas discretas', 'Para variables cualitativas (categorías)', 'Solo cuando todos los datos son diferentes',
 'C', 'La moda es la única medida de tendencia central que puede aplicarse a variables cualitativas. Por ejemplo: la talla de ropa más vendida (S, M, L, XL) o el color más popular de un producto.', 'medio');

-- Ejercicios Rango y Varianza - Subtema 9
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(9, 'opcion_multiple', 'El conjunto de notas es: 2, 5, 3, 8, 4. ¿Cuál es el rango?',
 '4', '5', '6', '8',
 'C', 'El rango es la diferencia entre el valor máximo y el mínimo: R = 8 - 2 = 6.', 'facil'),

(9, 'opcion_multiple', '¿Qué indica una varianza alta en un conjunto de datos?',
 'Los datos están muy agrupados alrededor de la media', 'Los datos están muy dispersos respecto a la media', 'La media es un valor muy alto', 'No hay valores extremos en los datos',
 'B', 'Una varianza alta indica que los datos están muy dispersos (alejados) respecto a la media. Una varianza baja indica que los datos están agrupados cerca de la media.', 'medio'),

(9, 'verdadero_falso', '¿La varianza siempre tiene las mismas unidades que los datos originales?',
 'Verdadero', 'Falso', NULL, NULL,
 'B', 'Falso. La varianza está expresada en las unidades al cuadrado de los datos originales. Por ejemplo, si los datos son en kg, la varianza está en kg². Por eso existe la desviación estándar, que sí tiene las mismas unidades que los datos.', 'medio');

-- Ejercicios Desviación Estándar - Subtema 10
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(10, 'opcion_multiple', 'Si la varianza de un conjunto de datos es 16, ¿cuál es la desviación estándar?',
 '16', '8', '4', '256',
 'C', 'La desviación estándar es la raíz cuadrada de la varianza: S = √16 = 4. La desviación estándar siempre es la raíz cuadrada positiva de la varianza.', 'facil'),

(10, 'opcion_multiple', '¿Cuál es la principal ventaja de la desviación estándar sobre la varianza?',
 'Es más fácil de calcular', 'Tiene las mismas unidades que los datos originales', 'Siempre es mayor que la varianza', 'No depende de la media',
 'B', 'La principal ventaja de la desviación estándar es que tiene las mismas unidades que los datos originales, lo que facilita su interpretación. La varianza está en unidades al cuadrado.', 'medio'),

(10, 'opcion_multiple', 'Si todos los datos de un conjunto son iguales (por ejemplo: 5, 5, 5, 5), ¿cuánto vale la desviación estándar?',
 '5', '1', '0', 'No se puede calcular',
 'C', 'Si todos los datos son iguales, no hay variación respecto a la media. Todas las desviaciones son 0, por lo que la varianza es 0 y la desviación estándar también es 0. S = 0 indica que no hay dispersión.', 'medio');

-- Ejercicios Espacio Muestral - Subtema 11
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(11, 'opcion_multiple', 'Al lanzar un dado de 6 caras, ¿cuántos elementos tiene el espacio muestral?',
 '1', '3', '6', '12',
 'C', 'El espacio muestral de un dado de 6 caras es Ω = {1, 2, 3, 4, 5, 6}, que contiene 6 elementos. Cada número del 1 al 6 es un resultado posible del experimento.', 'facil'),

(11, 'opcion_multiple', '¿Cómo se llama un evento cuya probabilidad es 0 (nunca puede ocurrir)?',
 'Evento seguro', 'Evento simple', 'Evento imposible', 'Evento complemento',
 'C', 'Un evento imposible es aquel que nunca puede ocurrir, es decir, su probabilidad es 0. Se representa con el símbolo ∅ (conjunto vacío). Ejemplo: "obtener 7 al lanzar un dado de 6 caras".', 'facil'),

(11, 'opcion_multiple', 'Se lanza una moneda dos veces. ¿Cuántos elementos tiene el espacio muestral?',
 '2', '3', '4', '6',
 'C', 'Al lanzar una moneda dos veces, los resultados posibles son: {CC, CS, SC, SS} donde C=Cara y S=Sello. El espacio muestral tiene 4 elementos (2 × 2 = 4).', 'medio');

-- Ejercicios Regla de Laplace - Subtema 12
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(12, 'opcion_multiple', 'Al lanzar un dado, ¿cuál es la probabilidad de obtener un número impar?',
 '1/6', '2/6', '3/6', '4/6',
 'C', 'Los números impares en un dado son {1, 3, 5}: 3 casos favorables. El espacio muestral tiene 6 casos posibles. P(impar) = 3/6 = 1/2 = 0.5 = 50%.', 'facil'),

(12, 'opcion_multiple', 'Una bolsa tiene 4 bolas rojas, 3 azules y 3 verdes. ¿Cuál es la probabilidad de sacar una bola azul?',
 '3/7', '3/10', '4/10', '1/3',
 'B', 'Total de bolas: 4 + 3 + 3 = 10. Bolas azules: 3. P(azul) = 3/10 = 0.3 = 30%.', 'facil'),

(12, 'opcion_multiple', 'Si P(A) = 0.35, ¿cuál es la probabilidad del evento complemento P(A´)?',
 '0.35', '0.65', '0.50', '1.35',
 'B', 'La probabilidad del evento complemento es P(A´) = 1 - P(A) = 1 - 0.35 = 0.65. Esto se debe a que P(A) + P(A´) = 1 siempre.', 'facil'),

(12, 'opcion_multiple', '¿Cuándo se puede aplicar la Regla de Laplace para calcular probabilidades?',
 'Siempre que el experimento sea aleatorio', 'Solo cuando hay exactamente 2 resultados posibles', 'Solo cuando todos los resultados son igualmente probables', 'Solo para experimentos con dados o monedas',
 'C', 'La Regla de Laplace solo se aplica cuando TODOS los resultados del espacio muestral son equiprobables (tienen la misma probabilidad de ocurrir). No sirve, por ejemplo, si un dado está cargado.', 'medio');

-- Ejercicios Probabilidad Condicional - Subtema 13
INSERT INTO ejercicios (subtema_id, tipo, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta, explicacion, dificultad) VALUES
(13, 'opcion_multiple', '¿Qué representa P(A|B)?',
 'La probabilidad de A multiplicada por B', 'La probabilidad de A dado que ya ocurrió B', 'La probabilidad de que A y B ocurran juntos', 'La probabilidad de A más la probabilidad de B',
 'B', 'La notación P(A|B) se lee "probabilidad de A dado B" y representa la probabilidad de que ocurra el evento A sabiendo que el evento B ya ha ocurrido. Es una probabilidad condicional.', 'facil'),

(13, 'opcion_multiple', 'P(A ∩ B) = 0.12 y P(B) = 0.4. ¿Cuál es P(A|B)?',
 '0.048', '0.30', '0.52', '3.33',
 'B', 'P(A|B) = P(A ∩ B) / P(B) = 0.12 / 0.4 = 0.30 = 30%. Esta es la probabilidad de A dado que B ya ocurrió.', 'medio'),

(13, 'verdadero_falso', 'Si dos eventos A y B son independientes, entonces P(A|B) = P(A).',
 'Verdadero', 'Falso', NULL, NULL,
 'A', 'Verdadero. Si A y B son independientes, la ocurrencia de B no afecta la probabilidad de A, por lo que P(A|B) = P(A). Esta es precisamente la definición matemática de independencia entre eventos.', 'medio'),

(13, 'opcion_multiple', 'En un grupo de 50 estudiantes: 30 estudian con Kitty Maths y 20 no. De los que estudian con Kitty Maths, 24 aprueban el examen. ¿Cuál es P(aprueba | usa Kitty Maths)?',
 '0.40', '0.48', '0.80', '0.60',
 'C', 'P(aprueba | usa Kitty Maths) = número que aprueba y usa Kitty / número que usa Kitty = 24/30 = 0.80 = 80%. De los estudiantes que usan Kitty Maths, el 80% aprueba.', 'dificil');
