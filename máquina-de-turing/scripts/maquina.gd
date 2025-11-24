extends Node3D


const CELDA_SCENE = preload("res://scenes/celda.tscn")
const NUMERO_CELDAS = 21
const ESPACIO_ENTRE_CELDAS = 10.01
var cinta: Array[Node3D] = []

# para controlar la velocidad de ejecución
var timer: Timer 

@export var modo_suma: bool = false # controlado por palanca
@export var velocidad_paso: float = 0.6 # pausa entre celdas
@onready var cabezal: Node3D = $Cabezal 
@onready var solenoide_mesh: Node3D = $Cabezal/SolenoideDentro 
@onready var boton_reiniciar: Node3D = $BotonReiniciar/button/buttonbutton
@onready var boton_iniciar: Node3D = $BotonIniciar/button/buttonbutton
@onready var switch_palanca = $Palanca/base/switch
const DESPLAZAMIENTO_SOLENOIDE_X = 4  # Distancia que se mueve el solenoide (ej. 10 cm)
const TIEMPO_ACCION_SOLENOIDE = 0.05    # Tiempo rápido para simular la acción

@onready var motor_engranaje1: Node3D = $MotorEngranaje1 
@onready var motor_engranaje2: Node3D = $MotorEngranaje2
const ENGRANAJE_ROTATION_FACTOR: float = 360.0 / (ESPACIO_ENTRE_CELDAS * 4)

var estado_actual: String = "Q0"
var indice_cabezal: int = 0 

# [Valor, Movimiento, Siguiente_Estado], el valor es el que debe estar en la celda; revisar si es distinto del puesto y actuar.
const SUMA = {
	"Q0": {"0": ["0", "R", "Q0"], "1": ["1", "R", "Q1"]},
	"Q1": {"0": ["0", "R", "Q2"], "1": ["1", "R", "Q1"]},
	"Q2": {"0": ["1", "R", "Q3"], "1": ["1", "L", "Q2"]},
	"Q3": {"0": ["0", "L", "Q4"], "1": ["1", "R", "Q3"]},
	"Q4": {"0": ["0", "N", "QF"], "1": ["0", "R", "QF"]},
	"QF": {"0": ["X", "X", "X"],  "1": ["X", "X", "X"]}
} 
const RESTA = {
	"Q0": {"0": ["0", "R", "Q0"], "1": ["1", "R", "Q1"]},
	"Q1": {"0": ["0", "R", "Q2"], "1": ["1", "R", "Q1"]},
	"Q2": {"0": ["0", "L", "Q3"], "1": ["1", "R", "Q2"]},
	"Q3": {"0": ["0", "N", "QF"], "1": ["0", "L", "Q4"]},
	"Q4": {"0": ["0", "L", "Q5"], "1": ["1", "L", "Q4"]},
	"Q5": {"0": ["0", "R", "Q6"], "1": ["1", "L", "Q5"]},
	"Q6": {"0": ["0", "R", "Q6"], "1": ["0", "R", "Q0"]},
	"QF": {"0": ["X", "X", "X"],  "1": ["X", "X", "X"]}
}

func _ready():
	_generar_cinta()
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_ejecutar_paso)	
	if boton_reiniciar:
		boton_reiniciar.turing_button_pressed.connect(_on_boton_reiniciar_pressed)
	if boton_iniciar:
		boton_iniciar.turing_button_pressed.connect(_on_boton_iniciar_pressed)
	if switch_palanca:
		switch_palanca.mode_changed.connect(_on_switch_palanca_mode_changed)
		
func _on_boton_reiniciar_pressed():
	print("--- REINICIANDO MÁQUINA ---")
	timer.stop() 
	for celda in cinta:
		if celda.has_method("LDR_get_bit"):
			if celda.LDR_get_bit() == 1:
				celda._toggle_state()

	indice_cabezal = 0
	if cinta.size() > 0:
		var pos_inicio = cinta[0].global_position
		cabezal.global_position = Vector3(cabezal.global_position.x, cabezal.global_position.y, pos_inicio.z)
	estado_actual = "Q0"
	print("Reinicialización completa. Máquina lista en Q0.")

func _on_boton_iniciar_pressed():
	if estado_actual != "QF":
		print("--- INICIANDO PROCESO ---")
		if cinta.size() > 0:
			iniciar_maquina()
	else:
		print("La máquina ya terminó (QF). Presiona REINICIAR primero.")

func iniciar_maquina():
	print("Máquina de Turing iniciada.")
	estado_actual = "Q0"
	indice_cabezal = 0
	timer.start(velocidad_paso)
	
func _on_switch_palanca_mode_changed(is_suma_mode_from_switch: bool):
	modo_suma = is_suma_mode_from_switch
	print("Máquina de Turing: Modo de operación actualizado a 'Suma':", modo_suma)

func _ejecutar_paso():
	if estado_actual == "QF" or indice_cabezal < 0 or indice_cabezal >= cinta.size():
		print("Máquina detenida. Estado final alcanzado o fuera de límites.")
		timer.stop()
		return

	var celda_actual = cinta[indice_cabezal]
	var valor_leido = _leer_estado_celda(celda_actual)
	
	var tabla = SUMA if modo_suma else RESTA
	var accion = tabla[estado_actual][str(valor_leido)] # El valor leído es 0 o 1

	var nuevo_valor = accion[0]
	var movimiento = accion[1]
	var siguiente_estado = accion[2]

	print("Estado:", estado_actual, " | Leído:", valor_leido, " | Acción:", accion)

	_escribir_valor_celda(celda_actual, nuevo_valor)

	_mover_cabezal(movimiento)
	
	estado_actual = siguiente_estado
	
	timer.start(velocidad_paso)


func _leer_estado_celda(celda: Node3D) -> int:
	if celda.has_method("LDR_get_bit"): 
		return celda.LDR_get_bit()
	return celda.bit_state if "bit_state" in celda else 0 

func _escribir_valor_celda(celda: Node3D, valor: String):
	if valor == "0" or valor == "1":
		var nuevo_bit = int(valor)
		if celda.LDR_get_bit() != nuevo_bit:
			celda._toggle_state()
			_animar_solenoide()
			
			
func _mover_cabezal(movimiento: String):
	match movimiento:
		"R":
			indice_cabezal += 1
		"L":
			indice_cabezal -= 1
		"N":
			pass 

	if indice_cabezal >= 0 and indice_cabezal < cinta.size():
		var target_celda = cinta[indice_cabezal]
		var target_position = target_celda.global_position
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		
		tween.tween_property(cabezal, "global_position", 
							 Vector3(cabezal.global_position.x, cabezal.global_position.y, target_position.z), 
							 velocidad_paso * 0.9)
		
		if movimiento != "N": 
			var direccion_movimiento: float
			if movimiento == "R":
				direccion_movimiento = -1.0 
			elif movimiento == "L":
				direccion_movimiento = 1.0 

			var rotacion_delta = ENGRANAJE_ROTATION_FACTOR * direccion_movimiento * 3
			tween.parallel()
			if motor_engranaje1:
				var current_rot_x1 = motor_engranaje1.rotation_degrees.x
				var target_rot_x1 = current_rot_x1 + rotacion_delta
				tween.tween_property(motor_engranaje1, "rotation_degrees:x", target_rot_x1, velocidad_paso * 0.5)
			
			if motor_engranaje2:
				var current_rot_x2 = motor_engranaje2.rotation_degrees.x
				var target_rot_x2 = current_rot_x2 + rotacion_delta
				tween.tween_property(motor_engranaje2, "rotation_degrees:x", target_rot_x2, velocidad_paso * 0.5)



func _generar_cinta():
	const BASE_X = 0.0
	const BASE_Y = 0.0
	const BASE_Z_INICIO = 76.12 # posición en z de primera celda

	for i in range(NUMERO_CELDAS):
		var nueva_celda = CELDA_SCENE.instantiate()
		
		var pos_z = BASE_Z_INICIO - (float(i) * ESPACIO_ENTRE_CELDAS)
		nueva_celda.position = Vector3(BASE_X, BASE_Y, pos_z)
		add_child(nueva_celda)
		cinta.append(nueva_celda)
		
func _animar_solenoide():
	var pos_base = solenoide_mesh.position
	var pos_accion = pos_base - Vector3(DESPLAZAMIENTO_SOLENOIDE_X, 0, 0)
	var tween = create_tween()
	tween.tween_property(solenoide_mesh, "position", pos_accion, TIEMPO_ACCION_SOLENOIDE)
	tween.tween_interval(0.01)
	tween.tween_property(solenoide_mesh, "position", pos_base, TIEMPO_ACCION_SOLENOIDE)
		
	
	
