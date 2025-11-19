# Adjuntar al nodo Camera3D
extends Camera3D

# Velocidad de Movimiento (WASD)
@export var speed: float = 10.0
# Sensibilidad del Ratón
@export var sensitivity: float = 0.005

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready():
	# Aseguramos que el cursor esté visible al inicio para poder interactuar
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	# 1. Manejo del Clic Derecho para Capturar el Ratón
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				# Al presionar el clic derecho: Captura el ratón para rotar
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				# Al soltar el clic derecho: Libera el ratón para interactuar
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# 2. Procesamiento de la Rotación SÓLO si el ratón está capturado
	if event is InputEventMouseMotion:
		# Verifica si el cursor está capturado (es decir, si el clic derecho está presionado)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# Rotación en el eje Y (mirar izquierda/derecha)
			rotation_y += -event.relative.x * sensitivity
			# Rotación en el eje X (mirar arriba/abajo), limitada
			rotation_x += -event.relative.y * sensitivity
			rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
			
			# Aplica la rotación
			rotation.y = rotation_y
			rotation.x = rotation_x

func _process(delta):
	var direction = Vector3.ZERO
	
	# Obtenemos las bases de la cámara (dirección local)
	var basis_z = global_transform.basis.z 
	var basis_x = global_transform.basis.x

	# 1. Movimiento Adelante/Atrás (W/S)
	if Input.is_action_pressed("move_forward"):
		direction += -basis_z
	if Input.is_action_pressed("move_backward"):
		direction += basis_z

	# 2. Movimiento Izquierda/Derecha (A/D)
	if Input.is_action_pressed("move_left"):
		direction += -basis_x
	if Input.is_action_pressed("move_right"):
		direction += basis_x
	
	# 3. Proyección sobre el plano XZ del mundo (Horizontalidad)
	
	# Eliminamos la componente Y del vector de dirección para asegurar movimiento horizontal
	direction.y = 0
	
	# Ahora, aplicamos la rotación horizontal (Y) de la cámara al vector de movimiento
	# Esto es similar a cómo resolvimos el problema de "Sims", pero lo aplicamos al vector resultante
	# después de la entrada WASD, no a la entrada bruta.
	
	# Rotamos el vector de movimiento (que ahora es plano XZ) según la rotación Y de la cámara.
	# El vector direction.y ya es 0, por lo que esta rotación solo afecta a X y Z.
	
	# --- LA SOLUCIÓN CLAVE ---
	if direction.length() > 0:
		# 4. Normalizar y mover
		direction = direction.normalized()
		translate(direction * speed * delta)
	
	# 5. Movimiento vertical (Q/E) se mantiene separado y global
	var vertical_move = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		vertical_move += Vector3.UP 
	if Input.is_action_pressed("move_down"):
		vertical_move += Vector3.DOWN 
	
	if vertical_move.length() > 0:
		translate(vertical_move * speed * delta)
