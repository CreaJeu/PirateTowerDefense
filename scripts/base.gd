class_name Base
extends Area2D

@export var max_health = 100
var health: int

func _ready():
	health = max_health
	Signals.base_take_damage.connect(take_damage)
	connect("body_entered", self._on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.enemy_hit_base.emit()


func take_damage(amount: int):
	health -= amount
	print("Base HP:", health)
	if health <= 0:
		on_base_destroyed()

func on_base_destroyed():
	print("Base destroyed! Game over!")
	Signals.game_over.emit()
