extends Node

var woodcutter

func enter(msg = {}):
	woodcutter = msg["woodcutter"]

	woodcutter.is_live = false
	dead()


func exit():
	pass

func dead():
	woodcutter.col.disabled = true
	woodcutter.anim.play("dead")
	await get_tree().create_timer(3).timeout
	woodcutter.queue_free()
