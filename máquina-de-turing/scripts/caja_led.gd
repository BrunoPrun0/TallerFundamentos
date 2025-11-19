extends MeshInstance3D

@onready var light_emitter: OmniLight3D = $OmniLight3D

const COLOR_ON = Color(0.892, 0.565, 0.186, 1.0) # Color de la luz 
const ENERGY_ON = 16                # Intensidad del OmniLight3D
const EMISSION_MULTIPLIER = 25.0       # Intensidad del brillo del material


var led_material: StandardMaterial3D

func _ready():
	var shared_material = get_surface_override_material(0)
	if shared_material:
		led_material = shared_material.duplicate()
		set_surface_override_material(0, led_material)
		_set_light_state(0)

func set_bit(valor: int):
	var new_state = clamp(valor, 0, 1)
	
	if led_material:
		_set_light_state(new_state)

func _set_light_state(state: int):
	if state == 1:
		
		if is_instance_valid(light_emitter):
			light_emitter.light_energy = ENERGY_ON
			light_emitter.light_color = COLOR_ON
			light_emitter.omni_range = 9.9
		
		led_material.emission_enabled = true
		led_material.emission = COLOR_ON
		led_material.emission_energy_multiplier = EMISSION_MULTIPLIER
		
	else:
		if is_instance_valid(light_emitter):
			light_emitter.light_energy = 0.0
		
		led_material.emission_enabled = false
		led_material.emission = Color.BLACK
		led_material.emission_energy_multiplier = 0.0
