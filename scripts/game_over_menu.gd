class_name GameOverMenu
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.game_over.connect(_on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_game_over() -> void:
	$"../GameOverMenu".visible = true
	get_tree().paused = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()
