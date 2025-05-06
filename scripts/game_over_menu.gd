class_name GameOverMenu
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.game_over.connect(_on_game_over)
	
func _on_game_over() -> void:
	$"../GameOverMenu".visible = true
	get_tree().paused = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	Gamestate.reset_all()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
