extends Node3D

signal mode_changed(is_suma_mode: bool)

var is_suma_mode: bool = false
const ROTATION_DURATION: float = 0.25
const RESTA_ROTATION: Vector3 = Vector3(-40,0,0) # pos inicial (resta)
const SUMA_ROTATION: Vector3 = Vector3(50,0,0) # rotación de 90 grados en el eje x (suma)

@onready var parent_area: Area3D = get_parent().get_parent() as Area3D

func _ready():
	if parent_area:
		parent_area.input_event.connect(_on_area_input_event)
	rotation_degrees = RESTA_ROTATION

func _on_area_input_event(camera, event, pos, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_toggle_switch()

func _toggle_switch():
	is_suma_mode = !is_suma_mode
	
	var target_rotation = SUMA_ROTATION if is_suma_mode else RESTA_ROTATION
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", target_rotation, ROTATION_DURATION)
	mode_changed.emit(is_suma_mode)
