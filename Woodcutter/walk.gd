extends Node

var woodcutter


func enter(msg = {}):
	woodcutter = msg["woodcutter"]

func exit():
	pass




func go_to_point():
	if not woodcutter.nav.target_position or woodcutter.nav.is_navigation_finished():
		woodcutter.velocity = Vector2.ZERO
	else:
		var nextPathPosition: Vector2 = woodcutter.nav.get_next_path_position()
		woodcutter.velocity = woodcutter.global_position.direction_to(nextPathPosition) * woodcutter.speed
