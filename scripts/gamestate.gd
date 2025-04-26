extends Node

signal money_changed(new_amount: int)

var money: int = 100

func add_money(amount: int):
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false
