class_name Bave
extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0 # seconds before auto-destroy
var direction: Vector2 = Vector2.ZERO
var damage: int = 2
var slow_strength: int = 50
var slow_duration: int = 2



func _ready():
	connect("body_entered", _on_body_entered)
	
	# Start a timer to auto-destroy after `lifetime` seconds
	await get_tree().create_timer(lifetime).timeout
	if self.is_inside_tree():
		queue_free()

func _process(delta):
	global_position += direction * speed * delta
	rotation_degrees += 10
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.hit_taken(damage,slow_strength,slow_duration)
		queue_free()

func projectile_stats(damage_param,slow_strength_param,slow_duration_param):
	damage = damage_param
	slow_strength = slow_strength_param
	slow_duration = slow_duration_param
