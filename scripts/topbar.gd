class_name Topbar
extends PanelContainer

@onready var button_obstacle = $HBoxContainer/ObstacleMcont/PanelContainer/HBoxContainer/Button
@onready var button_turret = $HBoxContainer/SingeMcont/PanelContainer/HBoxContainer/Button
@onready var label_money = $HBoxContainer/MoneyMCont/PanelContainer/HBoxContainer/LabelMoney
@onready var lifebar = $HBoxContainer/LifeContainer/PanelContainer/LifeBar

@export var build_manager: BuildManager
@export var obstacle_scene: PackedScene
@export var turret_scene: PackedScene

func _ready():
	Gamestate.money_changed.connect(update_money)
	update_money(Gamestate.money)
		
	button_obstacle.pressed.connect(on_button_obstacle)
	button_turret.pressed.connect(on_button_turret)

func update_money(money: int):
	label_money.text = str(money)
	
	if build_manager.turret_cost > money:
		button_turret.disabled = true
	else:
		button_turret.disabled = false
	
	if build_manager.obstacle_cost > money:
		button_obstacle.disabled = true
	else:
		button_obstacle.disabled = false

func update_life(life: int):
	lifebar.set_value(life)

func on_button_obstacle():
	build_manager.start_build(obstacle_scene, build_manager.obstacle_cost)

func on_button_turret():
	build_manager.start_build(turret_scene, build_manager.turret_cost)
