extends Turret
class_name Lama

var damage: int = 2
var slow_strength: int = 50
var slow_duration: int = 2 

@onready var upgrade_attack_speed_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/AttackSpeedButton
@onready var upgrade_slow_duration_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/StrongerSlowButton
@onready var upgrade_slow_strength_button: Button = $UpgradeMenuPanel/MarginContainer/VSplitContainer/GridContainer/LongerSlowButton



@onready var current_slow_strength_upgrade = 1
@onready var current_attack_speed_upgrade = 1
@onready var current_slow_duration_upgrade = 1
@onready var current_lama_level = 1



func _ready():
	$ConstructionRestriction.add_to_group("build_blocker")
	$FiringArea.connect("body_entered", _on_body_entered)
	$FiringArea.connect("body_exited", _on_body_exited)
	projectile_scene = load("res://scenes/projectiles/bave_lama.tscn")
	
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	health = max_health

	if (placed):
		$Button.show()

	upgrade_attack_speed_button.pressed.connect(upgrade_attack_speed)
	upgrade_slow_strength_button.pressed.connect(upgrade_slow_duration)
	upgrade_slow_duration_button.pressed.connect(upgrade_slow_strength)

	Gamestate.money_changed.connect(check_money)


func upgrade_slow_strength():
	if current_slow_strength_upgrade >= 5:
		upgrade_slow_duration_button.disabled = true
		print("current_hp_upgrade maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	slow_strength += 10
	
	current_slow_strength_upgrade += 1
	check_lama_level()

func upgrade_slow_duration():
	if current_slow_duration_upgrade>= 5:
		upgrade_slow_strength_button.disabled = true
		print("upgrade_range maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
	
	slow_duration += 1
	
	current_slow_duration_upgrade += 1
	check_lama_level()

func upgrade_attack_speed():
	if current_attack_speed_upgrade >= 5:
		upgrade_attack_speed_button.disabled = true
		print("current_attack_speed_upgrade maxed")
		return
	
	if not (Gamestate.spend_money(20)):
		return
		
	fire_rate -= 0.03
	
	current_attack_speed_upgrade += 1
	check_lama_level()

func check_lama_level():
	if current_lama_level >= 4:
		return
		
	var total_level = current_attack_speed_upgrade + current_slow_duration_upgrade + current_slow_strength_upgrade
	if total_level < current_lama_level*5:
		return
		
	current_lama_level += 1
	if current_lama_level == 1:
		$Sprite2D.texture = load("res://assets/sprites/structure/herisson.png")
	elif current_lama_level == 2:
		$Sprite2D.texture = load("res://assets/sprites/structure/lamaUpgrade1.png")
	elif current_lama_level == 3:
		$Sprite2D.texture = load("res://assets/sprites/structure/lamaUpgrade2.png")
	elif current_lama_level == 4:
		$Sprite2D.texture = load("res://assets/sprites/structure/lamaUpgrade3.png")


func check_money(current_money: int):
	if current_money < 20:
		upgrade_attack_speed_button.disabled = true
		upgrade_slow_duration_button.disabled = true
		upgrade_slow_strength_button.disabled = true
	else:
		if current_attack_speed_upgrade < 5:
			upgrade_attack_speed_button.disabled = false
		if current_slow_duration_upgrade < 5:
			upgrade_slow_duration_button.disabled = false
		if current_slow_strength_upgrade < 5:
			upgrade_slow_strength_button.disabled = false


func _on_button_pressed() -> void:
	$UpgradeMenuPanel.show()



func _on_cross_pressed() -> void:
	$UpgradeMenuPanel.hide()
