extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@export var speed = 100.0
@export var target_position: Vector2

func _ready():
	nav_agent.target_position = target_position

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		return
	var next_path_point = nav_agent.get_next_path_position()
	var direction = (next_path_point - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
