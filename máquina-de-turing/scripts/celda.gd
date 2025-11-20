
extends Node3D

@onready var boton_mesh: MeshInstance3D = $CajaBoton 
@onready var area_boton: Area3D = $CajaBoton/Area3D 
@onready var luz_led: MeshInstance3D = $CajaLed

var bit_state: int = 0 # 0 (apagado) o 1 (encendido)
var posicion_inicial_boton: Vector3 # posición inicial del botón
const DESPLAZAMIENTO_X = 1 # distancia que se hunde el botón (10 cm)
const TIEMPO_ANIMACION = 0.1

func _ready():
	posicion_inicial_boton = boton_mesh.position
	if area_boton:
		area_boton.input_event.connect(_on_area_input_event)

func _on_area_input_event(camera, event, pos, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_toggle_state()

func _toggle_state():
	bit_state = 1 - bit_state
	if luz_led and "set_bit" in luz_led:
		luz_led.set_bit(bit_state) # llama a la función que enciende/apaga el LED
	_animar_boton(bit_state)
	
func LDR_get_bit():
	return bit_state

func _animar_boton(new_state: int):
	var target_position: Vector3
	
	if new_state == 1:
		target_position = posicion_inicial_boton - Vector3(DESPLAZAMIENTO_X, 0, 0) 
	else:
		target_position = posicion_inicial_boton # se libera el boton
	
	var tween = create_tween()
	tween.tween_property(boton_mesh, "position", target_position, TIEMPO_ANIMACION)
	
