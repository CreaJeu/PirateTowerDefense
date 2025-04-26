extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_rate = 1.5 # seconds between spawns
@export var spawn_distance = 600.0

var timer := 0.0

func _process(delta):
	timer += delta
	if timer > spawn_rate:
		spawn_enemy()
		timer = 0.0

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = spawn_pos
	enemy.target_position = $"../Base".global_position
	$"../Enemies".add_child(enemy)
