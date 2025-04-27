extends Node

signal money_changed(new_amount: int)

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
	
func update_kills(_unused: int) -> void:
	kills += 1

func get_kills() -> int:
	return kills
