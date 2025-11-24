extends Camera3D


@export_group("Movimiento")
@export var speed: float = 40.0
@export var sensitivity: float = 0.005

@export_group("Zoom")
@export var min_fov: float = 30.0  # Zoom máximo (acercado)
@export var max_fov: float = 120.0 # Zoom mínimo (alejado)
@export var zoom_speed: float = 5.0 # Cuánto cambia por cada "tick" de la rueda
@export var zoom_smooth: float = 10.0 # Qué tan rápido se suaviza el movimiento

var rotation_x: float = 0.0
var rotation_y: float = 0.0
var target_fov: float = 75.0 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	target_fov = fov 

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_fov -= zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_fov += zoom_speed
		
		target_fov = clamp(target_fov, min_fov, max_fov)

	# 2. Rotación con ratón
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_y += -event.relative.x * sensitivity
			rotation_x += -event.relative.y * sensitivity
			rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
			
			rotation.y = rotation_y
			rotation.x = rotation_x

func _process(delta):
	fov = lerp(fov, target_fov, delta * zoom_smooth)

	var direction = Vector3.ZERO

	var forward_global = global_transform.basis.z
	var right_global = global_transform.basis.x

	forward_global.y = 0
	right_global.y = 0
	
	forward_global = forward_global.normalized()
	right_global = right_global.normalized()

	if Input.is_action_pressed("move_forward"):
		direction -= forward_global
	if Input.is_action_pressed("move_backward"):
		direction += forward_global
	if Input.is_action_pressed("move_left"):
		direction -= right_global
	if Input.is_action_pressed("move_right"):
		direction += right_global
	
	if direction.length() > 0:
		direction = direction.normalized()
		global_position += direction * speed * delta
	
	var vertical_move = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		vertical_move += Vector3.UP 
	if Input.is_action_pressed("move_down"):
		vertical_move += Vector3.DOWN 
	
	if vertical_move.length() > 0:
		global_position += vertical_move * speed * delta
