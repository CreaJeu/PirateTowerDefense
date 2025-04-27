extends Control

var Outside_world

func _ready():
	add_window_option()
	$"Leave?".visible = false
	var dB = 20 * log(50/100.0)
	for v in range(0,2):
		AudioServer.set_bus_volume_db(v,dB)
		
func sound_gestion(BusNumber, value):
	var factor = value/100
	var dB = 20 * log(factor)
	AudioServer.set_bus_volume_db(BusNumber,dB)
		
# General volume
func _on_volume_value_changed(value: float) -> void:
	sound_gestion(0, value)
# Mute general 
func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)

# Volume Music
func _on_volume_music_value_changed(value: float) -> void:
	sound_gestion(1, value)
# Mute Music 
func _on_mute_music_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(1,toggled_on)
	
# Volume Sounds
func _on_volume_sounds_value_changed(value: float) -> void:
	sound_gestion(2, value)
# Mute Sounds
func _on_mute_sounds_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(2,toggled_on)
	
# Close Settings
func _on_close_pressed() -> void:
	if Outside_world:
		Outside_world.disabled = false
	queue_free()

func _on_exit_pressed() -> void:
	$"Leave?".visible = true

func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	$"Leave?".visible = false
	
const WINDOW_MODE_ARRAY : Array[String] = [
	"Full-Screen",
	"Window Mode",
	"Borderless Window"
]

func add_window_option():
	for window_mode in WINDOW_MODE_ARRAY:
		%WindowOptions.add_item(window_mode)
		
func on_window_mode_selected(index : int):
	match index:
		0: 	
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
			return
		1: 	
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
			return
		2: 	
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
			return


func _on_window_options_item_selected(index: int) -> void:
	on_window_mode_selected(index)
