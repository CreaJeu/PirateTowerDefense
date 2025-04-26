class_name BuildManager
extends Node2D

@export var obstacle_scene: PackedScene
@export var turret_scene: PackedScene
@export var obstacle_cost: int = 30
@export var turret_cost: int = 50

@onready var obstacles = $"../Obstacles"
@onready var turrets = $"../Turrets"

var build_mode: bool = false
var ghost_instance: Node2D
var building_scene: PackedScene
var building_cost: int

func start_build(scene: PackedScene, cost: int):
	if ghost_instance:
		ghost_instance.queue_free()
		
	build_mode = true
	building_scene = scene
	building_cost = cost
	
	ghost_instance = scene.instantiate()
	ghost_instance.modulate = ghost_instance.modulate - Color(0, 0, 0, 0.5) # Make it semi-transparent
	ghost_instance.process_mode = Node.PROCESS_MODE_DISABLED # Stop it from acting
	add_child(ghost_instance)

func cancel_build():
	if ghost_instance:
		ghost_instance.queue_free()
	ghost_instance = null
	build_mode = false

func _process(delta):
	if not build_mode:
		return
	
	# Move ghost to mouse
	ghost_instance.global_position = get_global_mouse_position()
	var overlapping_bodies = ghost_instance.get_overlapping_bodies()
	
	var valid = true
	for body in overlapping_bodies:
		if body.is_in_group("build_blocker"):
			valid = false
			break
	
	ghost_instance.modulate = Color(0, 1, 0, 0.5) if valid else Color(1, 0, 0, 0.5)

	if Input.is_action_just_released("place_object") and not get_viewport().gui_get_hovered_control():
		print("Trying placing object")
		try_place()
		
	if Input.is_action_just_released("cancel_build"):
		cancel_build()

func try_place():
	if not ghost_instance:
		return
	
	# Get all bodies overlapping the ghost
	var overlapping_bodies = ghost_instance.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("build_blocker"):
			print("Cannot build here, something is blocking!")
			return
	
	# All clear to build!
	if not Gamestate.spend_money(building_cost):
		print("Not enough money!")
		return
	
	var real_instance = building_scene.instantiate()
	real_instance.global_position = ghost_instance.global_position
	obstacles.add_child(real_instance)
		
	cancel_build()
