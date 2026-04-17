extends CharacterBody2D

var select : bool = false
@onready var label: Label = $Label



func _physics_process(delta: float) -> void:
	label.visible = select
