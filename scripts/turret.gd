class_name Turret
extends StaticBody2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0 # seconds per shot
@export var projectile_speed: float = 500.0
@export var is_active: bool = true
@export var restriction_width_tiles: int = 6
@export var restriction_height_tiles: int = 6
@export var placed: bool = false
@export var max_health: int = 20
@export var rotation_speed: float = 10.0  # How quickly the turret rotates to face enemies

var current_damage_upgrade = 1
var current_proj_speed_upgrade = 1
var current_range_upgrade = 1

var health: int
var enemies_in_range: Array[Node2D] = []

@onready var fire_timer: Timer = $FiringCooldown
@onready var upgrade_damage_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/DamageButton
@onready var upgrade_proj_speed_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/ProjSpeedButton
@onready var upgrade_range_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/RangeButton

func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$ConstructionRestriction.add_to_group("obstacles")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	if (placed):
		$Button.show()
	health = max_health
	
	upgrade_proj_speed_button.pressed.connect(upgrade_projectile_speed)
	upgrade_range_button.pressed.connect(upgrade_range)
	
	Gamestate.money_changed.connect(check_money)

	
func _process(delta):
	# Handle rotation toward target if there are enemies
	if not enemies_in_range.is_empty() and is_active:
		var target = get_closest_enemy()
		if target:
			_rotate_toward(target, delta)

func _rotate_toward(target: Node2D, delta: float):
	# Calculate the angle to the target
	var direction = (target.global_position - global_position).normalized()
	var target_angle = direction.angle() - PI/2
	
	# Get the current rotation
	var current_angle = $Sprite2D.rotation

	# Calculate the shortest rotation direction
	var angle_diff = wrapf(target_angle - current_angle, -PI, PI)

	# Apply smooth rotation
	if abs(angle_diff) > 0.01:  # Small threshold to prevent jittering
		$Sprite2D.rotation += sign(angle_diff) * min(rotation_speed * delta, abs(angle_diff))
	else:
		$Sprite2D.rotation = target_angle
			
func place():
	$Button.show()

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
	get_tree().current_scene.add_child(projectile)

func show_upgrade_menu():
	$UpgradeMenuPanel.show()
	
func hide_upgrade_menu():
	$UpgradeMenuPanel.hide()

func get_overlapping_bodies():
	return $ConstructionRestriction.get_overlapping_bodies()

func take_damage(amount: int):
	health -= amount
	shake(0.15)  # Add shake effect when taking damage
	if health <= 0:
		on_destroyed()

func on_destroyed():
	Signals.obstacle_destroyed.emit(global_position, 6, 6, rotation)
	queue_free()

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

func upgrade_range():
	if current_range_upgrade >= 5:
		upgrade_range_button.disabled = true
		print("upgrade_range maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	$FiringArea/FiringRange.shape.radius += 30
	
	current_range_upgrade += 1

func upgrade_projectile_speed():
	if current_proj_speed_upgrade >= 5:
		upgrade_proj_speed_button.disabled = true
		print("upgrade_projectile_speed maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
		
	projectile_speed += 100
	
	current_proj_speed_upgrade += 1

func check_money(current_money: int):
	if current_money < 20:
		upgrade_proj_speed_button.disabled = true
		upgrade_range_button.disabled = true
	else:
		if current_proj_speed_upgrade < 5:
			upgrade_proj_speed_button.disabled = false
		if current_range_upgrade < 5:
			upgrade_range_button.disabled = false
