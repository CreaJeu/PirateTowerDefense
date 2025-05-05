class_name Topbar
extends PanelContainer

@onready var button_obstacle = $HBoxContainer/ObstacleMcont/PanelContainer/HBoxContainer/Button
@onready var button_singe = $HBoxContainer/SingeMcont/PanelContainer/HBoxContainer/Button
@onready var button_herisson = $HBoxContainer/HerissonMcont/PanelContainer/HBoxContainer/Button
@onready var button_lama = $HBoxContainer/LamaMcont/PanelContainer/HBoxContainer/Button

@onready var label_money = $HBoxContainer/MoneyMCont/PanelContainer/HBoxContainer/LabelMoney
@onready var label_kills = $HBoxContainer/KillsMCont/PanelContainer/HBoxContainer/LabelKills
@onready var label_difficulty = $HBoxContainer/DifficultyMCont/PanelContainer/HBoxContainer/LabelDifficulty

@export var build_manager: BuildManager
@export var obstacle_scene: PackedScene
@export var singe_scene: PackedScene
@export var herisson_scene: PackedScene
@export var lama_scene: PackedScene

func _ready():
	Gamestate.money_changed.connect(update_money)
	update_money(Gamestate.money)
		
	button_obstacle.pressed.connect(on_button_obstacle)
	button_obstacle.text = "Obstacle\n("+str(build_manager.obstacle_cost)+")"
	
	button_singe.pressed.connect(on_button_singe)
	button_singe.text = "Singe\n("+str(build_manager.singe_cost)+")"
	
	button_herisson.pressed.connect(on_button_herisson)
	button_herisson.text = "Hérisson\n("+str(build_manager.herisson_cost)+")"
	
	button_lama.pressed.connect(on_button_lama)
	button_lama.text = "Lama\n("+str(build_manager.lama_cost)+")"

	Signals.enemy_died.connect(update_kills)
	Signals.difficulty_increased.connect(update_difficulty)
	update_kills(0)

func update_money(money: int):
	label_money.text = "[center][b]" + str(money)
	
	if build_manager.singe_cost > money:
		button_singe.disabled = true
	else:
		button_singe.disabled = false
		
	if build_manager.herisson_cost > money:
		button_herisson.disabled = true
	else:
		button_herisson.disabled = false
		
	if build_manager.lama_cost > money:
		button_lama.disabled = true
	else:
		button_lama.disabled = false

	if build_manager.obstacle_cost > money:
		button_obstacle.disabled = true
	else:
		button_obstacle.disabled = false

func update_kills(_unused: int):
	label_kills.text = "[center][b]" + str(Gamestate.get_kills())
	
func update_difficulty(new_difficulty: int):
	label_difficulty.text = "[center][b]" + str(new_difficulty)

func on_button_obstacle():
	build_manager.start_build(obstacle_scene, build_manager.obstacle_cost)

func on_button_singe():
	build_manager.start_build(singe_scene, build_manager.singe_cost)

func on_button_herisson():
	build_manager.start_build(herisson_scene, build_manager.herisson_cost)

func on_button_lama():
	build_manager.start_build(lama_scene, build_manager.lama_cost)
