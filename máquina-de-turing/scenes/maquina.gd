# maquina_de_turing.gd
extends Node3D

# --- PROPIEDADES ---
const CELDA_SCENE = preload("res://scenes/celda.tscn")
const NUMERO_CELDAS = 21

# Ajusta esta distancia según el tamaño de tu celda
# Si la celda es de 1.0 en el eje Z, usa 1.2 para un pequeño espacio.
const ESPACIO_ENTRE_CELDAS = 10.01

var cinta: Array[Node3D] = []

func _ready():
	print("El script de la Maquina de Turing se está ejecutando.") # Paso 1
	_generar_cinta()
	print("Función _generar_cinta() terminada. Se crearon ", cinta.size(), " celdas.") # Paso 2

func _generar_cinta():
	# --- PASO CLAVE: OBTENER POSICIÓN BASE ---
	
	# Suponemos que la celda que colocaste manualmente es el primer hijo o un nodo llamado "CeldaReferencia"
	# Si la posición 0,0,76.12 es la posición del padre, podemos usar esos valores directamente.
	
	# La posición inicial (base de la estructura)
	const BASE_X = 0.0
	const BASE_Y = 0.0
	const BASE_Z_INICIO = 76.12 # Este es el Z inicial, justo al lado de la estructura.

	for i in range(NUMERO_CELDAS):
		var nueva_celda = CELDA_SCENE.instantiate()
		
		# 1. Calcular la nueva posición Z
		# Z Negativo: El valor de Z disminuye con cada celda.
		# Z_final = BASE_Z_INICIO - (índice * espaciado)
		var pos_z = BASE_Z_INICIO - (float(i) * ESPACIO_ENTRE_CELDAS)
		
		# 2. Aplicar la posición
		nueva_celda.position = Vector3(BASE_X, BASE_Y, pos_z)
		
		# 3. Añadir a la escena y referenciar
		add_child(nueva_celda)
		cinta.append(nueva_celda)
		
	print(NUMERO_CELDAS, " celdas generadas a lo largo del eje Z negativo.")
