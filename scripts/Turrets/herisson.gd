extends Turret
class_name Herisson

var damage = 1

var current_hp_upgrade = 1
var current_attack_speed_upgrade = 1
var current_range_upgrade = 1
var current_herisson_level = 1

@onready var upgrade_attack_speed_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/AttackSpeedButton
@onready var upgrade_range_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/RangeButton
@onready var upgrade_hp_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/HPButton


func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	fire_rate = 0.2
	projectile_scene = null
	
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
		var target_position = spike.position + dir.normalized() * $FiringArea/FiringRange.shape.radius
		tween.tween_property(spike, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# Clean up the spike after it reaches its destination
		tween.tween_callback(Callable(spike, "queue_free"))




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
		
	

func show_upgrade_menu():
	$UpgradeMenuPanel.show()
	

func _on_cross_pressed() -> void:
	$UpgradeMenuPanel.hide()
