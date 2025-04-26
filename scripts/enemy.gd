class_name Enemy
extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@export var speed = 100.0
@export var damage = 10.0
@export var target: Node2D

var is_ready := false

signal enemy_hit_base()
	
func _ready():
	add_to_group("enemies")
	enemy_hit_base.connect(_on_hit_base)
	
func initialize(target_node: Node2D, start_position: Vector2):
	target = target_node
	global_position = start_position
	nav_agent.target_position = target.global_position
	is_ready = true

func _physics_process(delta):
	if not is_ready:
		return
	if nav_agent.is_navigation_finished():
		return	
	var next_path_point = nav_agent.get_next_path_position()
	var direction = (next_path_point - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
func _on_hit_base():
	Signals.base_take_damage.emit(damage)
	queue_free()
