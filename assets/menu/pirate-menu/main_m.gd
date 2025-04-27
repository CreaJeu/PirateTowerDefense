extends Node2D

const OPTIONS = preload("uid://druykgxn2q42u")
var option_open = false

func _on_option_pressed() -> void:
	$Option.disabled = true
	var instance = OPTIONS.instantiate()
	instance.Outside_world = $Option
	add_child(instance)
	
	pass # Replace with function body.
	
func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
