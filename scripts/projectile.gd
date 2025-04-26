class_name Projectile
extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0 # seconds before auto-destroy
var direction: Vector2 = Vector2.ZERO

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
		body.die()
		queue_free()
