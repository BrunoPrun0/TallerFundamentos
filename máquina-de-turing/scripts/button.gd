extends MeshInstance3D


signal turing_button_pressed
@export var click_distance: float = 0.5
@export var animation_time: float = 0.1 

var is_ready: bool = false
var original_position: Vector3 

func _ready():
	var area_node = get_parent().get_parent() 
	if area_node is Area3D:
		area_node.input_event.connect(_on_area_input_event)
	original_position = position
	is_ready = true

func _on_area_input_event(camera, event, pos, normal, shape_idx):
	if is_ready and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_press_button()

func _press_button():
	var target_position = original_position - Vector3(0, click_distance, 0) 
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, animation_time)
	tween.tween_interval(0.05) 
	tween.tween_property(self, "position", original_position, animation_time * 2.0)
	turing_button_pressed.emit()
