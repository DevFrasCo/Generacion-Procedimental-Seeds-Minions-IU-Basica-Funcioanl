extends CharacterBody2D

var objetive_position

var can_mark : bool = true
var speed : int = 80

var target = []
var current_state


var select : bool = false
var is_live : bool = true

@onready var label: Label = $Label

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var col: CollisionShape2D = $CollisionShape2D

@onready var states = {
	"IDLE" : $States/Idle,
	"MOVING" : $States/Walk,
	"CUTTING" : $States/Chop,
	"HURT" : $States/Hurt,
	"DEAD" : $States/Dead, # <--- animacion de "idle_special" se reproduce en algunas ocaciones REVISAR
	"ATTACK" : $States/Attack,  # testeado 5 veces y sin fallos (sin confirmar q este resuelto)
	}

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("click_left"):
		set_target_position()


func set_target_position():
	nav.target_position = get_global_mouse_position()




func _physics_process(delta: float) -> void:
	label.visible = select
	
	if current_state and current_state.has_method("update"):
		current_state.update(delta)
	
	
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var nextPathPosition: Vector2 = nav.get_next_path_position()
		velocity = global_position.direction_to(nextPathPosition) * speed
	
	
func _ready() -> void:
	_change_state("IDLE")

func _change_state(state_name: String):
	
	if not states.has(state_name):
		print("Estado no existe:", state_name)
		return

	var new_state = states[state_name]

	# evitar cambiar al mismo estado
	if current_state == new_state:
		return

	# salir del estado actual
	if current_state and current_state.has_method("exit"):
		current_state.exit()

	# cambiar al nuevo estado
	current_state = new_state

	# entrar al nuevo estado
	if current_state.has_method("enter"):
		current_state.enter({
			"woodcutter": self,
			"targets": target
		})
