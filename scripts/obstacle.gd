class_name Obstacle
extends StaticBody2D

@export var max_health: int = 50
var health: int

func _ready():
	health = max_health
	$ConstructionRestriction.add_to_group("obstacles")
	add_to_group("build_blocker")
	
func shake(duration = 0.2, strength = 5.0):
	# Store the original position
	var original_position = position

	# Create a new tween
	var tween = $Sprite2D.create_tween()
	tween.set_parallel(true)

	# Set up the shake effect using multiple property tweens
	for i in range(int(duration * 20)):  # 20 steps per second
		# Create random offset within the strength range
		var random_x = randf_range(-strength, strength)
		var random_y = randf_range(-strength, strength)
	# Add property tween for this step
		tween.tween_property(self, "position", original_position + Vector2(random_x, random_y), 0.05)


	# Final tween to return to original position
	tween.chain().tween_property(self, "position", original_position, 0.1)
	tween.play()


func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	shake(0.15)  # Add shake effect when taking damage
	if health <= 0:
		on_destroyed()

func on_destroyed():
	Signals.obstacle_destroyed.emit(global_position, 6, 2, rotation)
	queue_free()
