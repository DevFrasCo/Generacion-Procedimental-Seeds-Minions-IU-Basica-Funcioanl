extends Node

var woodcutter

var cut_timer = 0.0
var cut_rate = 1.2

var nav_agent
var sprite


func enter(msg = {}):

	woodcutter = msg["woodcutter"]

	nav_agent = woodcutter.get_node("NavigationAgent2D")
	sprite = woodcutter.get_node("AnimatedSprite2D")

	#print("Entré a Chop")
	#print("Objetivos:", woodcutter.target)

	cut_timer = 0


func exit():
	pass


func update(delta):
	if woodcutter.target.is_empty():
		woodcutter._change_state("IDLE")
		return

	var tree = woodcutter.target[0]

	if !is_instance_valid(tree):
		woodcutter.target.remove_at(0)
		return

	move_to_tree(tree, delta)

func move_to_tree(tree, delta):

	nav_agent.target_position = tree.global_position

	if nav_agent.is_navigation_finished():
		chop_tree(tree, delta)
		return

	var next_position = nav_agent.get_next_path_position()

	var direction = (next_position - woodcutter.global_position).normalized()

	woodcutter.velocity = direction * woodcutter.speed
	woodcutter.move_and_slide()

	# Flip del sprite
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

	if sprite.animation != "walk":
		sprite.play("walk")

func chop_tree(tree, delta):

	if sprite.animation != "cut":
		sprite.play("cut")

	cut_timer += delta

	if cut_timer >= cut_rate:

		cut_timer = 0

		if is_instance_valid(tree):

			tree.take_damage(1)


			if tree.health <= 0:


				woodcutter.target.remove_at(0)
