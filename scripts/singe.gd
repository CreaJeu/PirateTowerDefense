extends Turret
class_name Singe


var current_damage_upgrade = 1
var current_proj_speed_upgrade = 1
var current_range_upgrade = 1

@onready var upgrade_damage_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/DamageButton
@onready var upgrade_proj_speed_button: Button =$UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/ProjSpeedButton
@onready var upgrade_range_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/RangeButton

func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$ConstructionRestriction.add_to_group("obstacles")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	projectile_scene 
	
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	if (placed):
		$Button.show()
	health = max_health
	
	upgrade_proj_speed_button.pressed.connect(upgrade_projectile_speed)
	upgrade_range_button.pressed.connect(upgrade_range)
	
	Gamestate.money_changed.connect(check_money)
	$SpawnAudioContainer.get_children()[randf_range(0,2)].play()
	

	

	
func _process(delta):
	# Handle rotation toward target if there are enemies
	if not enemies_in_range.is_empty() and is_active:
		var target = get_closest_enemy()
		if target:
			_rotate_toward(target, delta)


	
func _on_cross_pressed() -> void:
	$UpgradeMenuPanel.hide()


func upgrade_range():
	if current_range_upgrade >= 5:
		upgrade_range_button.disabled = true
		print("upgrade_range maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	$FiringArea/FiringRange.shape.radius += 30
	
	current_range_upgrade += 1
	check_level()

func upgrade_projectile_speed():
	if current_proj_speed_upgrade >= 5:
		upgrade_proj_speed_button.disabled = true
		print("upgrade_projectile_speed maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
		
	projectile_speed += 100
	
	current_proj_speed_upgrade += 1
	check_level()

func check_money(current_money: int):
	if current_money < 20:
		upgrade_proj_speed_button.disabled = true
		upgrade_range_button.disabled = true
	else:
		if current_proj_speed_upgrade < 5:
			upgrade_proj_speed_button.disabled = false
		if current_range_upgrade < 5:
			upgrade_range_button.disabled = false

func check_level():
	if current_level >= 4:
		return
		
	var total_level = current_proj_speed_upgrade + current_range_upgrade # + current_damage_upgrade
	if total_level < current_level*3:
		return
		
	current_level += 1
	if current_level == 1:
		$Sprite2D.texture = load("res://assets/sprites/structure/Singe.png")
	elif current_level == 2:
		$Sprite2D.texture = load("res://assets/sprites/structure/SingeUpgrade1.png")
	elif current_level == 3:
		$Sprite2D.texture = load("res://assets/sprites/structure/SingeUpgrade2.png")
	elif current_level == 4:
		$Sprite2D.texture = load("res://assets/sprites/structure/SingeUpgrade3.png")
