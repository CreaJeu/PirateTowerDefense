class_name Enemy
extends CharacterBody2D

@onready var initial_speed = 100.0
@onready var speed = 100.0
@onready var damage = 10.0
@onready var money_on_death = 10.0
@onready var target: Node2D
@onready var health = 10.0


@onready var attack_range = $MeleeRange
@onready var attack_timer = $MeleeAttackTimer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var slow_timer = $SlowTimer

signal enemy_hit_base()
	
var obstacles_in_range: Array[StaticBody2D] = []
var is_ready := false
var construction_mask: TileMapLayer

func initialize(target_node: Node2D, start_position: Vector2):
	target = target_node
	global_position = start_position
	nav_agent.target_position = target.global_position
	
func _ready():
	add_to_group("enemies")
	$Hitbox.add_to_group("build_blocker")
	enemy_hit_base.connect(_on_hit_base)
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	$AnimatedSprite2D.play("down")
	is_ready = true
	

func _physics_process(delta):
	if not is_ready:
		return
	if nav_agent.is_navigation_finished():
		return	
	
	var cell = construction_mask.local_to_map(global_position)
			
	var tile_data = construction_mask.get_cell_tile_data(cell)
	if tile_data == null:
		return # Out of map bounds
	
	var tile_type: String = tile_data.get_custom_data("type")
	var on_water = false
	
	match tile_type:
		"water":
			on_water = true
		_:
			on_water = false

			
	if obstacles_in_range.is_empty():
		var next_path_point = nav_agent.get_next_path_position()
		var direction = (next_path_point - global_position).normalized()
		
		velocity = direction * speed
		move_and_slide()
		# Animation control
		if on_water:
			$AnimatedSprite2D.visible = false
			$BoatSprite.visible = true
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					$BoatSprite.texture = load("res://assets/sprites/enemy/boat/BateauDroit.png")
				else:
					$BoatSprite.texture = load("res://assets/sprites/enemy/boat/BateauGauche.png")
			else:
				if direction.y > 0:
					$BoatSprite.texture = load("res://assets/sprites/enemy/boat/BateauBas.png")
				else:
					$BoatSprite.texture = load("res://assets/sprites/enemy/boat/BateauHaut.png")
		else:
			$AnimatedSprite2D.visible = true
			$BoatSprite.visible = false
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					$AnimatedSprite2D.play("right")
				else:
					$AnimatedSprite2D.play("left")
			else:
				if direction.y > 0:
					$AnimatedSprite2D.play("down")
				else:
					$AnimatedSprite2D.play("up")

				
func _on_attack_range_body_entered(body):
	if body is Obstacle or body is Turret or body is Herisson or body is Lama:
		obstacles_in_range.append(body)
		if not attack_timer.is_stopped():
			return
		attack_timer.start()
		
func _on_attack_range_body_exited(body):
	if body is Obstacle or body is Turret or body is Herisson or body is Lama:
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
		
func attack_obstacle(obstacle: StaticBody2D):
	if not (obstacle is Obstacle or obstacle is Turret or obstacle is Herisson or obstacle is Lama):
		return
	
	if is_instance_valid(obstacle):
		obstacle.take_damage(damage)
	else:
		obstacles_in_range.remove_at(0)

func die():
	Signals.enemy_died.emit(money_on_death)
	$DeathNoise.play()
	visual_damage(0.2)
	queue_free()
	
func hit_taken(damage_taken,slow_strength = 0,slow_duration = 0):
	health -= damage_taken
	if(slow_strength != 0):
		if(speed == initial_speed): #eviter d'accumuler du slow
			speed -= slow_strength
			slow_timer.wait_time = slow_duration
			slow_timer.start()
	
	if(health<0):
		die()
	else:
		visual_damage(0.15)
		
		
func visual_damage(time: float):
	$AnimatedSprite2D.modulate = Color(1, 0, 0) # Red
	# Wait a short time then reset color
	await get_tree().create_timer(time).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # Default (white, no tint)

func _on_slow_timer_timeout() -> void:
	speed = initial_speed
