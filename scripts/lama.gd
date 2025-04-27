class_name Lama
extends Area2D
@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0 # seconds per shot
@export var projectile_speed: float = 500.0
@export var is_active: bool = true
@export var restriction_width_tiles: int = 6
@export var restriction_height_tiles: int = 6
@export var damage: int = 2
@export var slow_strength: int = 50
@export var slow_duration: int = 2 

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

	var target = get_closest_enemy()
	if target:
		shoot_at(target)

func get_closest_enemy() -> Node2D:
	var closest = null
	var min_dist = INF
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest

func shoot_at(target: Node2D):

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (target.global_position - global_position).normalized()
	projectile.speed = projectile_speed
	projectile.projectile_stats(damage,slow_strength,slow_duration)
	get_tree().current_scene.add_child(projectile)
