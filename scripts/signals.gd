extends Node

signal base_take_damage(amount)
signal enemy_died(money_gained)
signal obstacle_destroyed(position: Vector2, width: int, height: int, rotation: float)
signal game_over()
signal difficulty_increased(new_difficulty: int)
