extends StaticBody2D

var health : int = 3


var select : bool = false
@onready var label: Label = $Label


func _ready() -> void:
	$NavigationObstacle2D.avoidance_enabled = true


func _physics_process(delta: float) -> void:
	label.visible = select





func take_damage(dmg):

	health -= dmg

	if health <= 0:
		queue_free()
