extends Node

var woodcutter
var value_anim : int = randi_range(1,4)


func enter(msg = {}):
	woodcutter = msg["woodcutter"]

	if woodcutter.is_live:
		animacion_idle()
		look_around()


func exit():
	pass

func animacion_idle():
	if value_anim == 1:
		woodcutter.anim.play("idle_special")
		await woodcutter.anim.animation_finished

	woodcutter.anim.play("idle")
	await get_tree().create_timer(5).timeout
	value_anim = randf_range(1,4)
	if woodcutter.is_live:
		animacion_idle()
		look_around()

func look_around():
	if value_anim > 2:
		woodcutter.anim.flip_h = !woodcutter.anim.flip_h
