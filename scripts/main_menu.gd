extends Control

const OPTIONS = preload("uid://druykgxn2q42u")
var option_open = false

func _process(delta: float) -> void:
	pass
	

func _on_start_pressed() -> void:
	Gamestate.reset_all()
	visible = false

func _on_option_pressed() -> void:
	var button = $PanelContainer/VBoxContainer/Option
	button.disabled = true
	var instance = OPTIONS.instantiate()
	instance.Outside_world = button
	add_child(instance)


func _on_exit_pressed() -> void:
	get_tree().quit()
