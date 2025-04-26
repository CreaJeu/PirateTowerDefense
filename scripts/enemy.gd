class_name Enemy
extends CharacterBody2D

@export var speed = 100.0
@export var damage = 10.0
@export var money_on_death = 10.0
@export var target: Node2D


@onready var attack_range = $MeleeRange
@onready var attack_timer = $MeleeAttackTimer
@onready var nav_agent = $NavigationAgent2D

signal enemy_hit_base()
	
var obstacles_in_range: Array[Obstacle] = []
var is_ready := false


func initialize(target_node: Node2D, start_position: Vector2):
	target = target_node
	global_position = start_position
	nav_agent.target_position = target.global_position
	is_ready = true
	
func _ready():
	add_to_group("enemies")
	$Hitbox.add_to_group("build_blocker")
	enemy_hit_base.connect(_on_hit_base)
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	$AnimatedSprite2D.play("down")

func _physics_process(delta):
	if not is_ready:
		return
	if nav_agent.is_navigation_finished():
		return	
		
	if obstacles_in_range.is_empty():
		var next_path_point = nav_agent.get_next_path_position()
		var direction = (next_path_point - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
				
func _on_attack_range_body_entered(body):
	if body is Obstacle:
		obstacles_in_range.append(body)
		if not attack_timer.is_stopped():
			return
		attack_timer.start()
		
func _on_attack_range_body_exited(body):
	if body is Obstacle:
		obstacles_in_range.erase(body)
		if obstacles_in_range.is_empty():
			attack_timer.stop()
				
func _on_hit_base():
	Signals.base_take_damage.emit(damage)
	Signals.enemy_died.emit(money_on_death)
	queue_free()
	
	
func _on_attack_timer_timeout():
	if obstacles_in_range.is_empty():
		return
	
	var obstacle = obstacles_in_range[0]
	attack_obstacle(obstacle)
		
func attack_obstacle(obstacle: Obstacle):
	if is_instance_valid(obstacle):
		obstacle.take_damage(damage)
	else:
		obstacles_in_range.remove_at(0)

func die():
	Signals.enemy_died.emit(money_on_death)
	queue_free()
