class_name EnemySpawner
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_rate = 1.5 # seconds between spawns
@export var spawn_distance = 600.0

var game_over := false
var timer := 0.0

func _ready() -> void:
	Signals.game_over.connect(_on_game_over)

func _process(delta):
	if game_over: 
		return
		
	# Using delta is bad, use a timer
	timer += delta
	if timer > spawn_rate:
		spawn_enemy()
		timer = 0.0

func spawn_enemy():
	var enemy: Enemy = enemy_scene.instantiate()
	$"../Enemies".add_child(enemy)
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = spawn_pos
	var base = $"../Base"
	enemy.target = base
	
	enemy.initialize(base, spawn_pos)

func _on_game_over():
	game_over = true
	print("EnemySpawner: Stopped spawning after game over.")
