class_name Lama
extends StaticBody2D
@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0 # seconds per shot
@export var projectile_speed: float = 500.0
@export var is_active: bool = true
@export var restriction_width_tiles: int = 7
@export var restriction_height_tiles: int = 7
@export var damage: int = 2
@export var slow_strength: int = 50
@export var slow_duration: int = 2 
@export var max_health: int = 20

var health: int
var enemies_in_range: Array[Node2D] = []

@onready var fire_timer: Timer = $FiringCooldown

func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	health = max_health

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

func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	shake(0.15)  # Add shake effect when taking damage
	if health <= 0:
		on_destroyed()

func on_destroyed():
	Signals.obstacle_destroyed.emit(global_position, restriction_width_tiles, restriction_height_tiles, rotation)
	queue_free()

func shake(duration = 0.2, strength = 5.0):
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
