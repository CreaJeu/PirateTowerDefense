class_name Obstacle
extends StaticBody2D

@export var max_health: int = 50
var health: int

func _ready():
	health = max_health
	$ConstructionRestriction.add_to_group("obstacles")
	add_to_group("build_blocker")

func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	print("Obstacle HP:", health)
	if health <= 0:
		on_destroyed()

func on_destroyed():
	queue_free()
