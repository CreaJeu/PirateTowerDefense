extends Node

signal money_changed(new_amount: int)

var money: int = 100

func _ready() -> void:
	Signals.enemy_died.connect(add_money)

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
