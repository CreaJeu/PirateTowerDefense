class_name Obstacle
extends StaticBody2D

@export var max_health: int = 50
var health: int

func _ready():
	health = max_health
	$ConstructionRestriction.add_to_group("obstacles")
	add_to_group("build_blocker")
	$HealthBar.setup(max_health)

func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	$HealthBar.lose_health(amount)
	if health <= 0:
		on_destroyed()

func on_destroyed():
	Signals.obstacle_destroyed.emit(global_position, 14, 4, rotation)
	queue_free()
