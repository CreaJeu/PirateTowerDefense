class_name Herisson
extends Area2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.2 # seconds per shot
@export var projectile_speed: float = 500.0
@export var is_active: bool = true
@export var restriction_width_tiles: int = 6
@export var restriction_height_tiles: int = 6
@export var damage = 1

var enemies_in_range: Array[Node2D] = []

@onready var fire_timer: Timer = $FiringCooldown

func _ready():
	$BuildRestriction.add_to_group("build_blocker")
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)

func get_size() -> Vector2:
	return Vector2($Sprite2D.texture.get_width(), $Sprite2D.texture.get_height())

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_body_exited(body):
	if body.is_in_group("enemies"):
		enemies_in_range.erase(body)

func _on_fire_timer_timeout():
	if enemies_in_range.is_empty() or not is_active:
		return
	projectile_animation()
	for target in enemies_in_range:
		target.hit_taken(damage)
	var rotation_tween = create_tween()
	var target_rotation = $Sprite2D.rotation + deg_to_rad(360)  # Rotate by 360 degrees
	rotation_tween.tween_property($Sprite2D, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func projectile_animation():
	var directions = [
		Vector2(0, -1),   # North
		Vector2(1, -1),   # North-East
		Vector2(1, 0),    # East
		Vector2(1, 1),    # South-East
		Vector2(0, 1),    # South
		Vector2(-1, 1),   # South-West
		Vector2(-1, 0),   # West
		Vector2(-1, -1)   # North-West
	]

	for dir in directions:
		var spike = $Epines/Sprite2D.duplicate()
		$Epines.add_child(spike)
		spike.global_position = $Sprite2D.global_position
		spike.visible = true
		
		# Make the spike point in the movement direction (+90° because original sprite faces north)
		spike.rotation = dir.angle() + deg_to_rad(90)

		var tween = create_tween()
		var target_position = spike.position + dir.normalized() * 100 # Adjust distance as needed
		tween.tween_property(spike, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# Clean up the spike after it reaches its destination
		tween.tween_callback(Callable(spike, "queue_free"))
