extends Node

signal money_changed(new_amount: int)
signal kills_changed(new_amount: int)
signal difficulty_increased(new_difficulty: int)

var starting_money = 200
var money: int = 200
var kills: int = 0
var difficulty_level: int = 0

func _ready() -> void:
	Signals.enemy_died.connect(add_money)
	Signals.enemy_died.connect(update_kills)

func add_money(amount: int):
	print("Money!")
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func set_money(new_amount: int) -> void:
	money = new_amount
	money_changed.emit(money)

func update_kills(_unused: int) -> void:
	kills += 1
	kills_changed.emit(kills)

func get_kills() -> int:
	return kills

func set_kills(new_amount: int) -> void:
	kills = new_amount
	kills_changed.emit(kills)

func set_difficulty(new_difficulty: int) -> void:
	difficulty_level = new_difficulty
	difficulty_increased.emit(difficulty_level)

func reset_all() -> void:
	set_difficulty(0)
	set_kills(0)
	set_money(starting_money)
