class_name HealthBar
extends Control
	
func setup(max_heath: int) -> void:
	$TextureProgressBar.max_value = max_heath

func lose_health(amount: int) -> void:
	$TextureProgressBar.value -= amount
