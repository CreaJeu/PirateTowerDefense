class_name EnemySpawner
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_rate = 1.5 # seconds between spawns
@export var spawn_distance = 960.0

# Difficulty scaling parameters
@export var min_spawn_rate = 0.04 # fastest possible spawn rate
@export var kills_per_difficulty_increase = 50 # kills needed for each speed increase
@export var spawn_rate_decrease_amount = 0.1 # how much faster spawns get per threshold

@onready var spawn_timer: Timer = $SpawnTimer

var game_over := false
var timer := 0.0
var current_spawn_rate: float

func _ready() -> void:
	Signals.game_over.connect(_on_game_over)
	current_spawn_rate = spawn_rate
	Signals.enemy_died.connect(_check_difficulty_increase)
	
	spawn_timer.wait_time = current_spawn_rate
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start()
	
func spawn_enemy():
	if game_over:
		return
	
	var enemy: Enemy = enemy_scene.instantiate()
	$"../Enemies".add_child(enemy)
	var angle = randf() * 360
	var spawn_pos = Vector2(960, 540) + Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = spawn_pos
	var base = $"../Base"
	enemy.target = base
	enemy.construction_mask = $"../ConstructionMask"
	
	var min_value = 0.8
	var max_value = 1.2
	var random_float_in_range = randf_range(min_value, max_value)
	enemy.scale = Vector2(random_float_in_range,random_float_in_range)
	
	enemy.initialize(base, spawn_pos)

func _on_game_over():
	game_over = true
	spawn_timer.stop()
	print("EnemySpawner: Stopped spawning after game over.")

func _check_difficulty_increase(_unused: int):
	var kills = Gamestate.get_kills()
	
	# Calculate how many difficulty increases should have happened
	var new_difficulty = int(kills / kills_per_difficulty_increase)
	if new_difficulty == Gamestate.difficulty_level:
		return
		
	Gamestate.difficulty_level =  new_difficulty
	Signals.difficulty_increased.emit(new_difficulty)
	
	# Calculate what the spawn rate should be based on difficulty level
	var new_spawn_rate = spawn_rate - (Gamestate.difficulty_level * spawn_rate_decrease_amount)
	
	# Clamp to minimum spawn rate
	new_spawn_rate = max(new_spawn_rate, min_spawn_rate)
	
	current_spawn_rate = new_spawn_rate
	spawn_timer.wait_time = current_spawn_rate
	print("Difficulty increased! New spawn rate: ", current_spawn_rate)
