extends Camera2D

@export var move_speed := 800.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.3
@export var max_zoom := 2.5

func _process(delta):
	_handle_movement(delta)
	#_handle_zoom()

func _handle_movement(delta):
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		position += direction.normalized() * move_speed * delta

func _handle_zoom():
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom = (zoom - Vector2.ONE * zoom_speed).clamp(
			Vector2.ONE * min_zoom,
			Vector2.ONE * max_zoom
		)

	if Input.is_action_just_pressed("ui_zoom_out"):
		zoom = (zoom + Vector2.ONE * zoom_speed).clamp(
			Vector2.ONE * min_zoom,
			Vector2.ONE * max_zoom
		)
