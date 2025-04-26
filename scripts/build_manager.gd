class_name BuildManager
extends Node2D

@export var obstacle_scene: PackedScene
@export var turret_scene: PackedScene
@export var obstacle_cost: int = 70
@export var turret_cost: int = 100
@export var construction_mask: TileMapLayer

@onready var obstacles = $"../Obstacles"
@onready var turrets = $"../Turrets"

var build_mode: bool = false
var ghost_instance: Node2D
var building_scene: PackedScene
var building_cost: int

var blocked_land_atlas_coords = Vector2i(0,0)
var free_land_atlas_coords = Vector2i(2,0)

func _ready() -> void:
	Signals.obstacle_destroyed.connect(free_area_at)

func start_build(scene: PackedScene, cost: int):
	if ghost_instance:
		ghost_instance.queue_free()
		
	build_mode = true
	building_scene = scene
	building_cost = cost
	
	construction_mask.visible = true
	
	ghost_instance = scene.instantiate()
	ghost_instance.modulate = ghost_instance.modulate - Color(0, 0, 0, 0.5)
	ghost_instance.set_collision_layer(0)
	ghost_instance.set_collision_mask(1)
	
	if ghost_instance is Turret:
		ghost_instance.is_active = false
		ghost_instance.get_node("FiringRange").disabled = true

	add_child(ghost_instance)

func cancel_build():
	if ghost_instance:
		ghost_instance.queue_free()
	ghost_instance = null
	build_mode = false
	construction_mask.visible = false

func _process(delta):
	if not build_mode:
		return
	
	# Move ghost to mouse
	ghost_instance.global_position = get_global_mouse_position()
	var valid = false
	
	if ghost_instance is Obstacle:
		valid = can_build_at(ghost_instance.global_position, 12, 4, ghost_instance.rotation)
	if ghost_instance is Turret:
		valid = can_build_at(ghost_instance.global_position, 6, 6, ghost_instance.rotation)

	if valid:
		ghost_instance.modulate = Color(0, 1, 0, 0.5) # Green semi-transparent
	else:
		ghost_instance.modulate = Color(1, 0, 0, 0.5) # Red semi-transparent

	if Input.is_action_just_released("place_object") and not get_viewport().gui_get_hovered_control():
		print("Trying placing object")
		try_place(valid)
		
	if Input.is_action_just_released("cancel_build"):
		cancel_build()

func try_place(is_blocked):
	if not ghost_instance:
		return
	
	# Get all bodies overlapping the ghost
	if not is_blocked:
		print("Cannot build here, something is blocking!")
		return
	
	# All clear to build!
	if not Gamestate.spend_money(building_cost):
		print("Not enough money!")
		return
	
	var real_instance = building_scene.instantiate()
	real_instance.global_position = ghost_instance.global_position
	real_instance.rotation = ghost_instance.rotation
	obstacles.add_child(real_instance)
	
	if real_instance is Obstacle:
		reserve_area_at(real_instance.global_position, 12, 3, blocked_land_atlas_coords, real_instance.rotation)
	if real_instance is Turret:
		reserve_area_at(real_instance.global_position, 6, 6, blocked_land_atlas_coords, real_instance.rotation)
	
	cancel_build()

func can_build_at(position: Vector2, width: int, height: int, rotation: float = 0.0) -> bool:
	for x in range(width):
		for y in range(height):
			var local_offset = Vector2(x, y) - Vector2(width / 2, height / 2) + Vector2(0.5, 0.5)
			local_offset = local_offset.rotated(rotation)
			var check_pos = position + local_offset * construction_mask.rendering_quadrant_size
			var cell = construction_mask.local_to_map(check_pos)
			
			var tile_data = construction_mask.get_cell_tile_data(cell)
			if tile_data == null:
				return false # Out of map bounds
			
			var tile_type: String = tile_data.get_custom_data("type")
			
			match tile_type:
				"free_land":
					continue # Good
				"blocked_land", "water":
					return false # Cannot build here
				_:
					continue # Consider it buildable unless defined otherwise

	return true # All checked tiles were OK

func reserve_area_at(position: Vector2, width: int, height: int, atlas_coords: Vector2i, rotation: float = 0.0):
	for x in range(width):
		for y in range(height):
			var local_offset = Vector2(x, y) - Vector2(width/4, height/4) # ça a l'air passable
			local_offset = local_offset.rotated(rotation)
			var coords = construction_mask.local_to_map(position + local_offset * construction_mask.rendering_quadrant_size)
			var source_id = construction_mask.get_cell_source_id(coords)
			construction_mask.set_cell(coords, source_id, atlas_coords)
			construction_mask.get_cell_tile_data(coords).set_custom_data("type", "blocked_land")

func free_area_at(position: Vector2, width: int, height: int, rotation: float = 0.0):
	for x in range(width):
		for y in range(height):
			var local_offset = Vector2(x, y) - Vector2(width/4, height/4) # ça a l'air passable
			local_offset = local_offset.rotated(rotation)
			var coords = construction_mask.local_to_map(position + local_offset * construction_mask.rendering_quadrant_size)
			var source_id = construction_mask.get_cell_source_id(coords)
			construction_mask.set_cell(coords, source_id, free_land_atlas_coords)
			construction_mask.get_cell_tile_data(coords).set_custom_data("type", "free_land")

func _unhandled_input(event):
	if not build_mode or ghost_instance == null:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			ghost_instance.rotation += deg_to_rad(30)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			ghost_instance.rotation -= deg_to_rad(30)
