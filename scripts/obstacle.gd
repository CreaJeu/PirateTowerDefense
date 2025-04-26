class_name Obstacle
extends StaticBody2D

@export var max_health: int = 50
var health: int

@onready var tween = $Tween  # Assuming you've added a Tween node as a child of the obstacle.

func _ready():
	health = max_health
	$ConstructionRestriction.add_to_group("obstacles")
	add_to_group("build_blocker")
	$HealthBar.setup(max_health)

# Call this to shake the barricade
func shake():
	# Shake effect: move left and right a little
	tween.tween_property(self, "position", position + Vector2(-10, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
	tween.tween_property(self, "position", position + Vector2(10, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	tween.tween_property(self, "position", position + Vector2(-5, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	tween.tween_property(self, "position", position + Vector2(5, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.3)

func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	$HealthBar.lose_health(amount)
	shake()  # Add shake effect when taking damage
	if health <= 0:
		on_destroyed()

func on_destroyed():
	Signals.obstacle_destroyed.emit(global_position, 6, 2, rotation)
	queue_free()
