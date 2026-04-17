extends Node2D

signal ref_unidades_selec

signal unidades_seleccionadas(cantidad)

signal ejecutar_accion()

@onready var selection_area: Area2D = $"../SelectionArea"
@onready var collision_shape_2d: CollisionShape2D = $"../SelectionArea/CollisionShape2D"

var selectionStarPoint = Vector2.ZERO
var can_select : bool = false

var grupo_actual = null
var objetivos_grupo = null

var is_prop : bool = false

var objetivo_rts = null

var selected_units : Array = []

var esperando_objetivo : bool

var minions_seleccionados = []

var objetivos_minions = []

var accion_actual : String

func _input(event): # <-- Input de Clik
	if can_select:
		if (selectionStarPoint == Vector2.ZERO && event is InputEventMouseButton
			 && event.button_index == 1 && event.is_pressed()):
				selectionStarPoint = get_global_mouse_position()
		elif (selectionStarPoint != Vector2.ZERO && event is InputEventMouseButton
			 && event.button_index == 1):
				select_objects()
				selectionStarPoint = Vector2.ZERO

func _physics_process(delta):
	queue_redraw()

func _draw(): # <-- dibuja el rectangulo
	if selectionStarPoint == Vector2.ZERO: return
	
	var mousePostition = get_global_mouse_position()
	var startX = selectionStarPoint.x
	var startY = selectionStarPoint.y
	var endX = mousePostition.x
	var endY = mousePostition.y
	
	var lineWidht  = 3.0
	var lineColor = Color.DARK_RED
	
	draw_line(Vector2(startX, startY),Vector2(endX,startY),lineColor,lineWidht)
	draw_line(Vector2(startX, startY),Vector2(startX,endY),lineColor,lineWidht)
	draw_line(Vector2(endX, startY),Vector2(endX,endY),lineColor,lineWidht)
	draw_line(Vector2(startX, endY),Vector2(endX,endY),lineColor,lineWidht)

func select_objects(): # <-- Selecion de prop + categoria (tree, bush, etc)
	#region valores post seleccion
	var size = abs(get_global_mouse_position() - selectionStarPoint)

	var areaPosition = _get_rect_star_position()
	selection_area.global_position = areaPosition
	collision_shape_2d.global_position = areaPosition + size / 2
	collision_shape_2d.shape.size = size

	await get_tree().create_timer(0.04).timeout

	var overlapping = selection_area.get_overlapping_bodies()
	#endregion
	selected_units.clear()
	objetivos_minions.clear()

	if not esperando_objetivo:
		minions_seleccionados.clear()

	# Determinar qué grupo vamos a buscar
	if is_prop:
		objetivo_rts = objetivos_grupo
	else:
		objetivo_rts = grupo_actual

	# Limpiar selección anterior
	for body in get_tree().get_nodes_in_group(objetivo_rts):
		body.select = false

	# Revisar lo que está dentro del rectángulo
	for body in overlapping:

		if body.is_in_group(objetivo_rts):

			body.select = true
			selected_units.append(body)

			# Guardar referencias reales
			if is_prop:
				objetivos_minions.append(body)
			else:
				minions_seleccionados.append(body)

	actualizar_seleccion(selected_units)

	# Ejecutar acción si estamos esperando objetivo
	if esperando_objetivo and objetivos_minions.size() > 0:

		esperando_objetivo = false

		emit_signal(
			"ejecutar_accion",
			minions_seleccionados,
			objetivos_minions,
			accion_actual,
			esperando_objetivo
		)
		can_select = false

func actualizar_seleccion(ab):
	emit_signal("unidades_seleccionadas", ab)

func _get_rect_star_position():
	var newPosition = Vector2()             
	var mousePosition = get_global_mouse_position()
	
	if selectionStarPoint.x < mousePosition.x:
		newPosition.x = selectionStarPoint.x
	else:
		newPosition.x = mousePosition.x
	
	if selectionStarPoint.y < mousePosition.y:
		newPosition.y = selectionStarPoint.y
	else:
		newPosition.y = mousePosition.y
	
	return newPosition


func _on_select_units_pressed() -> void:
	
	minions_seleccionados.clear()
	selected_units.clear()
	objetivos_minions.clear()
	
	
	if can_select == true:
		can_select = false
		is_prop = false
	else:
		can_select = true


func _GuardarReferenciasMinions(minion_selec) -> void:
	grupo_actual = minion_selec
	

func _on_inspector_menu_activar_rts(objetives , ac , valor_bool) -> void:
	objetivos_grupo = objetives
	is_prop = true
	can_select = true
	esperando_objetivo = valor_bool
	accion_actual = ac


func _on_inspector_menu_marcar_position() -> void:
	emit_signal("ref_unidades_selec", selected_units, esperando_objetivo)
	
