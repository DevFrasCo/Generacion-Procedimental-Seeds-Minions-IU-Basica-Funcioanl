extends Control

signal marcar_position

signal accion_seleccionada

signal TipoDeMinion(data_minions)

signal  activar_rts

signal desactivar_rts

var valor_bool : bool

var icons_principales = [
	preload("res://Assets/IU/Icons/Trops/Icon_Lumber.png"), # <- 0
	preload("res://Assets/IU/Icons/Trops/Icon_Miner.png"), # <- 1
	preload("res://Assets/IU/Icons/Trops/Icon_Hunter.png"), # <- 2
	preload("res://Assets/IU/Icons/Trops/Icon_Farmer.png"), # <- 3
	preload("res://Assets/IU/Icons/Trops/Icon_Collector.png") # <- 4 ...
]

var icons_acciones = [
	preload("res://Assets/IU/Icons/Icon_Chop.png"), #
	preload("res://Assets/IU/Icons/Icon_MoveTrops.png"), #
	preload("res://Assets/IU/Icons/Icon_Attack.png"), #
	preload("res://Assets/IU/Icons/Icon_Bow.png"), #
	preload("res://Assets/IU/Icons/Icon_Picaxe.png"),#
	preload("res://Assets/IU/Icons/Icon_Shovel.png"),#
	preload("res://Assets/IU/Icons/Icon_Plant.png"),#
	preload("res://Assets/IU/Icons/Icon_gather.png") #
]

var icons_ui = [
	preload("res://Assets/IU/Icons/Icon_Back.png"),
	preload("res://Assets/IU/Icons/Icon_Cancel.png"),
	preload("res://Assets/IU/Icons/Icon_Accept.png"),
	preload("res://Assets/IU/Icons/Trops/Icon_BackCollector.png"), # <- Iconos "Back" (3)
	preload("res://Assets/IU/Icons/Trops/Icon_BackFarmer.png"), # <-(4)
	preload("res://Assets/IU/Icons/Trops/Icon_BackHunter.png"),# <-(5)
	preload("res://Assets/IU/Icons/Trops/Icon_BackLumber.png"),# <-(6)
	preload("res://Assets/IU/Icons/Trops/Icon_BackMiner.png")# <-(7)
]

var data_minions = {
	"Button_Lumber": {
		"group": "LumberJacks",
		"main_icon": icons_ui[6],
		"acciones": [
			{ "icon": icons_acciones[0], "estado": "CUTTING", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Trees"},
			{ "icon": icons_acciones[2], "estado": "ATTACK", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Enemies"},
			{ "icon": icons_acciones[1], "estado": "MOVING", "enabled": true, "requiere_objetivo": false, "requiere_posicion": true, "objetivo": null}
		]
	},
	"Button_Collector": {
		"group": "Collector",
		"main_icon": icons_ui[3],
		"acciones": [
			{ "icon": icons_acciones[7], "estado": "COLLECTING", "enabled": true, "requiere_objetivo": false,"requiere_posicion": false, "objetivo": null },
			{ "icon": icons_acciones[1], "estado": "MOVING", "enabled": true, "requiere_objetivo": false,"requiere_posicion": true, "objetivo": null },
			{ "icon": icons_ui[1], "estado": null, "enabled": false , "requiere_objetivo": false, "requiere_posicion": false, "objetivo": null} # X roja / deshabilitada
		]
	},
	"Button_Hunter": {
		"group": "Hunter",
		"main_icon": icons_ui[5],
		"acciones": [
			{ "icon": icons_acciones[3], "estado": "HUNTING", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Animals"},
			{ "icon": icons_acciones[2], "estado": "ATTACK", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Enemies"},
			{ "icon": icons_acciones[1], "estado": "MOVING", "enabled": true, "requiere_objetivo": false, "requiere_posicion": true, "objetivo": null}
		]
	},
	"Button_Miner": {
		"group": "Miner",
		"main_icon": icons_ui[7],
		"acciones": [
			{ "icon": icons_acciones[4], "estado": "MINING", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Rocks"},
			{ "icon": icons_acciones[2], "estado": "ATTACK", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Enemies"},
			{ "icon": icons_acciones[1], "estado": "MOVING", "enabled": true, "requiere_objetivo": false, "requiere_posicion": true, "objetivo": null}
		]
	},
	"Button_Farmer": {
		"group": "Farmer",
		"main_icon": icons_ui[4],
		"acciones": [
			{ "icon": icons_acciones[6], "estado": "PLANTING", "enabled": true, "requiere_objetivo": false, "requiere_posicion": false, "objetivo": null},
			{ "icon": icons_acciones[5], "estado": "PLOWING", "enabled": true, "requiere_objetivo": true, "requiere_posicion": false, "objetivo": "Cultive"},
			{ "icon": icons_acciones[1], "estado": "MOVING", "enabled": true, "requiere_objetivo": false, "requiere_posicion": true, "objetivo": null}
		]
	}
}

var objetives_minion : Array = []

var minion_actual = null

@export var tipo_minion : String

var boton_actual: Button = null

var botones_principales: Array[Button] = []

var botones_accion: Array[Button] = []

var position_to_move = Vector2(24 , -128)
var original_positions := {}
var original_icon :={}
@onready var principal_buttons = $PrincipalButtons
@onready var action_container: Control = $Buttons_Actions

@onready var ac_1: Button = $Buttons_Actions/Action_1
@onready var ac_2: Button = $Buttons_Actions/Action_2
@onready var ac_3: Button = $Buttons_Actions/Action_3

var accion_actual

var esperando_objetivo : bool = false

@onready var botones = [ac_1, ac_2, ac_3]
var acciones_actuales = []


func _ready() -> void:
	for boton in principal_buttons.get_children():
		if boton is Button:
			botones_principales.append(boton)
			boton.pressed.connect(_on_principal_pressed.bind(boton))
			
	botones_accion = [$Buttons_Actions/Action_1, $Buttons_Actions/Action_2, $Buttons_Actions/Action_3,
	$Buttons_Actions/Select_Units]


	for i in botones.size():
		botones[i].pressed.connect(_on_accion_pressed.bind(i))


func _on_principal_pressed(boton: Button): # <- Botones Principales
	#print("Se presionó:", boton.name)
	
	if not original_icon.has(boton):
		original_icon[boton] = boton.icon
	
	if not original_positions.has(boton):
		original_positions[boton] = boton.global_position
	
	# Si presiona el mismo → volver atrás
	if boton_actual == boton:
		valor_bool = true

		volver_estado_base(boton_actual)
		return

	boton_actual = boton

	# Ocultar los otros principales
	for b in botones_principales:
		b.visible = (b == boton)


	definir_icons(boton_actual)

	move_buttons_left(boton_actual) # <- Mover izquierda

	mostrar_acciones() # <- Mostrar acciones
	
	colocar_acciones_al_lado(boton) # <- Botones de Acciones

func volver_estado_base(boton_presionado):
	boton_presionado.icon = original_icon[boton_presionado]
	boton_actual = null

	for b in botones_principales:
		b.visible = true

	ocultar_acciones()
	move_buttons_back(boton_presionado)

func mostrar_acciones():
	for b in botones_accion:
		b.visible = true

func ocultar_acciones():
	for b in botones_accion:
		b.visible = false


func colocar_acciones_al_lado(boton: Button): #  <- Acciones a un lado

	# Posición global del botón
	var boton_pos = boton.global_position
	var boton_size = boton.size

	# Colocar a la derecha
	action_container.global_position = Vector2(
		boton_pos.x + boton_size.x - 10,
		boton_pos.y + 20
	)

func move_buttons_left(boton_presionado): # <- Acciones movidas a la izquierda
	boton_presionado.position = Vector2(24, -128)

func move_buttons_back(boton_presionado): # <- Restableccer Pocision
	if original_positions.has(boton_presionado):
		boton_presionado.global_position = original_positions[boton_presionado]

func definir_icons(boton_presionado): # aqui señal import
	
	var nombre = boton_presionado.name
	if not data_minions.has(nombre):
		return
	
	var data = data_minions[nombre]
	
	_on_minion_seleccionado(nombre)
	
	emit_signal("TipoDeMinion" , data["group"]) # <-- Referencias enviados a RTS
	
	boton_presionado.icon = data["main_icon"]


	var acciones = data["acciones"]


	ac_1.icon = acciones[0]["icon"]
	ac_2.icon = acciones[1]["icon"]
	ac_3.icon = acciones[2]["icon"]


func _on_accion_pressed(index: int): # <- envio para ac.estado WARNING

	if index >= acciones_actuales.size():
		return

	var accion = acciones_actuales[index]
	accion_actual = accion["estado"]

	# 🔥 CASO 1: requiere objetivo (props)
	if accion["requiere_objetivo"]:
		esperando_objetivo = true


		emit_signal(
		"activar_rts",
		accion["objetivo"],
		accion_actual,
		true
		)

	# 🔥 CASO 2: requiere posición (MOVING)
	elif accion.get("requiere_posicion", false):
		esperando_objetivo = false
		emit_signal("marcar_position")
		#hab_marcar_position(accion_actual)

	# 🔥 CASO 3: acción directa
	else:
		ejecutar_accion_directa(accion_actual)

func ejecutar_accion_directa(ac):
	print(ac)


func hab_marcar_posicion(minions, valor_bool):

	if !valor_bool:
		for minion in minions:
			minion.can_mark = true


func ejecutar_accion_con_referencias(minions, objetivos, accion, valor_bool):
	esperando_objetivo = valor_bool

	#print("Objetivos desde RTS:", objetivos) # <- test print

	for minion in minions:

		if is_instance_valid(minion):

			minion.target.clear()
			minion.target = objetivos.duplicate()

			minion._change_state(accion)


func _on_minion_seleccionado(nombre):

	if not data_minions.has(nombre):
		return

	minion_actual = nombre
	acciones_actuales = data_minions[nombre]["acciones"]

	configurar_botones()

func configurar_botones():

	for i in botones.size():

		if i < acciones_actuales.size():

			var accion = acciones_actuales[i]

			botones[i].visible = true
			botones[i].icon = accion["icon"]

			# Empiezan deshabilitados
			botones[i].disabled = true

		else:
			botones[i].visible = false

func _on_unidades_seleccionadas(unidades):

	var hay_unidades = unidades.size() > 0
	actualizar_estado_botones(hay_unidades)

func actualizar_estado_botones(hay_unidades):

	for i in botones.size():

		if i >= acciones_actuales.size():
			continue

		var accion = acciones_actuales[i]

		if accion["enabled"] and hay_unidades:
			botones[i].disabled = false
		else:
			botones[i].disabled = true
