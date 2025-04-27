class_name Herisson
extends StaticBody2D

@export var fire_rate: float = 0.2 # seconds per shot
@export var is_active: bool = true
@export var restriction_width_tiles: int = 6
@export var restriction_height_tiles: int = 6
@export var placed: bool = false
@export var damage = 1
@export var max_health: int = 20

var current_hp_upgrade = 1
var current_attack_speed_upgrade = 1
var current_range_upgrade = 1
var current_herisson_level = 1

var health: int
var enemies_in_range: Array[Node2D] = []

@onready var fire_timer: Timer = $FiringCooldown
@onready var upgrade_attack_speed_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/AttackSpeedButton
@onready var upgrade_range_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/RangeButton
@onready var upgrade_hp_button: Button = $UpgradeMenuPanel/MarginContainer/GridContainer/HPButton


func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	health = max_health
		
	if (placed):
		$Button.show()

	upgrade_attack_speed_button.pressed.connect(upgrade_attack_speed)
	upgrade_range_button.pressed.connect(upgrade_range)
	upgrade_hp_button.pressed.connect(upgrade_hp)

	Gamestate.money_changed.connect(check_money)

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


func show_upgrade_menu():
	$UpgradeMenuPanel.show()
	
func hide_upgrade_menu():
	$UpgradeMenuPanel.hide()

func upgrade_hp():
	if current_hp_upgrade >= 5:
		upgrade_hp_button.disabled = true
		print("current_hp_upgrade maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	health += 10
	max_health += 10
	
	current_hp_upgrade += 1
	check_herisson_level()

func upgrade_range():
	if current_range_upgrade >= 5:
		upgrade_range_button.disabled = true
		print("upgrade_range maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	$FiringArea/FiringRange.shape.radius += 10
	
	current_range_upgrade += 1
	check_herisson_level()

func upgrade_attack_speed():
	if current_attack_speed_upgrade >= 5:
		upgrade_attack_speed_button.disabled = true
		print("current_attack_speed_upgrade maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
		
	fire_rate -= 0.03
	
	current_attack_speed_upgrade += 1
	check_herisson_level()

func check_money(current_money: int):
	if current_money < 20:
		upgrade_attack_speed_button.disabled = true
		upgrade_range_button.disabled = true
		upgrade_hp_button.disabled = true
	else:
		if current_attack_speed_upgrade < 5:
			upgrade_attack_speed_button.disabled = false
		if current_range_upgrade < 5:
			upgrade_range_button.disabled = false
		if current_hp_upgrade < 5:
			upgrade_hp_button.disabled = false

func check_herisson_level():
	if current_herisson_level >= 4:
		return
		
	var total_level = current_attack_speed_upgrade + current_hp_upgrade + current_range_upgrade
	if total_level < current_herisson_level*5:
		return
		
	current_herisson_level += 1
	if current_herisson_level == 1:
		$Sprite2D.texture = load("res://assets/sprites/structure/herisson.png")
	elif current_herisson_level == 2:
		$Sprite2D.texture = load("res://assets/sprites/structure/herissonUpgrade1.png")
	elif current_herisson_level == 3:
		$Sprite2D.texture = load("res://assets/sprites/structure/herissonUpgrade2.png")
	elif current_herisson_level == 4:
		$Sprite2D.texture = load("res://assets/sprites/structure/herissonUpgrade3.png")
		
	
